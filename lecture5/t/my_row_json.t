use strict;
use warnings;

use Test::More tests => 10;

use Local::Row::JSON;

my $json_row = Local::Row::JSON->new(str=>'{
	"key1":1,
	"key2":2,
	"key3":3,
	"key4":{
		"key5":5,
		"key6":6, 
		"key7":{
			"key8":8
		}
	},
	"key9":9
}');

is($json_row->get("key",  0), 0, 'my JSON row key');
is($json_row->get("key1", 0), 1, 'my JSON row key1');
is($json_row->get("key2", 0), 2, 'my JSON row key2');
is($json_row->get("key3", 0), 3, 'my JSON row key3');
is($json_row->get("key4", 0), 0, 'my JSON row key4');
is($json_row->get("key5", 0), 0, 'my JSON row key5');
is($json_row->get("key6", 0), 0, 'my JSON row key6');
is($json_row->get("key7", 0), 0, 'my JSON row key7');
is($json_row->get("key8", 0), 0, 'my JSON row key8');
is($json_row->get("key9", 0), 9, 'my JSON row key9');