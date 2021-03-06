if {$argc!=1} {
	puts "Usage: ns lab11.tcl TCPversion."
    puts "Example: ns lab11.tcl Tahoe or ns lab11.tcl Reno."
    exit
}

set par1 [lindex $argv 0]

#产生一个仿真对象
set ns [new Simulator]
#打开一个 trace file，用来记录封包传送的过程。
set nd [open out-$par1.tr w]
$ns trace-all $nd
#打开一个文件用来记录 cwnd 变化情况
set f0 [open cwnd-$par1.tr w]

#定义一个结束的程序
proc finish { } \
{
	global ns nd f0 tcp
    
    #显示最后的平均吞吐量。
    puts [format "average throughput: %.1f Kbps"\
            [expr [$tcp set ack_]*([$tcp set packetSize_])*8/1000.0/10]]
    $ns flush-trace
    #关闭文件
    close $nd
    close $f0
    exit 0
}

#定义一个记录的程序，每隔 0,01s 就去记录当时的 cwnd。
proc record { } \
{
	global ns tcp f0
    set now [$ns now]
    puts $f0 "$now [$tcp set cwnd_]"
    $ns at [expr $now+0.01] "record"
}


#产生传送结点，路由器 r1，r2 和接收结点
set n0 [$ns node]
set r0 [$ns node]
set r1 [$ns node]
set n1 [$ns node]

#建立链路
$ns duplex-link $n0 $r0 10Mb 1ms DropTail
$ns duplex-link $r0 $r1 1Mb 4ms DropTail
$ns duplex-link $r1 $n1 10Mb 1ms DropTail

#设置队列长度为 18 个封包大小
set queue 18
$ns queue-limit $r0 $r1 $queue

#根据用户的设置，指定 TCP 版本
if {$par1=="Tahoe"} {
	set tcp [new Agent/TCP]
} else {
	set tcp [new Agent/TCP/Reno]
}


$ns attach-agent $n0 $tcp

set tcpsink [new Agent/TCPSink]
$ns attach-agent $n1 $tcpsink

$ns connect $tcp $tcpsink

#建立 FTP 应用程序
set ftp [new Application/FTP]
$ftp attach-agent $tcp

#在 0.0s 时，开始传送
$ns at 0.0 "$ftp start"
#在 10.0s 时，结束传送
$ns at 10.0 "$ftp stop"
#在 0.0s 时调用 reconrd 来记录 TCP 的 cwnd 变化情况
$ns at 0.0 "record"
#在第 10,0s 时调用 finish 来结束模拟
$ns at 10.0 "finish"
#执行模拟
$ns run
