use strict;
use warnings;

use Test::More tests => 10;

use Local::Reducer::Sum;
use Local::Source::FileHandler;
use Local::Row::JSON;

my $my_sum_file = "in";
open my $my_sum_fh, '<:raw', $my_sum_file or die "Can't open file `$my_sum_file': $!\n";

my $my_sum_reducer = Local::Reducer::Sum->new(
    field => 'price',
    source => Local::Source::FileHandler->new(fh=>$my_sum_fh),
    row_class => 'Local::Row::JSON',
    initial_value => 0,
);

my $my_sum_result;

$my_sum_result = $my_sum_reducer->reduce_n(3);
is($my_sum_result, 6, 'my sum reduced 6');
is($my_sum_reducer->reduced, 6, 'my sum reducer saved n=3');

$my_sum_result = $my_sum_reducer->reduce_n(1);
is($my_sum_result, 10, 'my sum reduced 10');
is($my_sum_reducer->reduced, 10, 'my sum reducer saved n=1');

$my_sum_result = $my_sum_reducer->reduce_n(4);
is($my_sum_result, 36, 'my sum reduced 36');
is($my_sum_reducer->reduced, 36, 'my sum reducer saved n=4');

$my_sum_result = $my_sum_reducer->reduce_all();
is($my_sum_result, 55, 'my sum reduced all');
is($my_sum_reducer->reduced, 55, 'my sum reducer saved at the end');

$my_sum_result = $my_sum_reducer->reduce_n(2);
is($my_sum_result, 55, 'my sum reduced 55');
is($my_sum_reducer->reduced, 55, 'my sum reducer saved n=2');

close $my_sum_fh;
