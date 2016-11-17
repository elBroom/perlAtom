package Local::Format::CSV;
use parent 'Local::Format';

use strict;
use warnings;

use mro 'c3';
use Scalar::Util qw(reftype);


=encoding utf8

=head1 NAME

Local::CSV - csv format

=head1 VERSION

Version 1.00

=head1 DESCRIPTION

Класс, объекты которого отвечают за вывод в формате CSV.

Методы:
* `get()` — возвращает форматированные данные вывода.

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub get{
	my ($self, $data) = @_;
	my $separator = "\t";
	my $str = '';

	if (reftype $data eq 'ARRAY'){
		my @data = @{$data};
		my @keys = keys %{$data[0]};
		$str .= (join $separator, @keys)."\n";
		for my $row(@data){
			my @vals;
			map { push(@vals, $row->{$_}) } @keys;
			$str .= (join $separator, @vals)."\n";
		}

	}elsif(reftype $data eq'HASH'){
		my %data = %{$data};
		$str .= (join $separator, keys %data)."\n";
		$str .= (join $separator, values %data)."\n";
	}
	return $str;
}