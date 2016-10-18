package Local::Reducer;

use strict;
use warnings;

=encoding utf8

=head1 NAME

Local::Reducer - base abstract reducer

=head1 VERSION

Version 1.00

=head1 DESCRIPTION

Отвечает за непосредственно схлопывания.

Параметры конструктора:
* `source` — объект, выдающий строки из лога;
* `row_class` — имя класса, с помощью которого создаются объекты из каждой строки логов;
* `initial_value` — инициализационое значение для операции схлопывания.

Методы:
* `reduce_n($n)` — схлопнуть очередные `$n` строк, вернуть промежуточный результат.
* `reduce_all()` — схлопнуть всё, вернуть результат.
* `reduced` — промежуточный результат.

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

use Class::XSAccessor {
	accessors => [qw/
		_source _row_class _reduce_result
	/],
};

sub new{
	my ($class, %params) = @_;
	my $self = bless {}, $class;

	$self->_source($params{'source'});
	$self->_row_class($params{'row_class'});
	$self->_reduce_result($params{'initial_value'});
	return $self;
}

sub reduce_n{
	my ($self, $n) = @_;

	while ($n > 0 and defined $self->_reduce_next()){
		$n--;
	}
	return $self->reduced();
}

sub reduce_all{
	my $self = shift;

	while (defined $self->_reduce_next()){};
	return $self->reduced();
}

sub reduced{
	my $self = shift;

	return $self->_reduce_result();
}

sub _reduce_next{
	return undef;
}

1;
