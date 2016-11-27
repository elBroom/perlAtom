#!/usr/bin/env perl

use v5.10;
use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;
use utf8;
# binmode(STDOUT,':utf8');

use Local::HabrFacade;

my $command = $ARGV[0];
my $format;
my $refresh;
my $site;
my %params;
my $ids;

GetOptions(
	'name=s' => \$params{'name'},
	'post=i' => \$params{'post'},
	'id=s' => \$params{'id'},
	'n=i' => \$params{'n'},
	'refresh' => \$refresh,
	'format=s' => \$format,
	'site=s' => \$site,
);

my $habr = Local::HabrFacade->new(
	'command' => $command,
	'params' => \%params,
	'refresh' => $refresh,
	'format' => $format,
	'site' => $site,
	);

say $habr->get();