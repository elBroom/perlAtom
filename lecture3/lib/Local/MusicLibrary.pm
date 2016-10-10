package Local::MusicLibrary;

use strict;
use warnings;

use Local::MusicLibrary::Parsing;
use Local::MusicLibrary::Processing;
use Local::MusicLibrary::Drawing;

=encoding utf8

=head1 NAME

Local::MusicLibrary - core music library module

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

our @EXPORT_OK = qw(parse show);

sub show{
	my @data = @{+shift};
	my ($filter, $sort, $columns) = @_;
	@data = filtered(\@data, $filter);
	@data = sorted(\@data, $sort) if $sort;
	return draw(\@data, $columns);
}

1;
