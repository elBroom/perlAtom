package Local::Row::Simple;
use parent 'Local::Row';

use strict;
use warnings;
use mro 'c3';

=encoding utf8

=head1 NAME

Local::Row::Simple - string parsing

=head1 VERSION

Version 1.00

=head1 DESCRIPTION

Kаждая строка — набор пар `ключ:значение`, соединенных запятой. В ключах и значениях не может быть двоеточий и запятых.

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub _parsing{
	my ($self, $str) = @_;

	my %cache;
	for(split(/,/, $str)){
		my @buf = split(/:/, $_);
		$cache{$buf[0]} = $buf[1];
	}
	return \%cache;
}

1;
