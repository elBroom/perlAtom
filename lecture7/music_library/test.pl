use strict;
use warnings;
use Data::Dumper;

my $i = 0;
foreach my $row (<>) {
	if($i % 2){
		print "$i: ".Dumper($row)."\n";
		my @cells = map {s/^\s+|\s+$//g; $_} split('\|', $row);
		print "cells \n";
		print Dumper(@cells);
	}
	$i++;
}
print "end\n";