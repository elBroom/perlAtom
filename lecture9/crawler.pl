use v5.10;
use strict;
use warnings;

use Data::Dumper;
use AnyEvent;
use AnyEvent::HTTP;
use HTML::TreeBuilder::XPath;

my $count_limit = 10000;
my $site = "https://mephi.ru"; #Site without slash in the end
my $count_top = 10;

my %urls;
my $sum = 0;
$AnyEvent::HTTP::MAX_PER_HOST = 100;
my $cv = AnyEvent->condvar;

sub is_limit{
	keys %urls > $count_limit
}

sub get_length_page{
	my ($url) = @_;

	if(!(defined $urls{$url}) && !is_limit){
		$urls{$url} = 0;
		$cv->begin;
		http_get $site.$url,
		recurse => 0,
		on_header => sub {
			my ($header) = @_;
			return 0 unless($header->{"content-type"} =~ m{^text/html\s*(?:;|$)});
			if($header->{"Status"} =~ m{^30\d$}){
				if($header->{"location"} =~ m{^$site}){
					# $url = $header->{"location"} =~ s/$site//r;
					get_length_page($url);
				}
				return 0;
			}
			return 1;
		},
		sub {
			my ($body, $header) = @_;
			if($header->{'Status'} == 200){
				$urls{$url} = length $body;
				$sum += $urls{$url};

				my $tree = HTML::TreeBuilder::XPath->new_from_content($body);
				for ($tree->findnodes('//a[@href]')){
					if($_ && $_->attr('href') =~
						m{^(?:$site)?(/[\w/\-_\(\)]*)(?:\?[^"]+)?$}ig){
						# say Dumper($1);
						last if(is_limit);
						get_length_page($1);
					}
				}
			}
			$cv->end;
		};
	}
}

get_length_page("/");
$cv->recv;
# say Dumper(scalar (keys %urls));

$count_top = $count_top < keys %urls ? $count_top : keys %urls;
say "Top-$count_top";
say $site.$_ for ((sort {$urls{$b} <=> $urls{$a}} keys %urls)[0..$count_top-1]);
say "\ntotal: $sum";