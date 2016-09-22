use DDP;
use Data::Dumper;

my @array;

while ($row = <>) {
	chomp($row);
	push(@array, [split(";",$row)]);
}

p @array;
print Dumper(@array);