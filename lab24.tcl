proc getopt {arc argv} \
{
	global opt
    lappend optlist nn
    for {set i 0} {$i < $argc} {incr i} {
    	set opt($i) [lindex $argv $i]
    }
    
}

getopt $argc $argv

#===================================================================================================================
#Simulation parameters setup
#===================================================================================================================
set val(chan)	Channel/WirelessChannel		;# channel type
set val(prop)	Propagation/TwoRayGround	;# radio-propagation model
set val(netif)	Phy/WirlessPhy				;# network interface type
if {$opt(0) > 0} {
	set val(mac)	Mac/802_11e				;# MAC Type
	set val(ifq)	Queue/DTail/PriQ		;# interface queue type
	Mac/802_11e set dataRate_ 1Mb
	Mac/802_11e set basicRate_ 1Mb
}else {
	set val(mac)	Mac/802_11				;# MAC type
	set val(ifq)	Queue/DropTail/PriQueue	;# interface queue type
	Mac/802_11 set dataRate_ 1Mb
	Mac/802_11 set basicRate_ 1Mb
}
set val(ll)		LL							;# link layer type
set val(ant)	Antenna/OmniAntenna			;# antenna model
set val(ifqlen)	50							;# max packet in ifq
set val(nn)		3							;#number of mobilenodes
set val(x)		400							;# X dimension of topography
set val(y)		500							;# Y dimension of topography
set val(stop)	50.0						;# time of simulation end

#===================================================================================================================
#Initialization
#===================================================================================================================
#Create a ns simulator
set ns [new Simulator]

#Setup topography object
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)
create-god $val(nn)


#Open the NS trace file
set tracefile [open out.tr w]
$ns trace-all $tracefile

set chan [new $val(chan)]; #Create a wireless channel

#===================================================================================================================
#Mobile node parameter setup
#===================================================================================================================
$ns node-config -adhocRouting	$val(rp) \
				-llType			$val(ll) \
				-macType		$val(mac) \
				-ifqType		$val(ifq) \
				-ifqLen			$val(ifqlen) \
				-antType		$val(ant) \
				-propType		$val(prop) \
				-phyType		$val(netif) \
				-channel		$chan \
				-topoInstance	$topo \
				-agentTrace		OFF \
				-routerTrace	OFF \
				-macTrace		OFF \
				-movementTrace	OFF

#===================================================================================================================
#Node Definition
#===================================================================================================================
#Create 3 nodes
set n0 [$ns node]
$n0 set X_ 200
$n0 set Y_ 400
$n0 set Z_ 0.0
$ns initial_node_pos $n0 20
set n1 [$ns node]
$n1 set X_ 300
$n1 set Y_ 400
$n1 set Z_ 0.0
$ns initial_node_pos $n1 20
