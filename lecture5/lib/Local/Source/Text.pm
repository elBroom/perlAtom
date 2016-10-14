package Local::Source::Text;
use parent 'Local::Source';

use strict;
use warnings;
use mro 'c3';

=encoding utf8

=head1 NAME

Local::Source::Text - iterate of the text

=head1 VERSION

Version 1.00

=head1 DESCRIPTION

Отдает построчно текст, который передается в конструктор в параметре `text`. Разделитель — `\n`, но можно изменить параметром конструктора `delimiter`.

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

sub new{
	my ($class, %params) = @_;
	my $self = bless {}, $class;

	$self->{_delimiter} = "\n";
	$self->{_delimiter} = $params{'delimiter'} if($params{'delimiter'});
	$self->{_arr_rows} = [split("$self->{_delimiter}", $params{'text'})];
	return $self;
}

# sub delimiter{
# 	my ($self, $delimiter) = @_;

# 	$self->{_delimiter} = $delimiter;
# 	$self->{_arr_rows} = [split("$self->{_delimiter}", $params{'text'})];
# }

1;
