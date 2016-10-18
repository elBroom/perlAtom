package Local::Reducer::MinMaxAvg;
use parent 'Local::Reducer';

use strict;
use warnings;
use mro 'c3';

=encoding utf8

=head1 NAME

Local::Reducer::MinMaxAvg - 

=head1 VERSION

Version 1.00

=head1 DESCRIPTION

Считает минимум, максимум и среднее по полю, указанному в параметре `field`. Результат (`reduced`) отдается в виде объекта с методами `get_max`, `get_min`, `get_avg`.

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

use Class::XSAccessor {
	accessors => [qw/
		_field
	/],
};

sub new{
	my ($class, %params) = @_;
	my $self = $class->next::method(%params);

	$self->_field($params{'field'});

	my %reduce_result;
	$reduce_result{"max"} = $params{'initial_value'};
	$reduce_result{"min"} = $params{'initial_value'};
	$reduce_result{"sum"} = $params{'initial_value'};
	$reduce_result{"count"} = 0;
	$self->_reduce_result(\%reduce_result);

	return $self;
}

sub _reduce_next{
	my $self = shift;

	my $str = $self->_source()->next();
	if($str){
		my $val = $self->_row_class()->new(str=>$str)->get($self->_field());

		my %reduce_result = %{$self->_reduce_result()};
		$reduce_result{"max"} = $val if (!defined $reduce_result{"max"} or $val > $reduce_result{"max"});
		$reduce_result{"min"} = $val if (!defined $reduce_result{"min"} or $val < $reduce_result{"min"});
		$reduce_result{"sum"} += $val;
		$reduce_result{"count"} += 1;
		$self->_reduce_result(\%reduce_result);

		return %reduce_result;
	}
	return undef;
}


sub get_max{
	my $self = shift;

	return $self->_reduce_result()->{"max"};
}

sub get_min{
	my $self = shift;

	return $self->_reduce_result()->{"min"};
}

sub get_avg{
	my $self = shift;

	return undef unless ($self->_reduce_result()->{"count"});
	return $self->_reduce_result()->{"sum"} / $self->_reduce_result()->{"count"};
}

1;
