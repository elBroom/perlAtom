package Local::Source::Array;
use parent 'Local::Source';

use strict;
use warnings;
use mro 'c3';

=encoding utf8

=head1 NAME

Local::Source::Array - iterate over the array

=head1 VERSION

Version 1.00

=head1 DESCRIPTION

Отдает поэлементно массив, который передается в конструктор в параметре `array`.

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub new{
	my ($class, %params) = @_;
	my $self = bless {}, $class;

	$self->_arr_rows($params{'array'});
	return $self;
}

1;
