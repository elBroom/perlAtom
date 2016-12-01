package Local::Habr;

use strict;
use warnings;

use Local::Habr::Config;

=encoding utf8

=head1 NAME

Local::Habr - abstract format

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub new{
	my ($class) = @_;

	return bless {}, $class;
}

1;
