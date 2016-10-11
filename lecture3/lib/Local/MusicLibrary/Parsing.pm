package Local::MusicLibrary::Parsing;

use strict;
use warnings;
use Exporter 'import';

=encoding utf8

=head1 NAME

Local::MusicLibrary::Parsing

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

our @EXPORT = qw(parse);

sub parse{
	my @data;
	while (<>){
		m{^\./(?<band>[^/]+)/(?<year>\d+)\s+-\s+(?<album>[^/]+)/(?<track>.+)\.(?<format>\w+)$};
		push(@data, {%+});
	}
	return @data;
}

1;
