=head1 DESCRIPTION

Эта функция должна принять на вход арифметическое выражение,
а на выходе дать ссылку на массив, состоящий из отдельных токенов.
Токен - это отдельная логическая часть выражения: число, скобка или арифметическая операция
В случае ошибки в выражении функция должна вызывать die с сообщением об ошибке

Знаки '-' и '+' в первой позиции, или после другой арифметической операции стоит воспринимать
как унарные и можно записывать как "U-" и "U+"

Стоит заметить, что после унарного оператора нельзя использовать бинарные операторы
Например последовательность 1 + - / 2 невалидна. Бинарный оператор / идёт после использования унарного "-"

=cut

use 5.010;
use strict;
use warnings;
use diagnostics;
BEGIN{
	if ($] < 5.018) {
		package experimental;
		use warnings::register;
	}
}
no warnings 'experimental';

sub tokenize($) {
	chomp(my $expr = shift);
	$expr =~ s/\s*//g;
	my @res = split m{((?<!e)[-+]|[*/^()])}, $expr;

	my $f_valid = 0;
	my $brackets = 0;

	for (@res){
		if($f_valid == 0 and $_ =~ /^[+-]$/){ #uno
			$_ = "U".$_;
		} else{
			given ($_) {
				when (/^$/)	{next;} #empty
				when ('(')	{$brackets++;}
				when (')')	{$brackets--;}
				when (['+','-','*','/','^']){$f_valid--;}
				when (/^\d*\.?\d*(e[-+]?)?\d+$/){ #digit
					$f_valid++;
					$_ += 0;
				}
				default{ die 'Error'; }
			}
		}
	}
	continue{
		die 'Error' if $brackets < 0;
	}
	die 'Error' if $f_valid != 1 or $brackets != 0;
	@res = grep(!/^$/, @res);
	return \@res;
}

1;
