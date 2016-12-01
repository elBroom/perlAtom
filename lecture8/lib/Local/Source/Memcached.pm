package Local::Source::Memcached;
use parent 'Local::Source';

use strict;
use warnings;

use v5.10;
use strict;
use warnings;
use mro 'c3';
use base qw/Class::Singleton/;

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

sub _new_instance{
	my ($class) = @_;
	my $self  = bless { }, $class;
	my $conf = $self->_get_config();

	$self->{ connection } = Cache::Memcached::Fast->new({servers => [
		$conf->val('MEMACHED','mem_host').':'.$conf->val('MEMACHED','mem_port')
	]}) || die "Can't connection to memcached";

	return $self;
}

1;
