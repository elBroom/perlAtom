package Local::Source::FileHandler;
use parent 'Local::Source';

use strict;
use warnings;
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

use Class::XSAccessor {
	accessors => [qw/
		_fh
	/],
};

sub new{
	my ($class, %params) = @_;
	my $self = bless {}, $class;

	$self->_fh($params{fh});
	return $self;
}

sub next{
	my $self = shift;

	my $fh = $self->_fh();
	my $line = <$fh>;
	if($line){
		chomp($line);
		return $line;
	}
	return undef;
}

1;
