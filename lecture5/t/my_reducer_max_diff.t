use strict;
use warnings;

use Test::More tests => 6;

use Local::Reducer::MaxDiff;
use Local::Source::Text;
use Local::Row::Simple;

my $my_diff_reducer = Local::Reducer::MaxDiff->new(
    top => 'received',
    bottom => 'sended',
    source => Local::Source::Text->new(text =>"sended:1024,received:2048\nsended:2048,received:10240\nsended:2048,received:10280"),
    row_class => 'Local::Row::Simple',
    initial_value => 0,
);

my $my_diff_result;

$my_diff_result = $my_diff_reducer->reduce_n(2);
is($my_diff_result, 8192, 'my diff reduced 8192 n=2');
is($my_diff_reducer->reduced, 8192, 'my diff reducer saved n=2');

$my_diff_result = $my_diff_reducer->reduce_all();
is($my_diff_result, 8232, 'my diff reduced all');
is($my_diff_reducer->reduced, 8232, 'my diff reducer saved at the end');

$my_diff_result = $my_diff_reducer->reduce_n(1);
is($my_diff_result, 8232, 'my diff reduced 8232 n=1');
is($my_diff_reducer->reduced, 8232, 'my diff reducer saved n=1');
