use strict;
use warnings;

use Test::More tests => 10;

use Local::Row::Simple;

my $simple_row = Local::Row::Simple->new(str=>'key1:1,key2:2,key3:3,key4:4,key5:5,key6:6,key7:7,key8:8,key9:9');

is($simple_row->get("key",  0), 0, 'my simple row key');
is($simple_row->get("key1", 0), 1, 'my simple row key1');
is($simple_row->get("key2", 0), 2, 'my simple row key2');
is($simple_row->get("key3", 0), 3, 'my simple row key3');
is($simple_row->get("key4", 0), 4, 'my simple row key4');
is($simple_row->get("key5", 0), 5, 'my simple row key5');
is($simple_row->get("key6", 0), 6, 'my simple row key6');
is($simple_row->get("key7", 0), 7, 'my simple row key7');
is($simple_row->get("key8", 0), 8, 'my simple row key8');
is($simple_row->get("key9", 0), 9, 'my simple row key9');