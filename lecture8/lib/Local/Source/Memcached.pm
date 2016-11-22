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

=encoding utf8

=head1 NAME

Local::Memcached - loader

=head1 VERSION

Version 1.00

=head1 DESCRIPTION

Подключение к мемкэшу.

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

my $connect;

sub new{
	my ($class) = @_;
	$connect ||= bless {}, $class;
}

sub _connection_ini{
	my ($self, $conf) = @_;

	return (Cache::Memcached::Fast->new({servers => [
		$conf->val('MEMACHED','mem_host').':'.$conf->val('MEMACHED','mem_port')
	]}) or die "Can't connection to memcached");
}

1;
