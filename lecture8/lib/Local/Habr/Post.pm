package Local::Habr::Post;
use parent 'Local::Habr';

use v5.10;
use strict;
use warnings;
no warnings 'experimental';

use List::MoreUtils qw(uniq);
use Data::Dumper;
use JSON::XS;

use Local::Source::Loader;
use Local::Source::MySQL;

use Local::Habr::Config;
use Local::Habr::Commenter;

=encoding utf8

=head1 NAME

Local::Habr::Post - post

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub get_posts{
	my ($self, $ids) = @_;
	my @result;
	for (grep { $_>0 } map { $_+0 } split /,/, $ids){
		my $post = $self->get_post($_);
		delete $post->{'id'};
		delete $post->{'commenters'};
		push(@result, $post);
	}
	return \@result;
}

sub get_post{
	my ($self, $id) = @_;
	my $result;

	$result = $self->_mysql_get_post($id) unless(Local::Habr::Config->is_refresh);
	unless($result){
		$result = $self->_loader_get_post($id);
		die "Post not found $id" unless($result);
		$self->_mysql_set_post($result);
	}
	return $result;
}

sub _loader_get_post{
	my ($self, $id) = @_;
	my %result;
	
	my $tree = Local::Source::Loader->connection->get_tree(Local::Habr::Config->site, 'post', $id);
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
	$result{'commenters'} = Local::Habr::Commenter->new->update_commenters(\%result, \@names);

	return \%result;
}

sub _mysql_get_post{
	my ($self, $id) = @_;

	return Local::Source::MySQL->connection->selectrow_hashref(
		'SELECT author, theme, rating, count_view, count_star FROM post WHERE id_post = ?',
		{}, $id
	) if ($id);

	return undef;
}

sub _mysql_set_post{
	my ($self, $data) = @_;

	return Local::Source::MySQL->connection->prepare(
		'INSERT INTO post (id_post, author, theme, rating, count_view, count_star, last_update) VALUES (?,?,?,?,?,?,NOW())
		ON DUPLICATE KEY UPDATE author=?, theme=?, rating=?, count_view=?, count_star=?, last_update=NOW()'
	)->execute(
		$data->{'id'}, $data->{'author'}, $data->{'theme'}, $data->{'rating'}, $data->{'count_view'}, $data->{'count_star'},
		$data->{'author'}, $data->{'theme'}, $data->{'rating'}, $data->{'count_view'}, $data->{'count_star'}
	) if($data->{'id'});
}

1;
