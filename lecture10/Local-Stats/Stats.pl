use Local::Stats;
use Data::Dumper;

my $stat = Local::Stats->new(sub {
	my $name = shift;
	return "cnt", "sum" if($name eq "m1");
	return "max", "min" if($name eq "m2");
	return "avg", "sum", "cnt" if($name eq "m3");
});

print Dumper($stat);

print Dumper($stat->add("m1", 1));
print Dumper($stat->add("m1", 2));
print Dumper($stat->add("m2", 3));
# for(1..1000){
# 	$stat->add("m1", $_);
# 	$stat->add("m2", $_);
# 	$stat->add("m3", $_);
# }

print Dumper($stat->stat());