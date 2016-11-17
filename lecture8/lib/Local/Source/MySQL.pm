package Local::Source::MySQL;
use parent 'Local::Source';

use strict;
use warnings;

use v5.10;
use strict;
use warnings;
use mro 'c3';

use Data::Dumper;
use DBI;

=encoding utf8

=head1 NAME

Local::MySQL - loader

=head1 VERSION

Version 1.00

=head1 DESCRIPTION

Класс, объекты которого отвечают за загрузку данных с базы.

Параметры конструктора:
* `site` — Сайт источника данных.

Методы:
* `connection()` — подключение к базе.
* `get_user()` — возвращает данные пользователя из базы.
* `get_post()` — возвращает данные поста из базы.
* `get_commenters()` — возвращает данные комментаторов из базы.
* `get_self_commentors()` — возвращает данные по всем известным пользователям, которые хоть раз комментировали свои посты из базы.
* `get_desert_posts()` — возвращает данные по всем известным постам, которые комментировало меньше XXX различных пользователей из базы.
* `set_user()` — добавляет данные пользователя в базу.
* `set_post()` — добавляет данные поста в базу.
* `set_commenter()` — добавляет данные комментаторов в базу.

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

	return $self->connection->selectrow_hashref(
		'SELECT uname as username, karma, rating FROM user WHERE uname = ?',
		{}, $name
	) if ($name);

	return undef;
}

sub get_post{
	my ($self, $id) = @_;

	return $self->connection->selectrow_hashref(
		'SELECT author, theme, rating, count_view, count_star FROM post WHERE id_post = ?',
		{}, $id
	) if ($id);

	return undef;
}

sub get_commenters{
	my ($self, $id) = @_;

	return $self->connection->selectall_arrayref(
		'SELECT uname as username, karma, rating FROM user
		JOIN commenter USING(id_user) WHERE id_post = ?',
		{ Slice => {} }, $id
	) if ($id);

	return undef;
}

sub get_self_commentors{
	my ($self) = @_;
	return $self->connection->selectall_arrayref(
		'SELECT uname as username, karma, user.rating FROM commenter 
			JOIN user USING(id_user)
			JOIN post USING(id_post)
			WHERE author = uname',
		{ Slice => {} }
	);
}

sub get_desert_posts{
	my ($self, $n) = @_;

	return $self->connection->selectall_arrayref(
		'SELECT author, theme, post.rating, count_view, count_star FROM commenter 
			JOIN user USING(id_user)
			JOIN post USING(id_post)
			GROUP BY id_post
			HAVING COUNT(*) < ?',
		{ Slice => {} }, $n
	) if ($n);

	return undef;
}

sub set_user{
	my ($self, $data) = @_;

	return $self->connection->prepare(
		'INSERT INTO user (uname, karma, rating, last_update) VALUES (?,?,?,NOW())
		ON DUPLICATE KEY UPDATE karma=?, rating=?, last_update=NOW()'
	)->execute(
		$data->{'username'}, $data->{'karma'}, $data->{'rating'},
		$data->{'karma'}, $data->{'rating'}
	) if($data->{'username'});
}

sub set_post{
	my ($self, $data) = @_;

	return $self->connection->prepare(
		'INSERT INTO post (id_post, author, theme, rating, count_view, count_star, last_update) VALUES (?,?,?,?,?,?,NOW())
		ON DUPLICATE KEY UPDATE author=?, theme=?, rating=?, count_view=?, count_star=?, last_update=NOW()'
	)->execute(
		$data->{'id'}, $data->{'author'}, $data->{'theme'}, $data->{'rating'}, $data->{'count_view'}, $data->{'count_star'},
		$data->{'author'}, $data->{'theme'}, $data->{'rating'}, $data->{'count_view'}, $data->{'count_star'}
	) if($data->{'id'});
}

sub set_commenter{
	my ($self, $post, $user) = @_;

	return $self->connection->prepare(
		'INSERT IGNORE INTO commenter (id_post, id_user) VALUES (?, (SELECT id_user FROM user WHERE uname=?))'
	)->execute(
		$post->{'id'}, $user->{'username'}
	) if($post->{'id'} and $user->{'username'});
}

sub _connection_ini{
	my ($self, $conf) = @_;

	return DBI->connect(
		'dbi:mysql:database='.$conf->val('DB','db_name'), $conf->val('DB','db_user'), $conf->val('DB','db_pass'),
		{ RaiseError=>1, mysql_enable_utf8 => 1 }
	) or die "Can't connection to database" ;
}

1;

