package Local::Reducer::MinMaxAvg;
use parent 'Local::Reducer';

use strict;
use warnings;
use mro 'c3';
use List::Util qw(max min sum);

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

sub new{
	my ($class, %params) = @_;
	my $self = $class->next::method(%params);

	$self->{_field} = $params{'field'};
	$self->{_acc}{"max"} = $params{'initial_value'};
	$self->{_acc}{"min"} = $params{'initial_value'};
	return $self;
}

sub _reduce{
	my $self = shift;

	my $str = $self->{_source}->next();
	if($str){
		my $val = $self->{_row_class}->new(str=>$str)->get($self->{_field});
		$self->{_acc}{"max"} = max($self->{_acc}{"max"}, $val);
		$self->{_acc}{"min"} = min($self->{_acc}{"min"}, $val);
		return $self->{_acc};
	}
	return undef;
}


sub get_max{
	my $self = shift;

	return $self->{_acc}{"max"};
}

sub get_min{
	my $self = shift;

	return $self->{_acc}{"min"};
}

1;
