package Local::Reducer::MaxDiff;
use parent 'Local::Reducer';

use strict;
use warnings;
use mro 'c3';

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

use Class::XSAccessor {
	accessors => [qw/
		_top _bottom
	/],
};

sub new{
	my ($class, %params) = @_;
	my $self = $class->next::method(%params);

	$self->_top($params{'top'});
	$self->_bottom($params{'bottom'});
	return $self;
}

sub _reduce_next{
	my $self = shift;

	my $str = $self->_source()->next();
	if($str){
		my $row = $self->_row_class()->new(str=>$str);
		my $val = $row->get($self->_top()) - $row->get($self->_bottom());
		$self->_reduce_result($val) if (!defined $self->_reduce_result() or $val > $self->_reduce_result());
		return $self->_reduce_result();
	}
	return undef;
}

1;
