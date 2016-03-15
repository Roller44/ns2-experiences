if {$argc!=2} {
	puts "Usage: ns queue.tcl queuetype_ noflows_ "
    puts "Example: ns queue.tcl myfifo 10"
    puts "queuetype_: myfifo or RED"
	exit
}


set par1 [lindex $argv 0]
set par2 [lindex $argv 1]

#产生一个仿真对象。
set ns [new Simulator]

#打开一个 trace 文件，用来描述封包传送的过程。
set nd [open out-$par1-$par2.tr w]
$ns trace-all $nd

proc finish { } \
{
	global ns nd par2 tcp startT
    $ns flush-trace
    close $nd

    set time [$ns now]
	set sum_thgpt 0

	#throughput = 收到 Ack 数 × Packet Size (Bit) / 传送时间
	#收到 Ack 数 = 传送出 Packet 数
	for {set i 0} {$i < $par2} {incr i} {
		set ackno_($i) [$tcp($i) set ack_]
		set thgpt($i) [expr $ackno_($i)*1000.0*8.0/($time-$startT($i))]
		#puts $thgpt($i)
		set sum_thgpt [expr $sum_thgpt + $thgpt($i)]
	}
	
	set avgthgpt [expr $sum_thgpt/$par2]
	puts "average throughput: $avgthgpt (bps)"
	exit 0
}

for {set i 0} {$i < $par2} {incr i} {
	set dst($i) [$ns node]
	set src($i) [$ns node]
}


set r1 [$ns node]
set r2 [$ns node]

#把结点和路由器连接起来
for {set i 0} {$i < $par2} {incr i} {
	$ns duplex-link $src($i) $r1 100Mb [expr ($i*10)]ms DropTail
    $ns duplex-link $r2 $dst($i) 100Mb [expr ($i*10)]ms DropTail
}


$ns duplex-link $r1 $r2 56k 10ms $par1

#设置 r1 到 r2 之间 Queue Size 为 50 个封包大小
$ns queue-limit $r1 $r2 50

#把队列长度记录下来
set q_ [[$ns link $r1 $r2] queue]
set queuechan [open q-$par1-$par2.tr w]
$q_ trace curq_

if {$par1=="RED"} {
	#使用 packet mode
    $q_ set bytes_ false
    $q_ set queue_in_bytes_ false
}

$q_ attach $queuechan

for {set i 0} {$i < $par2} {incr i} {
	set tcp($i) [$ns create-connection TCP/Reno $src($i) TCPSink $dst($i) 0]
    $tcp($i) set fid_ $i
}

#随机在 0 ～ 1s 之间决定数据流开始传送时间
set rng [new RNG]
$rng seed 1

set RVstart [new RandomVariable/Uniform]
$RVstart set min_ 0
$RVstart set max_ 1
$RVstart set use-rng $rng

#确定开始传送的时间
for {set i 0} {$i < $par2} {incr i} {
	set startT($i) [expr [$RVstart value]]
   puts "startT($i) $startT($i) start"
}

#在指定时间，开始传送数据
for {set i 0} {$i < $par2} {incr i} {
	set ftp($i) [$tcp($i) attach-app FTP]
    $ns at $startT($i) "$ftp($i) start"
}

#在第 50s 时去调用 finish 来结束模拟
$ns at 50.0 "finish"

#执行模拟
$ns run
