package Local::Format::JSON;
use parent 'Local::Format';

use strict;
use warnings;

use mro 'c3';
use JSON::XS;


=encoding utf8

=head1 NAME

Local::JSON - json format

=head1 VERSION

Version 1.00

=head1 DESCRIPTION

Класс, объекты которого отвечают за вывод в формате JSON.

Методы:
* `get()` — возвращает форматированные данные вывода.

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub get{
	my ($self, $data) = @_;

	return JSON::XS->new->utf8->encode($data);
}