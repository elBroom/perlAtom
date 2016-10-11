#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Long;
use Local::MusicLibrary;
use Data::Dumper;

my %filter;
my $sort;
my @columns;
my @data;

GetOptions(
	'band=s' => \$filter{'band'},
	'year=i' => \$filter{'year'},
	'album=s' => \$filter{'album'},
	'track=s' => \$filter{'track'},
	'format=s' => \$filter{'format'},
	'sort=s' => \$sort,
	'columns=s' => \@columns
);
unless(@columns){
	@columns = ('band', 'year', 'album', 'track', 'format');
}else{
	@columns = grep { length } split /,/, $columns[0];
}

@data = Local::MusicLibrary::parse();
print Local::MusicLibrary::show(\@data, \%filter, $sort, \@columns);