package Local::Source::Loader;
use parent 'Local::Source';

use strict;
use warnings;

use v5.10;
use strict;
use warnings;
use mro 'c3';

use Data::Dumper;
use HTML::TreeBuilder::XPath;
use List::MoreUtils qw(uniq);
use LWP::UserAgent;

=encoding utf8

=head1 NAME

Local::Loader - loader

=head1 VERSION

Version 1.00

=head1 DESCRIPTION

Класс, объекты которого отвечают за загрузку данных с сайта.

Параметры конструктора:
* `site` — Сайт источника данных.

Методы:
* `get_user()` — возвращает данные пользователя с сайта.
* `get_post()` — возвращает данные поста с сайта.

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub get_user{
	my ($self, $name) = @_;
	my %result;
	
	my $tree = $self->_get_tree('users', $name);
	return undef unless($tree);

	$result{'username'} = $tree->findvalue('//a[@class = "author-info__nickname"]');
	$result{'username'} =~ s/^.{1}//s;
	$result{'karma'} = $tree->findvalue('//div[@class = "voting-wjt__counter-score js-karma_num"]');
	$result{'karma'} =~ s/,/./s;
	$result{'rating'} = $tree->findvalue('//div[@class = "statistic__value statistic__value_magenta"]');
	$result{'rating'} =~ s/,/./s;

	return \%result;
}

sub get_post{
	my ($self, $id) = @_;
	my %result;
	
	my $tree = $self->_get_tree('post', $id);
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

sub _get_tree{
	my ($self, $url, $id) = @_;
	
	$url = "https://".$self->_site().".ru/$url/$id/";

	my $ua = LWP::UserAgent->new(ssl_opts => { verify_hostname => 1 });
	my $try = 3;
	my $content;
	do{
		# say $url;
		my $response = $ua->get($url);
		return undef unless($response->is_success); #404

		if($response->previous){ #301
			$try--;
			$url = $response->request->uri;
		} else{ #200
			$try = 0;
			$content = $response->decoded_content;
		}
	} while($try > 0);

	die 'multiple redirects' unless($content);
	return HTML::TreeBuilder::XPath->new_from_content($content);
}

1;
