if {$argc!=1} {
	puts "Usage: ns lab15_3.tcl Bandwidth(Mbps)"
    exit
}

#产生一个仿真对象
set ns [new Simulator]

set bandwidth [lindex $argv 0]

#每秒可以处理的封包数（含 TCP/IP Header）
set mu [expr $bandwidth*1000000/(8*552)]

#Round Trip Time
set tau [expr (1+18+1)*2*0.001]
set beta .64

#设置 buffer size 为 bandwidth-delay product 的 beta 倍以观察频宽的使用频率与 ssthresh 之间的关系
set B [expr $beta*($mu*$tau+1)+0.5]

puts "Buffer size=$B"

#计算 bandwidth-delay product
puts "Bandwidth-delay product=[expr $mu*$tau+1]"

#打开记录文件，用来记录封包传送的过程
set nd [open out-ssthresh.tr w]
$ns trace-all $nd

set f1 [open sq-ssthresh.tr w]
set f2 [open throughput-ssthresh.tr w]
set f3 [open cwnd-ssthresh.tr w]

#定义一个结束的程序
proc finish { } \
{
	global ns nd f1 f2 tcp0 sink0 bandwidth
    $ns flush-trace

    #关闭文件
    close $nd
    close $f1
    close $f2


    set now [$ns now]
    set ack [$tcp0 set ack_]
    set size [$tcp0 set packetSize_]
	set throughput [expr $ack*($size)*8/$now/1000000.0]
	set ut [expr ($throughput/$bandwidth)*100.0]

	#计算平均吞吐量
	puts [format "throughput=\t%.2f Mbps" $throughput]
	puts [format "utilization=\t%.1f" $ut]
	exit 0
}

#定义一个记录的程序，每隔 0.05s 就去记录当时的 tcp 的 seqno_, cwnd, 和 throughput
proc record { } \
{
	global ns tcp0 sink0 f1 f2 f3

    set time 0.05
    set now [$ns now]

    set seq [$tcp0 set seqno_]
    set cwnd [$tcp0 set cwnd_]
	set bw [$sink0 set bytes_]
	puts $f1 "$now $seq"
	puts $f2 "$now [expr $bw*8/$now/1000]"
	puts $f3 "$now $cwnd"

	$ns at [expr $now+$time] "record"
}

#建立结点
set r0 [$ns node]
set r1 [$ns node]
set n0 [$ns node]
set n1 [$ns node]

#建立链路
set bd $bandwidth+Mb
$ns duplex-link $n0 $r0 100Mb 1ms DropTail
$ns duplex-link $r0 $r1 $bd 18ms DropTail
$ns duplex-link $r1 $n1 100Mb 1ms DropTail
$ns queue-limit $r0 $r1 $B

#建立 FTP 联机
set tcp0 [new Agent/TCP/Reno]
$ns attach-agent $n0 $tcp0
$tcp0 set window_ 64
$tcp0 set packetSize_ 512
set sink0 [new Agent/TCPSink]
$ns attach-agent $n1 $sink0
$ns connect $tcp0 $sink0
set ftp [new Application/FTP]
$ftp attach-agent $tcp0


$ns at 0.0 "$ftp start"
$ns at 30.0 "$ftp stop"
$ns at 0.05 "record"
$ns at 30.0 "finish"

$ns run
