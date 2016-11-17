package Local::FormatFabric;

use v5.10;
use strict;
use warnings;
no warnings 'experimental';

use Local::Format::JSON;
use Local::Format::CSV;

=encoding utf8

=head1 NAME

Local::Format - format

=head1 VERSION

Version 1.00

=head1 DESCRIPTION

Фабричный класс, объекты которого отвечают за формат вывода.

Параметры конструктора:
* `type` — тип вывода.

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub new{
	my ($class, $type) = @_;

	given($type){
		when('json'){
			return Local::Format::JSON->new;
		}
		when('csv'){
			return Local::Format::CSV->new;
		}
		default{
			die 'Invalid format';
		}
	}
}

1;
