package Local::Format;

use v5.10;
use strict;
use warnings;
no warnings 'experimental';
use Scalar::Util qw(reftype);

use Data::Dumper;
use JSON::XS;

=encoding utf8

=head1 NAME

Local::Format - format

=head1 VERSION

Version 1.00

=head1 DESCRIPTION

Класс, объекты которого отвечают за формат вывода. Формат вывода может быть разным, для каждого нужен свой метод.

Параметры конструктора:
* `type` — тип вывода.

Методы:
* `get()` — возвращает форматированные данные вывода.

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

use Class::XSAccessor {
	accessors => [qw/
		_type
	/],
};

sub new{
	my ($class, $type) = @_;
	my $self = bless {}, $class;

	$self->_type($type);
	return $self;
}

sub get{
	my ($self, $data) = @_;
	given($self->_type){
		when('json'){
			return $self->_json($data);
		}
		when('csv'){
			return $self->_csv($data);
		}
		default{
			die 'Invalid format';
		}
	}
}

sub _json{
	my ($self, $data) = @_;

	return JSON::XS->new->utf8->encode($data);
}

sub _csv{
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

1;
