package Local::Source;

use strict;
use warnings;

use Path::Class qw( file );
use Config::IniFiles;

=encoding utf8

=head1 NAME

Local::Source - base abstract source

=head1 VERSION

Version 1.00

=head1 DESCRIPTION

Класс, объекты которого отвечают за источник данных. Источник может быть разным, для каждого нужен свой подкласс `Source`.

Параметры конструктора:
* `site` — Сайт источника данных.

Методы:
* `connection()` — подключение к источнику.
* `get_user()` — возвращает данные пользователя из источника.
* `get_post()` — возвращает данные поста из источника.
* `set_user()` — добавляет данные пользователя в источник.
* `set_post()` — добавляет  данные поста в источник.
=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

use Class::XSAccessor {
	accessors => [qw/
		_site _connection
	/],
};

sub new{
	my ($class, %params) = @_;
	my $self = bless {}, $class;

	$self->_site($params{'site'});
	return $self;
}

sub get_user{
	undef;
}

sub get_post{
	undef;
}

sub set_user{
	undef;
}

sub set_post{
	undef;
}

sub connection{
	my ($self) = @_;

	unless($self->_connection){
		my $conf_file = file($0)->absolute->dir.'/config.ini';
		my $conf = Config::IniFiles->new(-file=>$conf_file);
		die "Can't read config ".$conf_file unless($conf);

		$self->_connection($self->_connection_ini($conf));
	}

	$self->_connection;
}

sub _connection_ini{
	undef;
}

1;
