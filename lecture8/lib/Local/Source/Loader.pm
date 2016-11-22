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
use LWP::UserAgent;

=encoding utf8

=head1 NAME

Local::Loader - loader

=head1 VERSION

Version 1.00

=head1 DESCRIPTION

Загрузчик данных по http

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

my $connect;

sub new{
	my ($class) = @_;
	$connect ||= bless {}, $class;
}

sub _connection_ini{
	my ($self) = @_;
	return $self;
}

sub get_tree{
	my ($self, $site, $url, $id) = @_;
	
	$url = "https://$site.ru/$url/$id/";

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
