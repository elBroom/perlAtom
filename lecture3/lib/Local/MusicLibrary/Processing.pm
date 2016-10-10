package Local::MusicLibrary;

use strict;
use warnings;
use Data::Dumper;

=encoding utf8

=head1 NAME

Local::MusicLibrary::Processing

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

our @EXPORT_OK = qw(filtered sorted);

sub filtered{
	my @data = @{+shift};
	my %filter = %{+shift};
	for my $cell (keys %filter){
		if($cell eq 'year'){
			@data = grep {$filter{$cell} == $$_{$cell}} @data if($filter{$cell});
		} else{
			@data = grep {$filter{$cell} eq $$_{$cell}} @data if($filter{$cell});
		}
	}
	return @data;
}

sub sorted{
	my @data = @{+shift};
	my $sort = shift;
	if($sort eq 'year'){
		@data = sort {$$a{$sort} <=> $$b{$sort}} @data;
	} else{
		@data = sort {lc($$a{$sort}) cmp lc($$b{$sort})} @data;
	}
	return @data;
}

1;
