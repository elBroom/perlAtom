use DDP;
use Data::Dumper;

my @array;

while ($row = <>) {
	@cells = split(";",$row);
	push(@array, [@cells]);
}

p @array;
print Dumper(@array);
