#产生一个仿真对象
set ns [new Simulator]

#产生结点
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]

#打开一个仿真过程记录文集那，用来记录封包传送的过程
set f [open out.tr w]
$ns trace-all $f

#打开一个 NAM 记录文件
set nf [open out.nam w]
$ns namtrace-all $nf

#针对不同的流量定义v不同的颜色，这是留给 NAM 用的
$ns color 0 red
$ns color 1 blue

#产生链路
$ns duplex-link $n2 $n1 0.2Mbps 100ms DropTail
$ns duplex-link $n0 $n1 0.2Mbps 100ms DropTail

#设置结点的位置，这是留给 NAM 用的
$ns duplex-link-op $n2 $n1 orient right-down
$ns duplex-link-op $n0 $n1 orient right-up

#建立一个 Exponential on/off 的应用程序
set exp1 [ new Application/Traffic/Exponential]
#设置封包大小
$exp1 set packetSize_ 128
#设置 on 的时间
$exp1 set burst_time_ [expr 20.0/64]
#设置 off 的时间
$exp1 set idle_time_ 325ms
#设置速率
$exp1 set rate_ 65.536k
#设置 UDP 
set a [new Agent/UDP]
#设置 flow id 为 1
$a set fid_ 0

$exp1 attach-agent $a

#设置一个令牌桶整流器
set tbf [new TBF]
#设置桶的深度
$tbf set bucket_ 1024
#设置令牌补充速度
$tbf set rate_ 32.768k
#设置缓冲区大小（100 个 packet）
$tbf set qlen_ 100

$ns attach-tbf-agent $n0 $a $tbf

#设置接收端
set rcvr [new Agent/SAack]
$ns attach-agent $n1 $rcvr

#连接传送端 n0 和接受端 n1
$ns connect $a $rcvr

#建立另一个 Exponential on/off 的应用程序
set exp2 [new Application/Traffic/Exponential]
#设置封包大小
$exp2 set packetSize_ 128
#设置 on 的时间
$exp2 set burst_time_ [expr 20.0/64]
#设置 off 的时间
$exp2 set idle_time_ 325ms
#设置速率
$exp2 set rate_ 65.536k
#设置 UDP
set a2 [new Agent/UDP]
#设置 flow id 为 1
$a2 set fid_ 1

$exp2 attach-agent $a2
$ns attach-agent $n2 $a2

#连接传送端 n2 和接受端 n1
$ns connect $a2 $rcvr

#在 0.0s 时，exp1 和 exp2 开始传送封包
$ns at 0.0 "$exp1 start;$exp2 start"

#在 20.0s 时，exp1 和 exp2 停止传送，并且关闭记录文件，最后执行 NAM
$ns at 20.0 "$exp1 stop;$exp2 stop;close $f;close $nf;exec nam out.nam &;exit 0"

#开始模拟
$ns run
