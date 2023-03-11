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
SynthDef("sine", {
	arg freq = 440, amp = 0.2, parFreq=0, pan2Freq=0, pan=0,
	vibratoFreq=3, vibratoDepth=0, actave=1, reverb=0, ice=0, distort=0;
	var sig, out=0, chain, in, z, y, oct, left, right, mod;
	sig = SinOsc.ar(actave*freq*(1+((LFPar.ar(vibratoFreq)+1)*(vibratoDepth/50))), 0, amp);
	// distort
	mod = CrossoverDistortion.ar(sig, amp: 0.2, smooth: 0.01);
	mod = mod + (0.1 * distort * DynKlank.ar(`[[60,61,240,3000 + SinOsc.ar(62,mul: 100)],nil,[0.1, 0.1, 0.05, 0.01]], sig));
	mod = (mod.cubed * 8).softclip * 0.5;
	sig = SelectX.ar(distort, [sig, mod]);
	// tremoro
	sig = if(
		parFreq>0.1,
		sig*LFPar.ar(parFreq),
		if(
			LFPar.ar(parFreq)>0,
			sig*(LFPar.ar(parFreq) + (1-(LFPar.ar(parFreq))*((1-(parFreq*10))))),
			sig*(LFPar.ar(parFreq) + (-1-(LFPar.ar(parFreq))*((1-(parFreq*10))))),
		)
	);
	// panning
	sig = if(
		pan2Freq>0.1,
		Pan2.ar(sig, LFPar.ar(pan2Freq)),
		Pan2.ar(sig, LFPar.ar(pan2Freq)*pan2Freq*10)
	);
	// reverb
	z = DelayN.ar(sig, 0.048);
	y = Mix.ar(Array.fill(7,{ CombL.ar(z, 0.1, 1, 15) }));
	32.do({ y = AllpassN.ar(y, 0.050, [0.050.rand, 0.050.rand], 1) });
	oct = 1.0 * LeakDC.ar( abs(y) );
	y = SelectX.ar(ice, [y, ice * oct, DC.ar(0)]);
	sig = sig + (0.2*y*reverb);
	sig = sig * 0.1;
    Out.ar(out, sig);
}, [0.3, 10, 1, 1, 1, 1, 1, 1, 10, 10, 10]).add;
)


// Live Coding

// ---------scene0---------

// node free
(
var osc = NetAddr.new("localhost", 57110);
osc.sendMsg("n_free", 1001);
osc.sendMsg("n_free", 1002);
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
osc.sendMsg("/n_set", ~rainNode, \amp, 1.5);
osc.sendMsg("/n_set", ~backgroundNode, \amp, 0.5);
)

// ---------scene1---------

// c: 261.626
// cs: 277.183
// d: 293.665
// ds: 311.127
// e: 329.628
// f: 349.228
// fs: 369.994
// g: 391.995
// gs: 415.305
// a: 440.000
// bf: 466.164
// b: 493.883

// node free
(
var osc = NetAddr.new("localhost", 57110);
osc.sendMsg("n_free", 1003);
osc.sendMsg("n_free", 1004);
osc.sendMsg("n_free", 1005);
osc.sendMsg("n_free", 1006);
osc.sendMsg("n_free", 1007);
)

// def
(
var osc = NetAddr.new("localhost", 57110);

~scene1n1 = 1003;
~scene1n2 = 1004;
~scene1n3 = 1005;
~scene1n4 = 1006;
~scene1n5 = 1007;


osc.sendMsg("/s_new", \sine, ~scene1n1, 1, 0, \freq, 369.994, \amp, 0, \parFreq, 0.3, \pan2Freq, 0.1, \vibratoDepth, 0.3, \vibratoFreq, 3, \actave, 1, \reverb, 0.7);

osc.sendMsg("/s_new", \sine, ~scene1n2, 1, 0, \freq, 329.628*2, \amp, 0, \vibratoDepth, 0.3, \vibratoFreq, 1, \actave, 1, \reverb, 0.5, \parFreq, 0.4, \pan2Freq, 0.12, \vibratoFreq, 1, \vibratoDepth, 0.1);
osc.sendMsg("/s_new", \sine, ~scene1n3, 1, 0, \freq, 277.183*2, \amp, 0, \vibratoDepth, 0.3, \vibratoFreq, 2, \actave, 1, \reverb, 0.5, \parFreq, 0.3, \pan2Freq, 0.6, \vibratoFreq, 1, \vibratoDepth, 0.1);
osc.sendMsg("/s_new", \sine, ~scene1n4, 1, 0, \freq, 415.305, \amp, 0, \vibratoDepth, 0.3, \vibratoFreq, 5, \actave, 1, \reverb, 0.5, \parFreq, 0.1, \pan2Freq, 0.2, \vibratoFreq, 1, \vibratoDepth, 0.1);
osc.sendMsg("/s_new", \sine, ~scene1n5, 1, 0, \freq, 440, \amp, 0, \vibratoDepth, 0.1, \vibratoFreq, 1.5, \actave, 1, \reverb, 0.5, \parFreq, 0.1, \pan2Freq, 0.2, \vibratoFreq, 1, \vibratoDepth, 0.1);
)


// play, vol control
(
var osc = NetAddr.new("localhost", 57110);
var masterVol = 1.0;

osc.sendMsg("/n_set", ~scene1n1, \amp, 1*masterVol);
osc.sendMsg("/n_set", ~scene1n2, \amp, 1*masterVol);
osc.sendMsg("/n_set", ~scene1n3, \amp, 1*masterVol);
osc.sendMsg("/n_set", ~scene1n4, \amp, 1*masterVol);
osc.sendMsg("/n_set", ~scene1n5, \amp, 1*masterVol);
)


(
var osc = NetAddr.new("localhost", 57110);
var distort = 0.0;

osc.sendMsg("/n_set", ~scene1n1, \distort, distort);
osc.sendMsg("/n_set", ~scene1n2, \distort, distort);
osc.sendMsg("/n_set", ~scene1n3, \distort, distort);
osc.sendMsg("/n_set", ~scene1n4, \distort, distort);
osc.sendMsg("/n_set", ~scene1n5, \distort, distort);
)


(
var osc = NetAddr.new("localhost", 57110);
var ice = 0.3;
var parFreq = 2;

osc.sendMsg("/n_set", ~scene1n1, \ice, 0.7*ice, \parFreq, 2*parFreq);
osc.sendMsg("/n_set", ~scene1n2, \ice, 0.3*ice, \parFreq, 4*parFreq);
osc.sendMsg("/n_set", ~scene1n3, \ice, 0.5*ice, \parFreq, 3*parFreq);
osc.sendMsg("/n_set", ~scene1n4, \ice, 0.8*ice, \parFreq, 1*parFreq);
osc.sendMsg("/n_set", ~scene1n5, \ice, 0.8*ice, \parFreq, 1*parFreq);
)

(
var osc = NetAddr.new("localhost", 57110);

osc.sendMsg("/n_set", ~scene1n1, \freq, 369.994/1, \amp, 1);
osc.sendMsg("/n_set", ~scene1n2, \freq, 329.628/2, \amp, 1);
osc.sendMsg("/n_set", ~scene1n3, \freq, 277.183/1, \amp, 1);
osc.sendMsg("/n_set", ~scene1n4, \freq, 415.305/4, \amp, 1);
osc.sendMsg("/n_set", ~scene1n4, \freq, 440/8, \amp, 1);
)

(
var osc = NetAddr.new("localhost", 57110);
var vibrato = 0.4;

osc.sendMsg("/n_set", ~scene1n1, \vibratoDepth, 1*vibrato, \vibratoFreq, 1);
osc.sendMsg("/n_set", ~scene1n2, \vibratoDepth, 0.7*vibrato, \vibratoFreq, 3);
osc.sendMsg("/n_set", ~scene1n3, \vibratoDepth, 0.5*vibrato, \vibratoFreq, 2);
osc.sendMsg("/n_set", ~scene1n4, \vibratoDepth, 0.6*vibrato, \vibratoFreq, 5);
osc.sendMsg("/n_set", ~scene1n5, \vibratoDepth, 0.4*vibrato, \vibratoFreq, 3.5);
)


// fire


Ndef(\fire).play(vol: 0, numChannels: 2, fadeTime: 1);
Ndef(\fire).stop;
Ndef(\fire).clear;
(
Ndef(\fire,{|amp = 3, freq = 0.8, lpf = 100000, hpf = 800|
	x=DelayL.ar(n=Ndef(\fire);n.ar,2,LFNoise0.kr(3.5*_!4)+1)+Blip.ar(freq);
	y=amp*LeakDC.ar(HPF.ar(LPF.ar(x+x.mean*0.15,lpf), hpf)).sin;
	y
});
)

Ndef(\fire).set(\amp, 3.0, \freq, 0.8, \lpf, 100000, \hpf, 800);
Ndef(\fire).set(\amp, 0);


// ---------scene2---------

(
var osc = NetAddr.new("localhost", 57110);
var masterVol = 1;
var ice = 0.8;

osc.sendMsg("/n_set", ~scene1n1, \vibratoDepth, \freq, 369.994, \amp, masterVol, \parFreq, 0.3, \pan2Freq, 0.1, \vibratoDepth, 0.3, \vibratoFreq, 3, \actave, 1, \reverb, 0.7, \ice, ice);
osc.sendMsg("/n_set", ~scene1n2, \freq, 329.628*2, \amp, masterVol, \vibratoDepth, 0.3, \vibratoFreq, 1, \actave, 1, \reverb, 0.5, \parFreq, 0.4, \pan2Freq, 0.12, \vibratoFreq, 1, \vibratoDepth, 0.1, \ice, ice);
osc.sendMsg("/n_set", ~scene1n3, \freq, 277.183*2, \amp, masterVol, \vibratoDepth, 0.3, \vibratoFreq, 2, \actave, 1, \reverb, 0.5, \parFreq, 0.3, \pan2Freq, 0.6, \vibratoFreq, 1, \vibratoDepth, 0.1, \ice, ice);
osc.sendMsg("/n_set", ~scene1n4, \freq, 415.305, \amp, masterVol, \vibratoDepth, 0.3, \vibratoFreq, 5, \actave, 1, \reverb, 0.5, \parFreq, 0.1, \pan2Freq, 0.2, \vibratoFreq, 1, \vibratoDepth, 0.1, \ice, ice);
osc.sendMsg("/n_set", ~scene1n5, \freq, 440, \amp, masterVol, \vibratoDepth, 0.1, \vibratoFreq, 1.5, \actave, 1, \reverb, 0.5, \parFreq, 0.1, \pan2Freq, 0.2, \vibratoFreq, 1, \vibratoDepth, 0.1, \ice, ice);
)


// ---------scene3---------



// ---------scene4---------



// node free
(
var osc = NetAddr.new("localhost", 57110);
osc.sendMsg("n_free", 1002);
osc.sendMsg("n_free", 1006);
osc.sendMsg("n_free", 1007);
)

(
var osc = NetAddr.new("localhost", 57110);
~backgroundNode = 1002;
~scene4n1 = 1006;
~scene4n2 = 1007;

osc.sendMsg("/s_new", \background, ~backgroundNode, 1, 0, \amp, 0);


osc.sendMsg("/s_new", \sine, ~scene4n1, 1, 0, \freq, 528, \amp, 0, \parFreq, 0.3, \pan2Freq, 0.1, \vibratoDepth, 0.3, \vibratoFreq, 3, \actave, 1, \reverb, 0.7);

osc.sendMsg("/s_new", \sine, ~scene4n2, 1, 0, \freq, 396, \amp, 0, \vibratoDepth, 0.3, \vibratoFreq, 1, \actave, 1, \reverb, 0.5, \parFreq, 0.4, \pan2Freq, 0.12, \vibratoFreq, 1, \vibratoDepth, 0.1);
)

(
var osc = NetAddr.new("localhost", 57110);

var masterVol = 1;
var ice = 0.2;


osc.sendMsg("/n_set", ~backgroundNode, \amp, 0.5*masterVol);

osc.sendMsg("/n_set", ~scene4n1, \vibratoDepth, 0.3, \freq, 528, \amp, 1*masterVol, \parFreq, 0.3, \pan2Freq, 0.1, \vibratoDepth, 0.01, \vibratoFreq, 3, \actave, 1, \reverb, 0.7, \ice, ice);
osc.sendMsg("/n_set", ~scene4n2, \freq, 396, \amp, 1*masterVol, \vibratoDepth, 0.3, \vibratoFreq, 1, \actave, 1, \reverb, 0.5, \parFreq, 0.4, \pan2Freq, 0.12, \vibratoFreq, 1, \vibratoDepth, 0.01, \ice, ice);
)


