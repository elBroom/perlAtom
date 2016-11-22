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

sub connection{
	my ($self) = @_;

	unless($self->{_connection}){
		my $conf_file = file($0)->absolute->dir.'/config.ini';
		my $conf = Config::IniFiles->new(-file=>$conf_file);
		die "Can't read config ".$conf_file unless($conf);

		$self->{_connection} = $self->_connection_ini($conf);
	}

	$self->{_connection};
}

sub _connection_ini{
	undef;
}

1;
