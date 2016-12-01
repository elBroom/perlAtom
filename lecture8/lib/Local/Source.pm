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

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub connection { $_[0]->instance->{connection} }

sub _get_config{
	my ($self) = @_;

	my $conf_file = file($0)->absolute->dir.'/config.ini';
	my $conf = Config::IniFiles->new(-file=>$conf_file);
	die "Can't read config ".$conf_file unless($conf);
	return $conf;
}

1;
