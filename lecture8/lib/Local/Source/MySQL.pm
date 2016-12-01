package Local::Source::MySQL;
use parent 'Local::Source';

use strict;
use warnings;

use v5.10;
use strict;
use warnings;
use mro 'c3';
use base qw/Class::Singleton/;

use Data::Dumper;
use DBI;

=encoding utf8

=head1 NAME

Local::MySQL - loader

=head1 VERSION

Version 1.00

=head1 DESCRIPTION

Подключение к MySQL

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub _new_instance{
	my ($class) = @_;
	my $self  = bless { }, $class;
	my $conf = $self->_get_config();

	$self->{ connection } = DBI->connect(
		'dbi:mysql:database='.$conf->val('DB','db_name'), $conf->val('DB','db_user'), $conf->val('DB','db_pass'),
		{ RaiseError=>1, mysql_enable_utf8 => 1 }
	) || die "Can't connection to database";

	return $self;
}

1;

