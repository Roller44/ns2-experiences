#产生一个新的仿真对象
set ns [new Simulator]
#打开一个 trace 文件，用来记录封包传送的过程
set nd [open tsw3cm.tr w]
$ns trace-all $nd

#设置地一个分组的 CIR 为 1500000 bps，CBR 为 2000 bps，PIR 为 3000000 bps，PBS 为 3000 B
#设置第二个分组的 CIR 为 1000000 bps，CBR 为 1000 bps，PIR 为 2000000 bps，PBS 为 2000 B
#设置地一个分组的 CBR 的传送速率为 4000000 bps，第二组的为 4000000bps
set cir0  1500000
set cbs0     2000
set pir0  3000000
set pbs0     3000
set rate0 4000000
set cir1  1000000
set cbs1     1000
set pir1  2000000
set pbs1     2000
set rate1 4000000

#模拟时间为 85s，每个传送的 CBR 的封包大小为 1000B
set testTime 85.0
set packetSize 1000

#设置网络仿真结构
set s1 [$ns node]
set s2 [$ns node]
set e1 [$ns node]
set core [$ns node]
set e2 [$ns node]
set dest [$ns node]

$ns duplex-link $s1 $e1 10Mb 5ms DropTail
$ns duplex-link $s2 $e1 10Mb 5ms DropTail

#指定 e1 为边境路由器，core 为核心路由器
$ns simplex-link $e1 $core 10Mb 5ms dsRED/edge
$ns simplex-link $core $e1 10Mb 5ms dsRED/core
#指定 e2 为边境路由器
$ns simplex-link $core $e2 5Mb 5ms dsRED/core
$ns simplex-link $e2 $core 5Mb 5ms dsRED/edge

$ns duplex-link $e2 $dest 10Mb 5ms DropTail

#设置在 nam 中结点的位置关系图
$ns duplex-link-op $s1 $e1 orient down-right
$ns duplex-link-op $s2 $e1 orient up-right
$ns duplex-link-op $e1 $core orient right
$ns duplex-link-op $core $e2 orient right
$ns duplex-link-op $e2 $dest orient right

#设置队列名称
set qE1C [[$ns link $e1 $core] queue]
set qE2C [[$ns link $e2 $core] queue]
set qCE1 [[$ns link $core $e1] queue]
set qCE2 [[$ns link $core $e2] queue]

#设置 e1 到 core 的参数
$qE1C meanPktSize $packetSize

#设置一个 physical queue
$qE1C set numQueues_ 1
#设置三个 virtual queue
$qE1C setNumPrec 3

#设置从 s1 到 dest 为第一分组，采用 TRTCM，并把符合标准的封包标成绿色
$qE1C addPolicyEntry [$s1 id] [$dest id] trTCM 10 $cir0 $cbs0 $pir0 $pbs0
#设置从 s2 到 dest 为第二分组，采用 TRTCM，并把符合标准的封包标成绿色
$qE1C addPolicyEntry [$s2 id] [$dest id] trTCM 10 $cir1 $cbs1 $pir1 $pbs1
#把不符合标准的封包标成黄色和红色
$qE1C addPolicerEntry trTCM 10 11 12
#把绿色的封包放到第一个实际队列中的第一个虚拟队列
$qE1C addPHBEntry 10 0 0
#把黄色的封包放到第一个实际队列中的第二个虚拟队列
$qE1C addPHBEntry 11 0 1
#把红色的封包放到第一个实际队列中的第三个虚拟队列
$qE1C addPHBEntry 12 0 2

#设置第一个实际队列中的第一个虚拟队列的 RED 参数
#{ min, max, max drop,probability } = { 20 packets, 40 packets, 0.02}
$qE1C configQ 0 0 20 40 0.02
#设置第一个实际队列中的第二个虚拟队列的 RED 参数为{ 10, 20, 0.1 }
$qE1C configQ 0 1 10 20 0.10
#设置第一个实际队列中的第二个虚拟队列的 RED 参数为{ 5, 10, 0.20 }
$qE1C configQ 0 2 5 10 0.20

#设置 e2 到 core 的参数
$qE2C meanPktSize $packetSize
$qE2C set numQueues_ 1
$qE2C setNumPrec 3
$qE2C addPolicyEntry {$dest id} {$s1 id} trTCM 10 $cir0 $cbs0 $pir0 $pbs0
$qE2C addPolicyEntry {$dest id} {$s2 id} trTCM 10 $cir1 $cbs1 $pir1 $pbs1
$qE2C addPolicerEntry trTCM 10 11 12
$qE2C addPHBEntry 10 0 0
$qE2C addPHBEntry 11 0 1
$qE2C addPHBEntry 12 0 2
$qE2C configQ 0 0 20 40 0.02
$qE2C configQ 0 1 10 20 0.10
$qE2C configQ 0 2  5 10 0.20

#设置 core 到 e1 的参数
$qCE1 meanPktSize $packetSize
$qCE1 set numQueues_ 1
$qCE1 setNumPrec 3
$qCE1 addPHBEntry 10 0 0
$qCE1 addPHBEntry 11 0 1
$qCE1 addPHBEntry 12 0 2
$qCE1 configQ 0 0 20 40 0.02
$qCE1 configQ 0 1 10 20 0.10
$qCE1 configQ 0 2  5 10 0.20

#设置 core 到 e2 的参数
$qCE2 meanPktSize $packetSize
$qCE2 set numQueues_ 1
$qCE2 setNumPrec 3
$qCE2 addPHBEntry 10 0 0
$qCE2 addPHBEntry 11 0 1
$qCE2 addPHBEntry 12 0 2
$qCE2 configQ 0 0 20 40 0.02
$qCE2 configQ 0 1 10 20 0.10
$qCE2 configQ 0 2  5 10 0.20

#设置 s1 到 dest 的 CBR 参数
set udp0 [new Agent/UDP]
$ns attach-agent $s1 $udp0
set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp0
$udp0 set class_ 1
$cbr0 set packet_size_ $packetSize
$udp0 set packetSize_ $packetSize
$cbr0 set rate_ $rate0
set null0 [new Agent/Null]
$ns attach-agent $dest $null0
$ns connect $udp0 $null0

#设置 s2 到 dest 的 CBR 参数
set udp1 [new Agent/UDP]
$ns attach-agent $s2 $udp1
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp1
$udp1 set class_ 2
$cbr1 set packet_size_ $packetSize
$udp1 set packetSize_ $packetSize
$cbr1 set rate_ $rate1
set null1 [new Agent/Null]
$ns attach-agent $dest $null1
$ns connect $udp1 $null1

#定义一个结束的程序
proc finish { } \
{
	global ns nd
    $ns flush-trace
    close $nd
    exit 0
}

#显示在 e1 的 SLA
$qE1C printPolicyTable
$qE1C printPolicerTable

$ns at 0.0 "$cbr0 start"
$ns at 0.0 "$cbr1 start"
$ns at $testTime "$cbr0 stop"
$ns at $testTime "$cbr1 stop"
$ns at [expr $testTime + 1.0] "finish"

$ns run
