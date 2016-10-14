package Local::Source::FileHandler;
use parent 'Local::Source';

use 5.18.2;  # for given/when
use strict;
use warnings;

use Data::Dumper;
use mro 'c3';

=encoding utf8

=head1 NAME

Local::Source::FileHandler - iterate of the file

=head1 VERSION

Version 1.00

=head1 DESCRIPTION

Отдает построчно содержимое файла, дескриптор которого передается в конструктор в параметре `fh`.

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub new{
	my ($class, %params) = @_;
	my $self = bless {}, $class;

	my $fh = $params{fh};
	chomp(my @lines = <$fh>);
	$self->{_arr_rows} = [@lines];

	return $self;
}

1;
