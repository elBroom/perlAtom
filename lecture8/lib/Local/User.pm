package Local::User;

use v5.10;
use strict;
use warnings;
no warnings 'experimental';

use Data::Dumper;
use JSON::XS;

use Local::Source::Loader;
use Local::Source::MySQL;
use Local::Source::Memcached;

use Local::Post;

=encoding utf8

=head1 NAME

Local::User - user

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

use Class::XSAccessor {
	accessors => [qw/
		refresh site
	/],
};

my $instance;

sub new{
	my ($class) = @_;
	$instance ||= bless {}, $class;
}

sub get_user{
	my ($self, $name) = @_;
	my $result;

	$result = $self->_memcached_get_user($name) unless($self->refresh);
	unless($result){
		$result = $self->_mysql_get_user($name) unless($self->refresh);
		unless($result){
			$result = $self->_loader_get_user($name);
			die "User not found $name" unless($result);
			$self->_mysql_set_user($result);
		}
		$self->_memcached_set_user($result);
	}
	return $result;
}

sub get_commenters{
	my ($self, $id) = @_;
	my $result;
	my $commenters;

	$commenters = $self->_mysql_get_commenters($id) unless($self->refresh);
	if($commenters && @{$commenters}){
		$result->{'comments'} = $commenters;
	} else{
		$result = Local::Post->new->get_loader_post($id);
	}
	return $result;
}

sub set_commenter{
	my ($self, $post, $user) = @_;
	$self->_mysql_set_commenter($post, $user);
}

sub get_user_post{
	my ($self, $post) = @_;

	my $author = Local::Post->new->get_post($post)->{'author'};
	return $self->get_user($author);
}

sub get_self_commentors{
	my ($self) = @_;
	my $result;

	$result = $self->_memcached_get_self_commentors() unless($self->refresh);
	unless($result){
		$result = $self->_mysql_get_self_commentors;
		$self->_memcached_set_self_commentors($result);
	}
	return $result;
}

sub del_self_commentors{
	my ($self) = @_;
	$self->_memcached_del_self_commentors();
}

sub _loader_get_user{
	my ($self, $name) = @_;
	my %result;
	
	my $tree = Local::Source::Loader->new->connection->get_tree($self->site, 'users', $name);
	return undef unless($tree);

	$result{'username'} = $tree->findvalue('//a[@class = "author-info__nickname"]');
	$result{'username'} =~ s/^.{1}//s;
	$result{'karma'} = $tree->findvalue('//div[@class = "voting-wjt__counter-score js-karma_num"]');
	$result{'karma'} =~ s/,/./s;
	$result{'rating'} = $tree->findvalue('//div[@class = "statistic__value statistic__value_magenta"]');
	$result{'rating'} =~ s/,/./s;

	return \%result;
}

sub _mysql_get_user{
	my ($self, $name) = @_;

	return Local::Source::MySQL->new->connection->selectrow_hashref(
		'SELECT uname as username, karma, rating FROM user WHERE uname = ?',
		{}, $name
	) if ($name);

	return undef;
}

sub _mysql_set_user{
	my ($self, $data) = @_;

	return Local::Source::MySQL->new->connection->prepare(
		'INSERT INTO user (uname, karma, rating, last_update) VALUES (?,?,?,NOW())
		ON DUPLICATE KEY UPDATE karma=?, rating=?, last_update=NOW()'
	)->execute(
		$data->{'username'}, $data->{'karma'}, $data->{'rating'},
		$data->{'karma'}, $data->{'rating'}
	) if($data->{'username'});
}

sub _mysql_get_commenters{
	my ($self, $id) = @_;

	return Local::Source::MySQL->new->connection->selectall_arrayref(
		'SELECT uname as username, karma, rating FROM user
		JOIN commenter USING(id_user) WHERE id_post = ?',
		{ Slice => {} }, $id
	) if ($id);

	return undef;
}

sub _mysql_set_commenter{
	my ($self, $post, $user) = @_;

	return Local::Source::MySQL->new->connection->prepare(
		'INSERT IGNORE INTO commenter (id_post, id_user) VALUES (?, (SELECT id_user FROM user WHERE uname=?))'
	)->execute(
		$post->{'id'}, $user->{'username'}
	) if($post->{'id'} and $user->{'username'});
}

sub _mysql_get_self_commentors{
	my ($self) = @_;
	return Local::Source::MySQL->new->connection->selectall_arrayref(
		'SELECT uname as username, karma, user.rating FROM commenter 
			JOIN user USING(id_user)
			JOIN post USING(id_post)
			WHERE author = uname',
		{ Slice => {} }
	);
}

sub _memcached_get_user{
	my ($self, $name) = @_;
	my $data = Local::Source::Memcached->new->connection->get($self->site.'_user_'.$name);

	return JSON::XS->new->utf8->decode($data) if($data);
	return undef;
}

sub _memcached_set_user{
	my ($self, $data) = @_;

	return Local::Source::Memcached->new->connection->set(
		$self->site.'_user_'.$data->{'username'},
		JSON::XS->new->utf8->encode($data),
		60
	) if ($data->{'username'});
}

sub _memcached_get_self_commentors{
	my ($self) = @_;
	my $data = Local::Source::Memcached->new->connection->get($self->site.'_self_commentors');

	return JSON::XS->new->utf8->decode($data) if($data);
	return undef;
}

sub _memcached_set_self_commentors{
	my ($self, $data) = @_;

	return Local::Source::Memcached->new->connection->set(
		$self->site.'_self_commentors',
		JSON::XS->new->utf8->encode($data),
		60
	) if ($data);
}

sub _memcached_del_self_commentors{
	my ($self) = @_;
	return Local::Source::Memcached->new->connection->delete($self->site.'_self_commentors');
}

1;
