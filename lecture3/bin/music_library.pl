#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Long;
use Local::MusicLibrary;

my %filter;
my $sort;
my $columns;
my @data;

GetOptions(
	'band=s' => \$filter{'band'},
	'year=i' => \$filter{'year'},
	'album=s' => \$filter{'album'},
	'track=s' => \$filter{'track'},
	'format=s' => \$filter{'format'},
	'sort=s' => \$sort,
	'columns=s' => \$columns
);

@data = Local::MusicLibrary::parse();
print Local::MusicLibrary::show(\@data, \%filter, $sort, $columns);