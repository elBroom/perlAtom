use strict;
use warnings;

use Test::More tests => 15;

use Local::Reducer::MinMaxAvg;
use Local::Source::FileHandler;
use Local::Row::JSON;

my $my_min_max_avg_file = "in";
open my $my_min_max_avg_fh, '<:raw', $my_min_max_avg_file or die "Can't open file `$my_min_max_avg_file': $!\n";

my $my_min_max_avg_reducer = Local::Reducer::MinMaxAvg->new(
    field => 'price',
    source => Local::Source::FileHandler->new(fh=>$my_min_max_avg_fh),
    row_class => 'Local::Row::JSON',
    initial_value => undef,
);

my $my_min_max_avg_result;

$my_min_max_avg_reducer->reduce_n(3);
is($my_min_max_avg_reducer->get_min(), 1, 'my MinMaxAvg min 1 n=3');
is($my_min_max_avg_reducer->get_max(), 3, 'my MinMaxAvg max 3 n=3');
is($my_min_max_avg_reducer->get_avg(), 2, 'my MinMaxAvg avg 2 n=3');

$my_min_max_avg_reducer->reduce_n(1);
is($my_min_max_avg_reducer->get_min(), 1, 'my MinMaxAvg min 1 n=1');
is($my_min_max_avg_reducer->get_max(), 4, 'my MinMaxAvg max 4 n=1');
is($my_min_max_avg_reducer->get_avg(), 2.5, 'my MinMaxAvg avg 2.5 n=1');

$my_min_max_avg_reducer->reduce_n(4);
is($my_min_max_avg_reducer->get_min(), 1, 'my MinMaxAvg min 1 n=4');
is($my_min_max_avg_reducer->get_max(), 8, 'my MinMaxAvg max 8 n=4');
is($my_min_max_avg_reducer->get_avg(), 4.5, 'my MinMaxAvg avg 4.5 n=4');

$my_min_max_avg_reducer->reduce_all();
is($my_min_max_avg_reducer->get_min(), 1, 'my MinMaxAvg min all');
is($my_min_max_avg_reducer->get_max(), 10, 'my MinMaxAvg max all');
is($my_min_max_avg_reducer->get_avg(), 5.5, 'my MinMaxAvg avg all');

$my_min_max_avg_reducer->reduce_n(2);
is($my_min_max_avg_reducer->get_min(), 1, 'my MinMaxAvg min 1 n=2');
is($my_min_max_avg_reducer->get_max(), 10, 'my MinMaxAvg max 10 n=2');
is($my_min_max_avg_reducer->get_avg(), 5.5, 'my MinMaxAvg avg 5.5 n=2');

close $my_min_max_avg_fh;
