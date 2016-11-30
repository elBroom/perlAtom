package Local::Habr::Config;

use v5.10;
use strict;
use warnings;
no warnings 'experimental';

=encoding utf8

=head1 NAME

Local::Config - Config

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

use Class::XSAccessor {
	accessors => [qw/
		is_refresh site
	/],
};

my $connect;

sub new{
	my ($class) = @_;
	$connect ||= bless {}, $class;
}

1;
