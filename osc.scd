
(
var addr = NetAddr.new("localhost", 57100);
OSCFunc({
arg msg, time;
var latency = time - Main.elapsedTime;
addr.sendBundle(latency, msg)
},'dirt/play').fix;
)



(
var osc = NetAddr.new("localhost", 57100);

// osc.sendMsg("/td/fall", 1);
// osc.sendMsg("/td/spin", 1);
// osc.sendMsg("/td/smoke", 1);
// osc.sendMsg("/td/window", 1);
// osc.sendMsg("/td/colorful", 1);
osc.sendMsg("/td/trolley", 1);
// osc.sendMsg("/td/end", 0);
)

(
var osc = NetAddr.new("localhost", 57100);

osc.sendMsg("/td/trolley", 0);
)

(
var osc = NetAddr.new("192.168.0.30", 10002);

osc.sendMsg("/td/trolley", 0.1);
)




// ----------------------------------
// ----------------------------------
// ----------------------------------
// ----------------------------------
// --------------以下はOLD------------
// ----------------------------------
// ----------------------------------
// ----------------------------------
// ----------------------------------




(
var addr = NetAddr.new("192.168.0.31", 2020);
~o=OSCFunc({
arg msg, time;
var latency = time - Main.elapsedTime;
	// msg.postln;
	// msg[16].postln;
	if(
		msg[16]=="nailClapper",
		addr.sendBundle(latency, ["/"++msg[16], msg[10]]),
		// ["/"++msg[16], msg[10]].postln,
		false
	);
},'dirt/play');
)

~o.free;


(
var osc = NetAddr.new("192.168.0.31", 2020);

osc.sendMsg("/test", 0.5);
// osc.sendMsg("/ctrl", "test", 0);
)


(
var osc = NetAddr.new("localhost", 57120);

osc.sendMsg("/dirt/play", "gain", 0.5, "n", 5, "pan", 0, "s", "bd", "room", 0.4);
)

(
var osc = NetAddr.new("localhost", 57110);

osc.sendMsg("/s_new", "sine", 1000, 1, 0, "amp", 1);
)



