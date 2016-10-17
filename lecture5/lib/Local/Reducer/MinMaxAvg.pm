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

	my %acc;
	$acc{"max"} = $params{'initial_value'};
	$acc{"min"} = $params{'initial_value'};
	$acc{"sum"} = $params{'initial_value'};
	$acc{"count"} = 0;
	$self->_acc(\%acc);

	return $self;
}

sub _reduce{
	my $self = shift;

	my $str = $self->_source()->next();
	if($str){
		my $val = $self->_row_class()->new(str=>$str)->get($self->_field());

		my %acc = %{$self->_acc()};
		$acc{"max"} = $val if (!defined $acc{"max"} or $val > $acc{"max"});
		$acc{"min"} = $val if (!defined $acc{"min"} or $val < $acc{"min"});
		$acc{"sum"} += $val;
		$acc{"count"} += 1;
		$self->_acc(\%acc);

		return %acc;
	}
	return undef;
}


sub get_max{
	my $self = shift;

	return $self->_acc()->{"max"};
}

sub get_min{
	my $self = shift;

	return $self->_acc()->{"min"};
}

sub get_avg{
	my $self = shift;

	return undef unless ($self->_acc()->{"count"});
	return $self->_acc()->{"sum"} / $self->_acc()->{"count"};
}

1;
