package Local::Habr::Config;

use v5.10;
use strict;
use warnings;
use base qw/Class::Singleton/;

=encoding utf8

=head1 NAME

Local::Config - Config

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub site { $_[0]->instance->{site} }
sub is_refresh { $_[0]->instance->{is_refresh} }

1;
