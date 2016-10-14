use strict;
use warnings;

use Test::More tests => 10;

use Local::Source::FileHandler;

my $my_file_source = "in";
open my $my_source_fh, '<:raw', $my_file_source or die "Can't open file `$my_file_source': $!\n";

my $iter_fh = Local::Source::FileHandler->new(fh=>$my_source_fh);

is($iter_fh->next(), '{"price": 1}', 'my FileHandler source iteration 1');
is($iter_fh->next(), '{"price": 2}', 'my FileHandler source iteration 2');
is($iter_fh->next(), '{"price": 3}', 'my FileHandler source iteration 3');
is($iter_fh->next(), '{"price": 4}', 'my FileHandler source iteration 4');
is($iter_fh->next(), '{"price": 5}', 'my FileHandler source iteration 5');
is($iter_fh->next(), '{"price": 6}', 'my FileHandler source iteration 6');
is($iter_fh->next(), '{"price": 7}', 'my FileHandler source iteration 7');
is($iter_fh->next(), '{"price": 8}', 'my FileHandler source iteration 8');
is($iter_fh->next(), '{"price": 9}', 'my FileHandler source iteration 9');
is($iter_fh->next(), '{"price": 10}', 'my FileHandler source iteration 10');

close $my_source_fh;
