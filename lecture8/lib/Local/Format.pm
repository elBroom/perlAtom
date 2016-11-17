package Local::Format;

use strict;
use warnings;

=encoding utf8

=head1 NAME

Local::Format - abstract format

=head1 VERSION

Version 1.00

=head1 DESCRIPTION

Класс, объекты которого отвечают за формат вывода.

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub new{
	my ($class) = @_;

	return bless {}, $class;
}

sub get{
	return undef;
}

1;
