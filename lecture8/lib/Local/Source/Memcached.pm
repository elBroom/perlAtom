package Local::Source::Memcached;
use parent 'Local::Source';

use strict;
use warnings;

use v5.10;
use strict;
use warnings;
use mro 'c3';

use Data::Dumper;
use Cache::Memcached::Fast;
use JSON::XS;

=encoding utf8

=head1 NAME

Local::Memcached - loader

=head1 VERSION

Version 1.00

=head1 DESCRIPTION

Класс, объекты которого отвечают за загрузку данных с мемкэша.

Параметры конструктора:
* `site` — Сайт источника данных.

Методы:
* `connection()` — подключение к мемкэшу.
* `get_user()` — возвращает данные пользователя из мемкэша.
* `get_self_commentors()` — возвращает данные по всем известным пользователям, которые хоть раз комментировали свои посты из мемкэша.
* `set_post()` — добавляет данные пользователя в мемкэш.
* `set_self_commentors()` — добавляет данные по всем известным пользователям, которые хоть раз комментировали свои посты из мемкэша.
* `del_self_commentors()` — удаляет данные по всем известным пользователям, которые хоть раз комментировали свои посты из мемкэша.

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

use Class::XSAccessor {
	accessors => [qw/
		_connection
	/],
};

sub get_user{
	my ($self, $name) = @_;
	my $data = $self->connection->get($self->_site.'_user_'.$name);

	return JSON::XS->new->utf8->decode($data) if($data);
	return undef;

}

sub get_self_commentors{
	my ($self) = @_;
	my $data = $self->connection->get($self->_site.'_self_commentors');

	return JSON::XS->new->utf8->decode($data) if($data);
	return undef;
}

sub set_user{
	my ($self, $data) = @_;

	return $self->connection->set(
		$self->_site.'_user_'.$data->{'username'},
		JSON::XS->new->utf8->encode($data),
		60
	) if ($data->{'username'});
}

sub set_self_commentors{
	my ($self, $data) = @_;

	return $self->connection->set(
		$self->_site.'_self_commentors',
		JSON::XS->new->utf8->encode($data),
		60
	) if ($data);
}

sub del_self_commentors{
	my ($self) = @_;
	return $self->connection->delete($self->_site.'_self_commentors');
}

sub _connection_ini{
	my ($self, $conf) = @_;

	return Cache::Memcached::Fast->new({servers => [
		$conf->val('MEMACHED','mem_host').':'.$conf->val('MEMACHED','mem_port')
	]}) or die "Can't connection to memcached"
}

1;
