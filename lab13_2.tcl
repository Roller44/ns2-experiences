set ns [new Simulator]

set nd [open out13_2.tr w]
$ns trace-all $nd

#打开两个文件用来记录 cwnd 变化情况
set f0 [open cwnd-Vegas.tr w]
set f1 [open cwnd-reno.tr w]

#定义一个结束的程序
proc finish { } \
{
	global ns nd f0 tcp0 f1 tcp1
    
	#显示最后的平均吞吐量
	puts [format "Vegas-throughput: %.1f Kbps"\
			[expr [$tcp0 set ack_]*([$tcp0 set packetSize_])*8/1000.0/10]]
	puts [format "Reno-throughput: %.1f Kbps"\
			[expr [$tcp1 set ack_]*([$tcp1 set packetSize_])*8/1000.0/10]]
    $ns flush-trace
    #关闭文件
    close $nd
    close $f0
	close $f1

	exit 0
}

#定义一个记录程序，每格 0.01s 就去记录当时的 cwnd
proc record { } \
{
	global ns tcp0 f0 tcp1 f1

    set now [$ns now]
    puts $f0 "$now [$tcp0 set cwnd_]"
	puts $f1 "$now [$tcp1 set cwnd_]"
	$ns at [expr $now+0.01] "record"
}

#建立结点
set r0 [$ns node]
set r1 [$ns node]
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

#建立链路
$ns duplex-link $n0 $r0 10Mb 1ms DropTail
$ns duplex-link $n2 $r0 10Mb 1ms DropTail
$ns duplex-link $r0 $r1 1Mb 20ms DropTail
$ns duplex-link $r1 $n1 10Mb 1ms DropTail
$ns duplex-link $r1 $n3 10Mb 1ms DropTail

set buffer_size 15
$ns queue-limit $r0 $r1 $buffer_size

#建立 TCP Vegas 的 FTP 联机
set tcp0 [new Agent/TCP/Vegas]
$tcp0 set v_alpha_ 1
$tcp0 set v_beta_ 3
$tcp0 set window_ 24
$ns attach-agent $n0 $tcp0
set tcp0sink [new Agent/TCPSink]
$ns attach-agent $n1 $tcp0sink
$ns connect $tcp0 $tcp0sink
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0

#建立另一条 TCP Vegas 的 FTP 联机
set tcp1 [new Agent/TCP/Reno]
$tcp1 set window_ 24
$ns attach-agent $n2 $tcp1
set tcp1sink [new Agent/TCPSink]
$ns attach-agent $n3 $tcp1sink
$ns connect $tcp1 $tcp1sink
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1

$ns at 0.0 "$ftp0 start"
$ns at 10.0 "$ftp0 stop"
$ns at 0.0 "$ftp1 start"
$ns at 10.0 "$ftp1 stop"

$ns at 0.0 "record"
$ns at 10.0 "finish"

$ns run
