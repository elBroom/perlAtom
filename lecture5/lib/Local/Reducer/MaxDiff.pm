package Local::Reducer::MaxDiff;
use parent 'Local::Reducer';

use strict;
use warnings;
use mro 'c3';
use List::Util qw(max);

=encoding utf8

=head1 NAME

Local::Reducer::MaxDiff - 

=head1 VERSION

Version 1.00

=head1 DESCRIPTION

Выясняет максимальную разницу между полями, указанными в параметрах `top` и `bottom` конструктора, среди всех строк лога.

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub new{
	my ($class, %params) = @_;
	my $self = $class->next::method(%params);

	$self->{_top} = $params{'top'};
	$self->{_bottom} = $params{'bottom'};
	$self->{_acc} = $params{'initial_value'};
	return $self;
}

sub _reduce{
	my $self = shift;

	my $str = $self->{_source}->next();
	if($str){
		my $row = $self->{_row_class}->new(str=>$str);
		my $val = abs($row->get($self->{_top}) - $row->get($self->{_bottom}));
		$self->{_acc} = max($self->{_acc}, $val);
		return $self->{_acc};
	}
	return undef;
}

1;