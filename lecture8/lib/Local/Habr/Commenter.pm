package Local::Habr::Commenter;
use parent 'Local::Habr';

use v5.10;
use strict;
use warnings;
no warnings 'experimental';

use Data::Dumper;
use JSON::XS;

use Local::Source::MySQL;
use Local::Source::Memcached;

use Local::Habr::Post;
use Local::Habr::User;

=encoding utf8

=head1 NAME

Local::Commenter - commenter

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub get_commenters{
	my ($self, $post_id) = @_;
	my $result;
	my $commenters;

	$commenters = $self->_mysql_get_commenters($post_id) unless(Local::Habr::Config->is_refresh);
	if($commenters && @{$commenters}){
		$result = $commenters;
	} else{
		$result = $self->_loader_get_commenters($post_id);
	}
	return $result;
}

sub get_self_commentors{
	my ($self) = @_;
	my $result;

	$result = $self->_memcached_get_self_commentors() unless(Local::Habr::Config->is_refresh);
	unless($result){
		$result = $self->_mysql_get_self_commentors;
		$self->_memcached_set_self_commentors($result);
	}
	return $result;
}

sub get_desert_posts{
	my ($self, $n) = @_;
	my $result;

	$result = $self->_memcached_get_desert_posts($n) unless(Local::Habr::Config->is_refresh);
	unless($result){
		$result = $self->_mysql_get_desert_posts($n);
		$self->_memcached_set_desert_posts({$n => $result});
	}
	return $result;
}

sub update_commenters{
	my ($self, $post, $names) = @_;

	my @commenters;
	for my $name (@{$names}) {
		my $user = Local::Habr::User->new->get_user($name);
		if($user){
			push(@commenters, $user);
			$self->_mysql_set_commenter($post, $user);
		}
	}
	$self->_memcached_del_self_commentors();
	$self->_memcached_del_desert_posts();

	return \@commenters;
}

sub _loader_get_commenters{
	my ($self, $post_id) = @_;

	my $post = Local::Habr::Post->new->get_post($post_id);
	return $post->{'commenters'} if($post->{'commenters'});
	return \[];
}

sub _mysql_get_commenters{
	my ($self, $post_id) = @_;

	return Local::Source::MySQL->connection->selectall_arrayref(
		'SELECT uname as username, karma, rating FROM user
		JOIN commenter USING(id_user) WHERE id_post = ?',
		{ Slice => {} }, $post_id
	) if ($post_id);

	return undef;
}

sub _mysql_set_commenter{
	my ($self, $post, $user) = @_;

	return Local::Source::MySQL->connection->prepare(
		'INSERT IGNORE INTO commenter (id_post, id_user) VALUES (?, (SELECT id_user FROM user WHERE uname=?))'
	)->execute(
		$post->{'id'}, $user->{'username'}
	) if($post->{'id'} and $user->{'username'});
}

sub _mysql_get_self_commentors{
	my ($self) = @_;
	return Local::Source::MySQL->connection->selectall_arrayref(
		'SELECT uname as username, karma, user.rating FROM commenter 
			JOIN user USING(id_user)
			JOIN post USING(id_post)
			WHERE author = uname',
		{ Slice => {} }
	);
}

sub _mysql_get_desert_posts{
	my ($self, $n) = @_;

	return Local::Source::MySQL->connection->selectall_arrayref(
		'SELECT author, theme, post.rating, count_view, count_star FROM commenter 
			JOIN user USING(id_user)
			JOIN post USING(id_post)
			GROUP BY id_post
			HAVING COUNT(*) < ?',
		{ Slice => {} }, $n
	) if ($n);

	return undef;
}

sub _memcached_get_self_commentors{
	my ($self) = @_;
	my $data = Local::Source::Memcached->connection->get(Local::Habr::Config->site.'_self_commentors');

	return JSON::XS->new->utf8->decode($data) if($data);
	return undef;
}

sub _memcached_set_self_commentors{
	my ($self, $data) = @_;

	return Local::Source::Memcached->connection->set(
		Local::Habr::Config->site.'_self_commentors',
		JSON::XS->new->utf8->encode($data),
		60
	) if ($data);
}

sub _memcached_del_self_commentors{
	my ($self) = @_;
	return Local::Source::Memcached->connection->delete(Local::Habr::Config->site.'_self_commentors');
}

sub _memcached_get_desert_posts{
	my ($self, $n) = @_;
	my $data = Local::Source::Memcached->connection->get(Local::Habr::Config->site.'_desert_posts');

	if($data){
		$data = JSON::XS->new->utf8->decode($data);
		return $data->{$n} if($data->{$n});
	}
	return undef;
}

sub _memcached_set_desert_posts{
	my ($self, $data) = @_;

	my $old_data = Local::Source::Memcached->connection->get(Local::Habr::Config->site.'_desert_posts');
	if($old_data){
		$old_data = JSON::XS->new->utf8->decode($old_data);
		$old_data->{$_} = $data->{$_} for (keys %{$data});
		$data = $old_data;
	}
	return Local::Source::Memcached->connection->set(
		Local::Habr::Config->site.'_desert_posts',
		JSON::XS->new->utf8->encode($data),
		60
	) if ($data);
}

sub _memcached_del_desert_posts{
	my ($self) = @_;
	return Local::Source::Memcached->connection->delete(Local::Habr::Config->site.'_desert_posts');
}

1;
