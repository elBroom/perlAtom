package Local::Habr::User;
use parent 'Local::Habr';

use v5.10;
use strict;
use warnings;
no warnings 'experimental';

use Data::Dumper;
use JSON::XS;

use Local::Source::Loader;
use Local::Source::MySQL;
use Local::Source::Memcached;

use Local::Habr::Config;

=encoding utf8

=head1 NAME

Local::User - user

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub get_user{
	my ($self, $name) = @_;
	my $result;

	$result = $self->_memcached_get_user($name) unless(Local::Habr::Config->is_refresh);
	unless($result){
		$result = $self->_mysql_get_user($name) unless(Local::Habr::Config->is_refresh);
		unless($result){
			$result = $self->_loader_get_user($name);
			die "User not found $name" unless($result);
			$self->_mysql_set_user($result);
		}
		$self->_memcached_set_user($result);
	}
	return $result;
}

sub _loader_get_user{
	my ($self, $name) = @_;
	my %result;
	
	my $tree = Local::Source::Loader->connection->get_tree(Local::Habr::Config->site, 'users', $name);
	return undef unless($tree);

	$result{'username'} = $tree->findvalue('//a[@class = "author-info__nickname"]');
	$result{'username'} =~ s/^.{1}//s;
	$result{'karma'} = $tree->findvalue('//div[@class = "voting-wjt__counter-score js-karma_num"]');
	$result{'karma'} =~ s/,/./s;
	$result{'rating'} = $tree->findvalue('//div[@class = "statistic__value statistic__value_magenta"]');
	$result{'rating'} =~ s/,/./s;

	return \%result;
}

sub _mysql_get_user{
	my ($self, $name) = @_;

	return Local::Source::MySQL->connection->selectrow_hashref(
		'SELECT uname as username, karma, rating FROM user WHERE uname = ?',
		{}, $name
	) if ($name);

	return undef;
}

sub _mysql_set_user{
	my ($self, $data) = @_;

	return Local::Source::MySQL->connection->prepare(
		'INSERT INTO user (uname, karma, rating, last_update) VALUES (?,?,?,NOW())
		ON DUPLICATE KEY UPDATE karma=?, rating=?, last_update=NOW()'
	)->execute(
		$data->{'username'}, $data->{'karma'}, $data->{'rating'},
		$data->{'karma'}, $data->{'rating'}
	) if($data->{'username'});
}

sub _memcached_get_user{
	my ($self, $name) = @_;
	my $data = Local::Source::Memcached->connection->get(Local::Habr::Config->site.'_user_'.$name);

	return JSON::XS->new->utf8->decode($data) if($data);
	return undef;
}

sub _memcached_set_user{
	my ($self, $data) = @_;

	return Local::Source::Memcached->connection->set(
		Local::Habr::Config->site.'_user_'.$data->{'username'},
		JSON::XS->new->utf8->encode($data),
		60
	) if ($data->{'username'});
}

1;
