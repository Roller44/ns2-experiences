#!/usr/bin/perl

for (my $i = 100; $i <= 500; $i=$i+100) {
	for (my $j = 1; $j <= 30; $j++) {
		system("ns lab5.tcl $i $j");
		$f1="out$i-$j.tr";
		$f2="result$i";
		system("awk -f 5T.awk $f1 >> $f2");
		printf "\n";
	}
	printf "\n";
}

