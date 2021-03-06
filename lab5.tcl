if {$argc!=2} {
	puts "Usage: ns lab5.tcl rate_ no_"
	exit
}


set par1 [lindex $argv 0]
set par2 [lindex $argv 1]

set ns [new Simulator]

set nd [open out$par1-$par2.tr w]
$ns trace-all $nd

proc finish { } \
{
	global ns nd
	$ns flush-trace
	close $nd
	exit 0;
}

for {set i 0} {$i < 3} {incr i} {
	set s($i) [$ns node]
}
for {set i 0} {$i < 3} {incr i} {
	set d($i) [$ns node]
}
for {set i 0} {$i < 2} {incr i} {
	set r($i) [$ns node]
}

$ns duplex-link $s(0) $r(0) 10Mb 1ms DropTail
$ns duplex-link $s(1) $r(0) 10Mb 1ms DropTail
$ns duplex-link $s(2) $r(0) 10Mb 1ms DropTail
$ns duplex-link $r(0) $r(1) 1Mb 1ms DropTail
$ns duplex-link $r(1) $d(0) 10Mb 1ms DropTail
$ns duplex-link $r(1) $d(1) 10Mb 1ms DropTail
$ns duplex-link $r(1) $d(2) 10Mb 1ms DropTail

set tcp1 [new Agent/TCP]
$ns attach-agent $s(0) $tcp1
set sink1 [new Agent/TCPSink]
$ns attach-agent $d(0) $sink1
$ns connect $tcp1 $sink1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ftp1 set type_ FTP

set tcp2 [new Agent/TCP]
$ns attach-agent $s(1) $tcp2
set sink2 [new Agent/TCPSink]
$ns attach-agent $d(1) $sink2
$ns connect $tcp2 $sink2
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2
$ftp2 set type_ FTP

set udp [new Agent/UDP]
$ns attach-agent $s(2) $udp
set null [new Agent/Null]
$ns attach-agent $d(2) $null
$ns connect $udp $null
set traffic [new Application/Traffic/Exponential]
$traffic set packetSize_ 1000
$traffic set burst_time_ 0.5
$traffic set idle_time_ 0
$traffic set  rate_ [expr $par1*1000]
$traffic attach-agent $udp

set rng [new RNG]
$rng seed 0

set RVstart [new RandomVariable/Uniform]
$RVstart set min_ 3
$RVstart set max_ 4
$RVstart use-rng $rng

set startT [expr [$RVstart value]]
puts "startT $startT sec"

$ns at 0.0 "$ftp2 start"
$ns at 0.0 "$traffic start"
$ns at $startT "$ftp1 start"
$ns at 11.0 "$ftp1 stop"
$ns at 11.5 "$ftp2 stop"
$ns at 11.5 "$traffic stop"

$ns at 12.0 "finish"

$ns run
