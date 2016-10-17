package Local::Row;

use strict;
use warnings;
use Scalar::Util qw(reftype);

=encoding utf8

=head1 NAME

Local::Row - base abstract row

=head1 VERSION

Version 1.00

=head1 DESCRIPTION

Класс, объекты которого отвечают за парсинг строк из источника. Отвечает за парсинг данных: формат логов может быть разным, для каждого нужен свой подкласс `Row`.

Параметры конструктора:
* `str` — строка из источника.

Методы:
* `get($name, $default)` — возвращает значение поля `$name` строки лога или `$default`, если таковое отсутствует.

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

use Class::XSAccessor {
	accessors => [qw/
		_cache
	/],
};

sub new{
	my ($class, %params) = @_;
	my $self = bless {}, $class;

	$self->_cache($self->_parsing($params{str}));
	return $self;
}

sub get{
	my ($self, $name, $default) = @_;
	if($self->_cache() and $self->_cache()->{$name} and
		!reftype($self->_cache()->{$name})){ #не ссылка
		return $self->_cache()->{$name};
	}
	return $default;
}

sub _parsing{
	undef;
}

1;
