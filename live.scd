Ndef(\fire).play(vol: 0, numChannels: 4, fadeTime: 1);
Ndef(\fire).stop;
Ndef(\fire).clear;
(
Ndef(\fire,{|amp = 3.5, freq = 1, lpf = 100000, hpf = 1100|
	x=DelayL.ar(n=Ndef(\fire);n.ar,2,LFNoise0.kr(3.5*_!4)+1)+Blip.ar(freq);
	y=amp*LeakDC.ar(HPF.ar(LPF.ar(x+x.mean*0.15,lpf), hpf)).sin;
	y
});
)

Ndef(\fire).set(\amp, 5.0, \freq, 0.9, \lpf, 100000, \hpf, 1000);
Ndef(\fire).set(\amp, 0);


(
SynthDef("FastSinSynthSc", {
	arg out, sustain=1, decay=0, pan=0, freq=110, accelerate=0, vibratoFreq=10, vibratoDepth=0, amp=1;
	var fglide, detune, sound, sig1, sig2, env, parFreq;
	detune = 1.0;
	freq = freq *(1+((LFPar.ar(vibratoFreq)+1)*(vibratoDepth/50)));
	sig1 = SinOsc.ar(freq).dup;
	sig2 = SinOsc.ar(freq * detune).dup * 0.1;
	sound = (sig1 + sig2) * 0.5;
	parFreq = 0.8 + EnvGen.ar(Env.linen(0, 0, 0.6, 10, -7), timeScale:sustain);
	sound = sound*LFPar.kr(parFreq); // tremoro
	env = EnvGen.ar(Env.linen(0, 0, 0.6, 1, -2), timeScale:sustain, doneAction:2);
	sound = sound * amp;
	sound = [
		0,sound,0,0
	];
	Out.ar(out, sound*env);
}).add;
)

Synth(\FastSinSynthSc, [\sustain, 10, \freq, 1760/2, \amp, 0.1])

(
SynthDef("testsine", {
	arg out, sustain=1, pan=0, freq=110, amp=1;
	var sound, env;
	sound = SinOsc.ar(freq);
	env = EnvGen.ar(Env.linen(0, 0, 0.6, 1, -2), timeScale:sustain, doneAction:2);
	sound = sound * amp * 0.3;
	sound = [
		0,0,0,sound
	];
	Out.ar(out, sound*env);
}).add;
)

Synth(\testsine, [\sustain, 2, \freq, 110, \amp, 1])


(
DirtPan.defaultPanningFunction = { |signals, numChannels, pan, mul|
	DirtSplayAz.ar(
		numChannels,
		signals,
		\span.ir(1),
		pan,
		mul,
		\splay.ir(1),
		\panwidth.ir(2),
		\orientation.ir(0)
	)
};

~dirt.loadSynthDefs;
)


(
var osc = NetAddr.new("localhost", 57120);

osc.sendMsg("/dirt/play", "gain", 0.7, "s", "FastSinSynthSc", "sustain", 5, "freq", 1760/2);
)


(
SynthDef("noisemanEndless", {
	arg amp=1, freq=110, accelerate=0, vibratoFreq=10, vibratoDepth=0, x, y;
	var out=0, sound, env;
	freq = freq *(1+((LFPar.ar(vibratoFreq)+1)*(vibratoDepth/50)));
	sound = PinkNoise.ar(1!2);
	sound = BPF.ar(sound, freq) * 2;
	sound = Pan4.ar(sound[0], x, y);
	Out.ar(out, sound*0.3*amp);
}, [3, 3]).add;
)

e = Synth("noisemanEndless", [\amp, 0.1, \freq, 1000, \x, 0, \y, 0])

e.set(\amp, 0.7);
e.set(\freq, 500);
e.set(\x, 1, \y, 0);
e.set(\amp, 0);

(
SynthDef(\rain, {
	arg amp=1;
    var sig, out=0;
    sig = { TRand.ar(-1, 1, Dust.ar(25000)) };
	sig = BPF.ar(sig, 100, 0.5);
	sig = HPF.ar(sig, 6000);
	sig = LPF.ar(sig, 5000);
	sig = sig*10*amp;
	sig = [
		0,0,0,0,sig
	];
	Out.ar(out, sig);
}, [30]).add;
)

r = Synth(\rain, [\amp, 0.1])

r.set(\amp, 0)


(
SynthDef("sunsetForest", {
	arg amp=1, groundNoise=0;
	var a, out=0;
	a=PinkNoise.ar(1);
	75.do{
		a=BBandStop.ar(a,LFNoise1.kr(0.01.rand).range(10,2500),Rand(0.9,1))
	};
	a=LPF.ar(a,7800);
	a=HPF.ar(a,1500-(groundNoise*1400));
	a = [0,0,0,0,a];
	Out.ar(out, amp * a * 5);
}, [5, 1]).add;
)


f = Synth(\sunsetForest, [\amp, 0])
f.set(\amp, 0)



