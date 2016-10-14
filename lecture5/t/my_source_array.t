use strict;
use warnings;

use Test::More tests => 10;

use Local::Source::Array;

my $iter_array = Local::Source::Array->new(array=>[
	'{"price": 1}',
	'{"price": 2}',
	'{"price": 3}',
	'{"price": 4}',
	'{"price": 5}',
	'{"price": 6}',
	'{"price": 7}',
	'{"price": 8}',
	'{"price": 9}',
	'{"price": 10}'
]);

is($iter_array->next(), '{"price": 1}', 'my Array source iteration 1');
is($iter_array->next(), '{"price": 2}', 'my Array source iteration 2');
is($iter_array->next(), '{"price": 3}', 'my Array source iteration 3');
is($iter_array->next(), '{"price": 4}', 'my Array source iteration 4');
is($iter_array->next(), '{"price": 5}', 'my Array source iteration 5');
is($iter_array->next(), '{"price": 6}', 'my Array source iteration 6');
is($iter_array->next(), '{"price": 7}', 'my Array source iteration 7');
is($iter_array->next(), '{"price": 8}', 'my Array source iteration 8');
is($iter_array->next(), '{"price": 9}', 'my Array source iteration 9');
is($iter_array->next(), '{"price": 10}', 'my Array source iteration 10');
