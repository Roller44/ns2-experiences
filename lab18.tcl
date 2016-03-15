#这个实验由于没有找到修改过的 wireless-phy.cc ，没有运行过也不知是否可用。
#建议到 柯志亨 的个人网站找它提供的 NS2 软件。

#设置模拟结束时间
set opt(stop) 250

#设置 base station 的数目
set opt(num_FA) 1

#读取使用者设置的参数
proc getopt {argc argv} \
{
	global opt
    lappend optlist nn
    for {set i 0} {$i < $argc} {incr i} {
    	set opt($i) [lindex $argv $i]
    }
    
}

getopt $argc $argv

set pGG $opt(0)
set pBB $opt(1)
set pG $opt(2)
set pB $opt(3)
set loss_model $opt(4)
#comm_type 是用来设置当封包进入无线网络时，要用 unicast 还是 multicast 传送
#0: multicast, 1: unicast
set comm_type $opt(5）

#产生一个仿真对象
set ns_ [new Simulator]

#设置最多重传次数
Mac/802_11 set LongRetryLimit_ 4
#若是模拟的环境，是单纯的有线网络，或无线网络，寻址的方式使用 flat 即可（default 设置），但是若包含了有线网络和无线网络，
#就需要使用 hierarchial addressing 的方式寻址
$ns_ node-config -addressType hierarchical
#设置有两个 domain （第一个 domain 是有线网络，第二个是无线网络）
AddrParams set domain_num_ 2
#每个 domain 各有一个 cluster （每一个 domain 只包含一个子网络）
lappend cluster_num 1 1
AddrParams set cluster_num_ $cluster_num
#而在第一个 domain，其第一个 cluster 中，只有一个有线网络结点；而在第二个 domain，其第一个 cluster 中，会有两个无线网络结
#点，基地台算无线结点
lappend eilastlevel 1 2 
AddrParams set nodes_num_ $eilastlevel

#设置记录文件，把仿真过程都记录下来
set tracefd [open test.tr w]
$ns_ trace-all $tracefd

#设置 mobile host 的个数
set opt(nnn) 1

#拓扑的范围为 100m x 100m
set topo [new Topography]
$topo load_flatgrid 100 100

#create-god 要设置 base station 个数 + mobile host 个数
set god_ [create-god [expr $op(nnn) + $opt(num_FA)]]

#有线结点的地址，因为此结点是属于第一个 domain，第一个 cluster 中的第一个结点，所以地址为 0.0.0（从 0 开始算起）
set W(0) [$ns_ node 0.0.0]


#设置结点参数
$ns_ node-config	-mobileIP ON \
					-adhocRouting NOAH \
					-llType LL \
					-macType Mac/802_11 \
					-ifqType Queue/DropTail/PriQueue \
					-ifqLen 2000 \
					-antType Antenna/OmniAntenna \
					-propType Propagation/TwoRayGround \
					-phyType Phy/WirelessPhy \
					-channel $chan_ \
					-topoInstance $topo \
					-wiredRouting ON \
					-agentTrace ON \
					-routerTrace ON \
					-macTrace ON \

#设置 base station 几点，base station 是属于第二个 domain，第一个 cluster 中的第一个结点，所以其地址为 1.0.0（从 0 开始）
set HA [$ns_ node 1.0.0]

#把此 mobile host 与前面的 base station 进行链接
[$MH(0) set regagent_] set home_agent_ [AddrParams addr2id [$HA node-addr]]

#设置 base station 的位置在（100.0, 100.0）
$HA set X_ 100.0
$HA set Y_ 100.0
$HA set Z_ 0.0

#设置 mobile host 的位置在（80.0, 80.0）
$MH(0) set X_ 80.0
$MH(0) set Y_ 80.0
$MH(0) set Z_ 0.0

#在有线结点和基地台之间建立一条联机
$ns_ duplex-link $W(0) $HA 10Mb 10ms DropTail

$ns_ at $opt(stop).1 "$MH(0) reset";
$ns_ at $opt(stop).0001 "$W(0) reset"

#建立一个 CBR 的应用程序（wired node ---> base station）
set udp0 [new Agent/mUDP]
$udp0 set_filename sd
$ns_ attach-agent $W(0) $udp0
$udp0 set packetSize_ 1000
set cbr0 [new Application/Traffic/CBR]
$cbr0 attach-agent $udp0
$cbr0 set rate_ 500kb
$cbr0 set packetSize_ 1000
set null0 [new Agent/mUdpSink]
$null0 set_filename rd
$MH(0) attach $null0 3

#当基地台收到 cbr 封包时，可以根据使用者设置为 unicast 或 multicast，转送封包到 mobile host
set forwarder_ [$HA set forwarder_]
puts [$forwarder_ port]
$ns_ connect $udp0 $forwarder_
$forwarder_ dst-addr [AddrParams addr2id [$MH(0) node-addr]]
$forwarder_ comm-type $comm_type
$ns_ at 2.4 "$cbr0 start"

#在 200.0s 时，停止传送
$ns_ at 200.0 "$cbr0 stop"

$ns_ at $opt(stop).0002 "stop"
$ns_ at $opt(stop).0003 "$ns_ halt"

#设置一个 stop 的程序
proc stop { } \
{
	global ns_ tracefd
    
    #关闭记录文件
    close $tracefd
}


$ns_ run
