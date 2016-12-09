use Local::Stats;
use Data::Dumper;

my $stat = Local::Stats->new(sub {
	my $name = shift;
	return "cnt", "sum" if($name eq "m1");
	return "max", "min" if($name eq "m2");
	return "avg", "sum", "cnt" if($name eq "m3");
	return "avg" if($name eq "m4");
});

print Dumper($stat->add("m2", 2));
for(1..5){
	$stat->add("m1", $_);
	$stat->add("m2", $_);
	$stat->add("m3", $_);
}

print Dumper($stat->stat());