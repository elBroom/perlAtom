package Local::Source;

use strict;
use warnings;

=encoding utf8

=head1 NAME

Local::Source - base abstract source

=head1 VERSION

Version 1.00

=head1 DESCRIPTION

Класс, объекты которого отвечают за подачу данных в `Reducer`. Отвечает за получение данных, но не за их парсинг.

Методы:
* `next` — возвращает очередную строку или `undef`, если лог исчерпан.

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub new{
	my ($class, %params) = @_;
	my $self = bless {}, $class;
	$self->{_arr_rows} = [];
	return $self;
}

sub next{
	my $self = shift;

	return shift $self->{_arr_rows};
}

1;
