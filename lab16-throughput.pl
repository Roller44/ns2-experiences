#使用方法：perl throughput.pl <trace file> <flow id> <granlarity>

#记录文件名
$infile=$ARGV[0];

#要计算平均速率的 flow id
$flowid=$ARGV[1];

#多少时间算一次（单位为 s）
$granularity=$ARGV[2];

$sum=0;
$clock=0;

#打开记录文集那
open(DATA,"<$infile")
	||die "Can't open $infile $!";

#读取记录文件中的每行数据，数据是以空白分成众多字段
while (<DATA>) {
	@x=split(' ');
	
	#读取的第二个字段是时间，判断所读到的时间，是否已经达到要统计吞吐量的时候
	if ($x[1]-$clock<=$granularity) {
		#读取的地一个字段是动作，判断动作是否是结点接收封包
		if ($x[0] eq 'r') {
			#读取的第 8 个字段是 flow id，判断 flow id 是否为指定的 id
			if ($x[7] eq $flowid) {
				#计算累计的封包大小
				$sum=$sum+$x[5];
			}	
		}
	}
	else
	{
		#计算吞吐量
		$throughput=$sum*8.0/$granularity;
        #输出结果： 时间、吞吐两（bps）
		print STDOUT "$x[1]: $throughput bps\n";
		#设置下次要计算吞吐量的时间
		$clock=$clock+$granularity;
		#把累计量清零
		$sum=0;
	}
	
}

#计算最后一次的吞吐量大小
	$throughput=$sum*8.0/$granularity;
	print STDOUT "$x[1]: $throughput bps\n";
	$clock=$clock+$granularity;
	$sum=0;

	#关闭文件
	close DATA;
	exit(0);
