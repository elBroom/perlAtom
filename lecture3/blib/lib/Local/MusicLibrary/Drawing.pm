package Local::MusicLibrary::Drawing;

use 5.010;  # for given/when
use strict;
use warnings;
no warnings 'experimental';
use Exporter 'import';

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

our @EXPORT = qw(draw);

sub draw{
	my @data = @{+shift};
	return '' unless @data;

	my @columns = @{+shift};
	return '' unless @columns;

	# Считаем длину ячейки
	my %col_len;
	for my $cell (@columns){
		$col_len{$cell} = max map {length($_->{$cell})} @data;
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
