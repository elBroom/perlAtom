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

use Class::XSAccessor {
	accessors => [qw/
		_field
	/],
};

sub new{
	my ($class, %params) = @_;
	my $self = $class->next::method(%params);

	$self->_field($params{'field'});
	return $self;
}

sub _reduce_next{
	my $self = shift;

	my $str = $self->_source()->next();
	if($str){
		my $val = $self->_row_class()->new(str=>$str)->get($self->_field());
		$self->_reduce_result($self->_reduce_result() + $val);
		return $self->_reduce_result();
	}
	return undef;
}

1;
