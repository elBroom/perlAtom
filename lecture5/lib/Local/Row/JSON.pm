package Local::Row::JSON;
use parent 'Local::Row';

use strict;
use warnings;
use mro 'c3';
use JSON::XS;

=encoding utf8

=head1 NAME

Local::Row::JSON - JSON parsing

=head1 VERSION

Version 1.00

=head1 DESCRIPTION

Kаждая строка — JSON.

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub _parsing{
	my ($self, $str) = @_;

	return JSON::XS->new->utf8->decode($str);
}

1;
