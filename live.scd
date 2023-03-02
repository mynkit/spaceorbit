
(
SynthDef(\rain, {
	arg amp=1;
    var sig, out=0;
    sig = { TRand.ar(-1, 1, Dust.ar(25000)) } ! 2;
	sig = BPF.ar(sig, 100, 0.5);
	sig = HPF.ar(sig, 6000);
	sig = LPF.ar(sig, 5000);
	sig = sig*10*amp;
	Out.ar(out, sig);
}, [30]).add;
SynthDef("background", {
	arg amp=1;
	var out=0;
	p=PinkNoise.ar(1!2);
	p=HPF.ar(p, 50);
	p=LPF.ar(p, 1500);
	Out.ar(out, p*0.2*amp);
}, [1]).add;
)
)


(
var osc = NetAddr.new("localhost", 57110);

~rainNode = 1001;
~backgroundNode = 1002;


osc.sendMsg("/s_new", \rain, ~rainNode, 1, 0, \amp, 0);

osc.sendMsg("/s_new", \background, ~backgroundNode, 1, 0, \amp, 0);
)

(
var osc = NetAddr.new("localhost", 57110);
osc.sendMsg("/n_set", ~rainNode, \amp, 0);
osc.sendMsg("/n_set", ~backgroundNode, \amp, 0);
)
