=head1 DESCRIPTION

Эта функция должна принять на вход арифметическое выражение,
а на выходе дать ссылку на массив, содержащий обратную польскую нотацию
Один элемент массива - это число или арифметическая операция
В случае ошибки функция должна вызывать die с сообщением об ошибке

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
use FindBin;
require "$FindBin::Bin/../lib/tokenize.pl";

sub rpn {
	my $expr = shift;
	my $source = tokenize($expr);
	my @rpn;

	my @buff;
	my %prior = (
		'(' =>	0,	')' => 0,
		'+' =>	1,	'-' => 1,
		'*' =>	2,	'/' => 2,
		'^' =>	3,
		'U+' =>	4,	'U-' => 4,
	);

	for (@{$source}) {
		given ($_) {
			when (['+','-','*','/','^', 'U+', 'U-']) {
				while( @buff and
					$prior{$_} < 3 ?
					$prior{$_} <= $prior{$buff[-1]}: #left assoc
					$prior{$_} < $prior{$buff[-1]} #right assoc
				){
					push @rpn, (pop @buff);
				}
				push @buff, $_;
			}
			when (/\d/)	{push @rpn, "".$_;}
			when ('(')	{push @buff, $_;}
			when (')')	{
				push @rpn, (pop @buff) while ($buff[-1] ne '(');
				pop @buff;
			}
		}
	}

	push @rpn, (pop @buff) while ($#buff >= 0);
	return \@rpn;
}

1;
