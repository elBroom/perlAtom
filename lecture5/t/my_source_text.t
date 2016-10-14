use strict;
use warnings;

use Test::More tests => 10;

use Local::Source::Text;

my $iter_text = Local::Source::Text->new(delimiter=>';', text=>
	'{"price": 1};{"price": 2};{"price": 3};{"price": 4};{"price": 5};{"price": 6};{"price": 7};{"price": 8};{"price": 9};{"price": 10}'
);

is($iter_text->next(), '{"price": 1}', 'my Text source iteration 1');
is($iter_text->next(), '{"price": 2}', 'my Text source iteration 2');
is($iter_text->next(), '{"price": 3}', 'my Text source iteration 3');
is($iter_text->next(), '{"price": 4}', 'my Text source iteration 4');
is($iter_text->next(), '{"price": 5}', 'my Text source iteration 5');
is($iter_text->next(), '{"price": 6}', 'my Text source iteration 6');
is($iter_text->next(), '{"price": 7}', 'my Text source iteration 7');
is($iter_text->next(), '{"price": 8}', 'my Text source iteration 8');
is($iter_text->next(), '{"price": 9}', 'my Text source iteration 9');
is($iter_text->next(), '{"price": 10}', 'my Text source iteration 10');
