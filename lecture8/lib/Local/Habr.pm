package Local::Habr;

use strict;
use warnings;

=encoding utf8

=head1 NAME

Local::Habr - abstract format

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

use Class::XSAccessor {
	accessors => [qw/
		_refresh _site
	/],
};

sub new{
	my ($class, %params) = @_;

	my $self = bless {}, $class;
	$self->_refresh($params{'refresh'});
	$self->_site($params{'site'});

	return $self;
}

1;
