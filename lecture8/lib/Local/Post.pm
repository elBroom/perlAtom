package Local::Post;

use v5.10;
use strict;
use warnings;
no warnings 'experimental';

use List::MoreUtils qw(uniq);
use Data::Dumper;
use JSON::XS;

use Local::Source::Loader;
use Local::Source::MySQL;
use Local::Source::Memcached;

use Local::User;

=encoding utf8

=head1 NAME

Local::Post - post

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

sub get_posts{
	my ($self, $ids) = @_;
	my @result;
	for (grep { $_>0 } map { $_+0 } split /,/, $ids){
		my $post = $self->get_post($_);
		delete $post->{'id'};
		delete $post->{'comments'};
		push(@result, $post);
	}
	return \@result;
}

sub get_post{
	my ($self, $id) = @_;
	my $result;

	$result = $self->_mysql_get_post($id) unless($self->refresh);
	$result = $self->get_loader_post($id) unless($result);
	return $result;
}

sub get_loader_post{
	my ($self, $id) = @_;
	my $result;

	$result = $self->_loader_get_post($id);
	die "Post not found $id" unless($result);

	my @commenters;
	for my $name (@{$result->{'comments'}}) {
		my $user = Local::User->new->get_user($name);
		if($user){
			push(@commenters, $user);
			Local::User->new->set_commenter($result, $user);
		}
	}
	$result->{'comments'} = \@commenters;
	Local::User->new->del_self_commentors();
	$self->_memcached_del_desert_posts();
	$self->_mysql_set_post($result);
	return $result;
}

sub get_desert_posts{
	my ($self, $n) = @_;
	my $result;

	$result = $self->_memcached_get_desert_posts($n) unless($self->refresh);
	unless($result){
		$result = $self->_mysql_get_desert_posts($n);
		$self->_memcached_set_desert_posts({$n => $result});
	}
	return $result;
}

sub _loader_get_post{
	my ($self, $id) = @_;
	my %result;
	
	my $tree = Local::Source::Loader->new->connection->get_tree($self->site, 'post', $id);
	return undef unless($tree);

	$result{'id'} = $id;
	$result{'author'} = $tree->findvalue('//div[@class = "author-info "]//a[@class = "author-info__nickname"]');
	unless($result{'author'}){ #from blog
		$result{'author'} = $tree->findvalue('//a[@class = "post-type__value post-type__value_author"]');
	}
	$result{'author'} =~ s/^.{1}//s;
	$result{'theme'} = ($tree->findvalues('//h1[@class = "post__title"]/span'))[1];
	$result{'rating'} = $tree->findvalue('//ul[@class = "postinfo-panel postinfo-panel_post"]//span[@class = "voting-wjt__counter-score js-score"]');
	$result{'count_view'} = $tree->findvalue('//div[@class = "views-count_post"]');
	$result{'count_star'} = $tree->findvalue('//span[@class = "favorite-wjt__counter js-favs_count"]');
	
	my @names;
	for ($tree->findvalues('//a[@class = "comment-item__username"]')){
		push(@names, $_);
	}
	@names = uniq @names;
	$result{'comments'} = \@names;
	
	return \%result;
}

sub _mysql_get_post{
	my ($self, $id) = @_;

	return Local::Source::MySQL->new->connection->selectrow_hashref(
		'SELECT author, theme, rating, count_view, count_star FROM post WHERE id_post = ?',
		{}, $id
	) if ($id);

	return undef;
}

sub _mysql_set_post{
	my ($self, $data) = @_;

	return Local::Source::MySQL->new->connection->prepare(
		'INSERT INTO post (id_post, author, theme, rating, count_view, count_star, last_update) VALUES (?,?,?,?,?,?,NOW())
		ON DUPLICATE KEY UPDATE author=?, theme=?, rating=?, count_view=?, count_star=?, last_update=NOW()'
	)->execute(
		$data->{'id'}, $data->{'author'}, $data->{'theme'}, $data->{'rating'}, $data->{'count_view'}, $data->{'count_star'},
		$data->{'author'}, $data->{'theme'}, $data->{'rating'}, $data->{'count_view'}, $data->{'count_star'}
	) if($data->{'id'});
}

sub _mysql_get_desert_posts{
	my ($self, $n) = @_;

	return Local::Source::MySQL->new->connection->selectall_arrayref(
		'SELECT author, theme, post.rating, count_view, count_star FROM commenter 
			JOIN user USING(id_user)
			JOIN post USING(id_post)
			GROUP BY id_post
			HAVING COUNT(*) < ?',
		{ Slice => {} }, $n
	) if ($n);

	return undef;
}

sub _memcached_get_desert_posts{
	my ($self, $n) = @_;
	my $data = Local::Source::Memcached->new->connection->get($self->site.'_desert_posts');

	if($data){
		$data = JSON::XS->new->utf8->decode($data);
		return $data->{$n} if($data->{$n});
	}
	return undef;
}

sub _memcached_set_desert_posts{
	my ($self, $data) = @_;

	my $old_data = Local::Source::Memcached->new->connection->get($self->site.'_desert_posts');
	if($old_data){
		$old_data = JSON::XS->new->utf8->decode($old_data);
		$old_data->{$_} = $data->{$_} for (keys %{$data});
		$data = $old_data;
	}
	return Local::Source::Memcached->new->connection->set(
		$self->site.'_desert_posts',
		JSON::XS->new->utf8->encode($data),
		60
	) if ($data);
}

sub _memcached_del_desert_posts{
	my ($self) = @_;
	return Local::Source::Memcached->new->connection->delete($self->site.'_desert_posts');
}

1;
