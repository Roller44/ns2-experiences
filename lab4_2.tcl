set ns [new Simulator]

set nd [open out.tr w]
$ns trace-all $nd

set nflow 3

set r1 [$ns node]
set r2 [$ns node]
$ns duplex-link $r1 $r2 1Mb 10ms DropTail

$ns queue-limit $r1 $r2 10

for {set i 0} {$i < $nflow} {incr i} {
	set s($i) [$ns node]
	set d($i) [$ns node]

	$ns duplex-link $s($i) $r1 10Mb 1ms DropTail
	$ns duplex-link $r2 $d($i) 10Mb 1ms DropTail
}

for {set i 0} {$i < $nflow} {incr i} {
	set tcp($i) [new Agent/TCP]
	set sink($i) [new Agent/TCPSink]
	$ns attach-agent $s($i) $tcp($i)
	$ns attach-agent $d($i) $sink($i)
	$ns connect $tcp($i) $sink($i)

	set ftp($i) [new Application/FTP]
	$ftp($i) attach-agent $tcp($i)
	$ftp($i) set type_ FTP
}

set rng [new RNG]
$rng seed 2

set RVstart [new RandomVariable/Uniform]
$RVstart set min_ 0
$RVstart set max_ 1
$RVstart use-rng $rng

for {set i 0} {$i < $nflow} {incr i} {
	set startT($i) [expr [$RVstart value]]
	puts "startT($i) $startT($i) sec"
	set endT($i) [expr ($startT($i) +5)]
	puts "endT($i) $endT($i) sec"

	$ns at $startT($i) "$ftp($i) start"
	$ns at $endT($i) "$ftp($i) stop"
}


proc finish { } \
{
	puts "proc finish"
	global ns nd
	puts "global ns nd"
	$ns flush-trace
	puts "flush trace"
	close $nd
	puts "close nd"
	
	exit 0
}

$ns at 7.0 "finish"

$ns run
