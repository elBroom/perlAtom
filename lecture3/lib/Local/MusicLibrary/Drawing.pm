package Local::MusicLibrary;

use 5.010;  # for given/when
use strict;
use warnings;
no warnings 'experimental';

use List::Util qw(max);
use Data::Dumper;

=encoding utf8

=head1 NAME

Local::MusicLibrary::Drawing

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

our @EXPORT_OK = qw(draw);

sub draw{
	my @data = @{+shift};
	return '' unless @data;

	my @columns;
	given (shift) {
		when(undef)	{@columns = ('band', 'year', 'album', 'track', 'format');}
		when ('')	{return ''}
		default		{@columns = split(',', join(',', $_))}
	}

	# Считаем длину ячейки
	my %col_len = ('band'=>0, 'year'=>0, 'album'=>0, 'track'=>0, 'format'=>0);
	for my $cell (keys %col_len){
		$col_len{$cell} = max map {length($$_{$cell})} @data;
	}

	# Рисуем
	my @res;
	my @dash;
	push(@dash,'-' x ($col_len{$_}+2)) for(@columns);
	push(@res, '/'.join('-', @dash).'\\'); #Верхний разделитель
	for my $row (@data){
		push(@res, '|'.
			join('|', 
				map {sprintf " %*s ", $col_len{$_}, $$row{$_}} 
					@columns).
			'|');
		push(@res, '|'.join('+', @dash).'|');
	}
	$res[-1] = '\\'.join('-', @dash).'/'; #Нижний разделитель

	return join("\n", @res)."\n";
}

1;
