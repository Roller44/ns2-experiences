$infile=$ARGV[0];

$granularity=$ARGV[1];

$sum=0;
$sum_total=0;
$clock=0;
$maxrate=0;
$init=0;

open (DATA, "<$infile")
	|| die "Can't open $infile $!";

while (<DATA>) {
	@x = split (' ');
	if ($init==0) {
		$start=$x[1];
		$init=1;
	}
	
	if ($x[1]-$clock<=$granularity) {
		$sum=$sum+$x[2];
		$sum_total=$sum_total+$x[2];
	}
	else
	{
		$throughput=$sum*0.8/$granularity;
		
		if ($throughput>$maxrate) {
			$maxrate=$throughput;
		}
    	print STDOUT "$x[2]: $throughput bps\n";
		
		$clock=$clock+$granularity;
		$sum_total=$sum_total+$x[2];
		$sum=$x[2];
	}
	#print STDOUT "$x[0]+++$x[1]+++$x[2]+++$x[3]+++$x[4]+++\n";
}

$endtime=$x[1];

$throughput=$sum*0.8/$granularity;
print STDOUT "$x[1]: $throughput bps\n";
$clock=$clock+$granularity;
$sum=0;
print STDOUT "$sum_total $start $endtime\n";
$avgrate=$sum_total*8.0/ ($endtime-$start);
print STDOUT "Average rate: $avgrate bps\n";

close DATA ;
exit (0) ;
