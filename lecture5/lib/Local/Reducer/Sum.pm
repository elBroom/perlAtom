package Local::Reducer::Sum;
use parent 'Local::Reducer';

use strict;
use warnings;
use mro 'c3';

=encoding utf8

=head1 NAME

Local::Reducer::Sum - 

=head1 VERSION

Version 1.00

=head1 DESCRIPTION

Суммирует значение поля, указанного в параметре `field` конструктора, каждой строки лога.

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub new{
	my ($class, %params) = @_;
	my $self = $class->next::method(%params);

	$self->{_field} = $params{'field'};
	$self->{_acc} = $params{'initial_value'};
	return $self;
}

sub _reduce{
	my $self = shift;

	my $str = $self->{_source}->next();
	if($str){
		my $val = $self->{_row_class}->new(str=>$str)->get($self->{_field});
		$self->{_acc} += $val;
		return $self->{_acc};
	}
	return undef;
}

1;
