=head1 DESCRIPTION

Эта функция должна принять на вход ссылку на массив, который представляет из себя обратную польскую нотацию,
а на выходе вернуть вычисленное выражение

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

sub evaluate {
	my $rpn = shift;
	my @data = @{$rpn};
	my @digits;

	for (@data) {
		if($_ =~ /\d/){ #is_digit
			push @digits, $_;
		} else{
			my $arg1 = pop @digits;
			given ($_) {
				when ('U+')	{push @digits, $arg1}
				when ('U-')	{push @digits, -1 * $arg1}
				when ('+')	{push @digits, (pop @digits) + $arg1;}
				when ('-')	{push @digits, (pop @digits) - $arg1;}
				when ('*')	{push @digits, (pop @digits) * $arg1;}
				when ('/')	{push @digits, (pop @digits) / $arg1;}
				when ('^')	{push @digits, (pop @digits) ** $arg1;}
			}
		}
	}
	return (pop @digits);
}

1;
