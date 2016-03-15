set ns [new Simulator]

#若用户指定了使用距离相量（distance vector）算法的动态路由方式，则设置路由的方式为 DV。
if {$argc==1} {
	set par [lindex $argv 0]
    if {$par=="DV"} {
    	$ns rtproto DV
    }
    
}

#设置数据传送时，以蓝色表示所传送的封包
$ns color 1 Blue
#打开 NAM 记录文件
set file1 [open out.nam w]
$ns namtrace-all $file1
#定义结束程序
proc finish { } \
{
	global ns file1
    $ns flush-trace
	close $file1
	exec nam out.nam &
	exit 0
}

#产生 5 个结点
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]

#把结点和路由器连接起来
$ns duplex-link $n0 $n1 0.5Mb 10ms DropTail
$ns duplex-link $n1 $n2 0.5Mb 10ms DropTail
$ns duplex-link $n1 $n3 0.5Mb 10ms DropTail
$ns duplex-link $n3 $n4 0.5Mb 10ms DropTail
$ns duplex-link $n3 $n2 0.5Mb 10ms DropTail
#设置节点在 nam 中所在的位置关系
$ns duplex-link-op $n0 $n1 orient right
$ns duplex-link-op $n1 $n2 orient right
$ns duplex-link-op $n1 $n3 orient down
$ns duplex-link-op $n3 $n4 orient right
$ns duplex-link-op $n3 $n2 orient right-up

#建立 TCP 联机
set tcp [new Agent/TCP]
$tcp set fid_ 1
$ns attach-agent $n0 $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $n4 $sink
$ns connect $tcp $sink

#建立 FTP 应用程序数据流
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ftp set type_ FTP

#设置在 1.0s 时，n1 到 n3 之间的链路发生的问题
$ns rtmodel-at 1.0 down $n1 $n3
#设置在 2.0s 时，n1 到 n3 间的链路又恢复正常
$ns rtmodel-at 2.0 up $n1 $n3
#在 0,1s 时，FTP 开始传送数据
$ns at 0.1 "$ftp start"
#在 3.0s 时，结束传送数据
$ns at 3.0 "finish"
#模拟开始
$ns run
