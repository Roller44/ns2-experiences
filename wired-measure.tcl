# Creating New Simulator
set ns [new Simulator -multicast on]
set group0 [Node allocaddr]

$ns color 1 Blue
$ns color 2 Red

# Setting up the traces
set f [open out.tr w]
set nf [open out.nam w]
$ns namtrace-all $nf
$ns trace-all $f
proc finish {} { 
	global ns nf f
	$ns flush-trace
	puts "Simulation completed."
	close $nf
	close $f
	exit 0
}


#
#Create Nodes
#

set s1 [$ns node]
      puts "s1: [$s1 id]"
set s2 [$ns node]
      puts "s2: [$s2 id]"
set r [$ns node]
      puts "r: [$r id]"
set d [$ns node]
      puts "d: [$d id]"


#
#Setup Connections
#

$ns duplex-link $s1 $r 2Mb 10ms DropTail

$ns duplex-link $s2 $r 2Mb 10ms DropTail

$ns duplex-link $r $d 1.7Mb 20ms DropTail
$ns queue-limit $r $d 10

$ns duplex-link-op $r $d queuePos 0.5

#
#Set up Transportation Level Connections
#

set tcp [new Agent/TCP]
$ns attach-agent $s1 $tcp

set udp [new Agent/mUDP]
$udp set_filename sd_udp
$ns attach-agent $s2 $udp

set sink [new Agent/TCPSink/mTcpSink]
$sink set_filename tcp_sink
$ns attach-agent $d $sink

set null [new Agent/mUdpSink]
$null set_filename rd_udp
$ns attach-agent $d $null



#
#Setup traffic sources
#

set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set packet_size_ 1000
$cbr set rate_ 1mb
$cbr set random_ false

set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ftp set type_ FTP

$ns connect $tcp $sink
$tcp set fid_ 1
$ns connect $udp $null
$udp set fid_ 2

set mproto DM
set mrthandle [$ns mrtproto $mproto]


#
#Start up the sources
#

$ns at 0.1 "$cbr start"
$ns at 1.0 "$ftp start"
$ns at 4.0 "$ftp stop"
$ns at 4.5 "$cbr stop"
$ns at 5.0 "finish"
$ns run
