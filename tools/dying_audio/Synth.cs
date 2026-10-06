// Procedural generator for the "slow decline" dying soundscape. Everything is synthesized here - no samples.
// Shaped after the structure (and loudness) of Casualties: Unknown's dying track: a saturated D1 / G#1 tritone
// underneath, a beating tone that bends up from C#4 to D4 with its octave and fifth, a saturated grind for the end,
// a final crescendo that stops dead, and a flatline over a low fade-out for death itself.
//
// Keeping it clean while it's loud:
// - Saturation is rendered at 4x oversampling, so it doesn't alias into fizz.
// - Noise (the rumble) is never pushed through saturation - distorted noise is exactly what sounds like static.
//   It's added afterwards as a clean low rumble.
// - Everything stays dark (like the reference, almost nothing above 1-2kHz), which is where fizz would live.
// - Loudness comes from a smooth look-ahead limiter shaving the peaks, not from clipping them.
// - Encoded at high Vorbis quality, since distorted material at low quality picks up swishy artifacts.
// The in-game mix keeps the layers' combined level under clipping too - see apply_layers() in dying_decline.dm.
//
// Writes Ogg Vorbis through libsndfile. Audacity ships one, so by default it's loaded from there;
// pass a different folder holding sndfile.dll as the second argument if needed.
// Build with build.bat, which also runs it.
using System;
using System.IO;
using System.Runtime.InteropServices;

static class Synth
{
	const int Rate = 44100;
	const int OS = 4; // oversampling factor for everything that gets saturated
	const int OSRate = Rate * OS;
	const double D1 = 36.71, GS1 = 51.91, D4 = 293.66, A5 = 880.0;
	/// Each loop on its own is a little louder than the reference's loud stretches; the limiter only takes the tallest peaks.
	const double LayerRmsDb = -8.5;
	/// Limiter ceiling. Vorbis overshoots a touch on decode, so this leaves room for it.
	const double Ceiling = 0.85;
	const double Quality = 0.8;

	static void Main(string[] args)
	{
		string root = args.Length > 0 ? args[0] : ".";
		string sndfileDir = args.Length > 1 ? args[1] : @"C:\Program Files\Audacity";
		if (!File.Exists(Path.Combine(sndfileDir, "sndfile.dll")))
		{
			Console.WriteLine("Can't find sndfile.dll in " + sndfileDir + " - install Audacity or pass a folder that has it.");
			Environment.Exit(1);
		}
		SetDllDirectory(sndfileDir);

		string health = Path.Combine(root, "sound", "health");
		Directory.CreateDirectory(health);
		WriteOgg(Path.Combine(health, "dying_pulse.ogg"), LoudLoop("pulse", Loop(16.0, 4.0, new PulseLayer(7)), LayerRmsDb));
		WriteOgg(Path.Combine(health, "dying_low.ogg"), LoudLoop("low", Loop(16.0, 4.0, new LowLayer(11)), LayerRmsDb));
		WriteOgg(Path.Combine(health, "dying_rise.ogg"), LoudLoop("rise", Loop(16.0, 4.0, new RiseLayer(22)), LayerRmsDb));
		WriteOgg(Path.Combine(health, "dying_grind.ogg"), LoudLoop("grind", Loop(16.0, 4.0, new GrindLayer(33)), LayerRmsDb));
		WriteOgg(Path.Combine(health, "dying_final.ogg"), FinalSwell(4.0));
		WriteOgg(Path.Combine(root, "sound", "misc", "deth.ogg"), FitPeak(Render(8.0, new Flatline(44)), 0.8, false));
		Console.WriteLine("Wrote dying_pulse/low/rise/grind/final.ogg and misc/deth.ogg");
	}

	// ---------------------------------------------------------------- building blocks

	abstract class Voice
	{
		/// One sample at time t (seconds), at OSRate.
		public abstract double Next(double t);
	}

	static double Sin(double f, double t) { return Math.Sin(2 * Math.PI * f * t); }
	static double Sat(double x, double drive) { return Math.Tanh(x * drive) / Math.Tanh(drive); }
	/// Lopsided saturation - adds the even harmonics that make it sound torn rather than buzzy.
	static double Tear(double x, double drive) { return (Math.Tanh(x * drive + 0.3) - Math.Tanh(0.3)) / Math.Tanh(drive); }
	static double Smooth(double x) { x = Math.Max(0, Math.Min(1, x)); return x * x * (3 - 2 * x); }

	/// RBJ low-pass biquad, cutoff can be changed per sample.
	class LowPass
	{
		double b0, b1, b2, a1, a2, x1, x2, y1, y2, rate;
		public LowPass(double cutoff, double sampleRate) { rate = sampleRate; Set(cutoff); }
		public void Set(double cutoff)
		{
			double w = 2 * Math.PI * cutoff / rate, q = 0.707, alpha = Math.Sin(w) / (2 * q), cos = Math.Cos(w), a0 = 1 + alpha;
			b0 = (1 - cos) / 2 / a0; b1 = (1 - cos) / a0; b2 = b0; a1 = -2 * cos / a0; a2 = (1 - alpha) / a0;
		}
		public double Run(double x)
		{
			double y = b0 * x + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2;
			x2 = x1; x1 = x; y2 = y1; y1 = y;
			return y;
		}
	}

	/// RBJ high-pass biquad. Used to keep the sub-bass to the low layer alone - every layer carrying the same low D means
	/// their peaks line up and add straight together in-game, which is what caps how loud the mix can go.
	class HighPass
	{
		double b0, b1, b2, a1, a2, x1, x2, y1, y2;
		public HighPass(double cutoff, double sampleRate)
		{
			double w = 2 * Math.PI * cutoff / sampleRate, alpha = Math.Sin(w) / (2 * 0.707), cos = Math.Cos(w), a0 = 1 + alpha;
			b0 = (1 + cos) / 2 / a0; b1 = -(1 + cos) / a0; b2 = b0; a1 = -2 * cos / a0; a2 = (1 - alpha) / a0;
		}
		public double Run(double x)
		{
			double y = b0 * x + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2;
			x2 = x1; x1 = x; y2 = y1; y1 = y;
			return y;
		}
	}

	/// Low rumble: white noise squeezed down into the bottom of the spectrum. Never saturate this.
	class Rumble
	{
		LowPass a = new LowPass(120, OSRate), b = new LowPass(120, OSRate);
		Random rng;
		public Rumble(Random r) { rng = r; }
		public double Next() { return b.Run(a.Run(rng.NextDouble() * 2 - 1)) * 6; }
	}

	/// Renders a voice at the oversampled rate and brings it down to 44.1k through an anti-alias FIR.
	static double[] Render(double seconds, Voice v)
	{
		int n = (int)(seconds * Rate);
		double[] hi = new double[n * OS];
		for (int i = 0; i < hi.Length; i++)
			hi[i] = v.Next((double)i / OSRate);
		return Decimate(hi);
	}

	static double[] Decimate(double[] hi)
	{
		const int taps = 127;
		double fc = 0.45 * Rate / OSRate; // keep up to ~19.8kHz
		double[] h = new double[taps];
		double sum = 0;
		for (int k = 0; k < taps; k++)
		{
			double m = k - (taps - 1) / 2.0;
			double sinc = m == 0 ? 2 * fc : Math.Sin(2 * Math.PI * fc * m) / (Math.PI * m);
			double win = 0.42 - 0.5 * Math.Cos(2 * Math.PI * k / (taps - 1)) + 0.08 * Math.Cos(4 * Math.PI * k / (taps - 1));
			h[k] = sinc * win;
			sum += h[k];
		}
		for (int k = 0; k < taps; k++)
			h[k] /= sum;
		double[] o = new double[hi.Length / OS];
		for (int i = 0; i < o.Length; i++)
		{
			int c = i * OS;
			double acc = 0;
			for (int k = 0; k < taps; k++)
			{
				int j = c + k - (taps - 1) / 2;
				if (j >= 0 && j < hi.Length)
					acc += hi[j] * h[k];
			}
			o[i] = acc;
		}
		return o;
	}

	/// Renders past the loop point and folds the overrun back over the start with an equal-power crossfade, so it loops seamlessly.
	static double[] Loop(double seconds, double fade, Voice voice)
	{
		int loopLen = (int)(seconds * Rate), fadeLen = (int)(fade * Rate);
		double[] s = Render(seconds + fade, voice);
		double[] o = new double[loopLen];
		for (int i = 0; i < loopLen; i++)
		{
			if (i < fadeLen)
			{
				double w = (double)i / fadeLen * Math.PI / 2;
				o[i] = s[i] * Math.Sin(w) + s[loopLen + i] * Math.Cos(w);
			}
			else
				o[i] = s[i];
		}
		return o;
	}

	static double Rms(double[] s)
	{
		double rs = 0;
		foreach (double v in s) rs += v * v;
		return Math.Sqrt(rs / s.Length);
	}

	static double[] Scaled(double[] s, double gain)
	{
		double[] o = new double[s.Length];
		for (int i = 0; i < s.Length; i++)
			o[i] = s[i] * gain;
		return o;
	}

	static double[] AtLayerLevel(double[] s) { return Scaled(s, Math.Pow(10, LayerRmsDb / 20) / Rms(s)); }

	static double[] Mix(double[] a, double wa, double[] b, double wb)
	{
		double[] o = new double[a.Length];
		for (int i = 0; i < o.Length; i++)
			o[i] = a[i] * wa + b[i] * wb;
		return o;
	}

	/// Smooth look-ahead limiter. The gain ramps down across the look-ahead before a peak instead of jumping,
	/// so it never clicks or crackles, then recovers slowly. Nothing past the ceiling gets out.
	/// preGain is applied first (per sample). wrap = treat the input as a loop, so the seam is settled.
	static double[] Limit(double[] x, double[] preGain, bool wrap)
	{
		int n = x.Length, look = Rate * 5 / 1000;
		double release = 1 - Math.Exp(-1.0 / (0.15 * Rate));
		int start = wrap ? n : 0, total = start + n + look;
		double[] v = new double[total], need = new double[total];
		for (int i = 0; i < total; i++)
		{
			int j = wrap ? i % n : Math.Min(i, n - 1);
			v[i] = x[j] * preGain[j];
			need[i] = Math.Min(1, Ceiling / Math.Max(Math.Abs(v[i]), 1e-9));
		}
		// held[i] = lowest gain needed anywhere in the last `look` samples, so every peak is covered for a whole window after it...
		double[] held = SlidingMin(need, look);
		// ...and averaging forward over the next window turns that into a ramp that has already arrived when the peak does.
		double[] gain = new double[total];
		double acc = 0;
		for (int i = total - 1; i >= 0; i--)
		{
			acc += held[i];
			if (i + look + 1 < total)
				acc -= held[i + look + 1];
			gain[i] = acc / Math.Min(look + 1, total - i);
		}
		double[] o = new double[n];
		double env = 1;
		for (int i = 0; i < start + n; i++)
		{
			env = gain[i] < env ? gain[i] : env + (gain[i] - env) * release;
			if (i >= start)
				o[i - start] = v[i] * env;
		}
		return o;
	}

	/// Minimum over the previous `len` samples (inclusive), via a monotonic deque.
	static double[] SlidingMin(double[] a, int len)
	{
		int n = a.Length;
		double[] o = new double[n];
		int[] dq = new int[n];
		int head = 0, tail = 0;
		for (int i = 0; i < n; i++)
		{
			while (tail > head && a[dq[tail - 1]] >= a[i]) tail--;
			dq[tail++] = i;
			while (dq[head] < i - len) head++;
			o[i] = a[dq[head]];
		}
		return o;
	}

	/// Pushes a loop up to the target RMS through the limiter.
	static float[] LoudLoop(string name, double[] s, double rmsDb)
	{
		double target = Math.Pow(10, rmsDb / 20);
		double lo = 0.05, hi = 50, gain = 1;
		double[] o = null;
		for (int iter = 0; iter < 16; iter++)
		{
			gain = Math.Sqrt(lo * hi);
			o = Limit(s, Fill(s.Length, gain), true);
			if (Rms(o) < target) lo = gain; else hi = gain;
		}
		Console.WriteLine("  " + name + ": " + (20 * Math.Log10(Rms(o))).ToString("F1") + "dB RMS, peak " + Peak(o).ToString("F2"));
		return ToFloat(o);
	}

	static double Peak(double[] s) { double p = 0; foreach (double v in s) p = Math.Max(p, Math.Abs(v)); return p; }
	static double[] Fill(int n, double v) { double[] o = new double[n]; for (int i = 0; i < n; i++) o[i] = v; return o; }

	static float[] ToFloat(double[] s)
	{
		float[] o = new float[s.Length];
		for (int i = 0; i < s.Length; i++)
			o[i] = (float)s[i];
		return o;
	}

	static float[] FitPeak(double[] s, double peak, bool keepEnd)
	{
		float[] o = ToFloat(Scaled(s, peak / Math.Max(Peak(s), 1e-9)));
		int ramp = Rate / 200; // 5ms in so nothing starts on a click
		for (int i = 0; i < ramp && i < o.Length; i++)
			o[i] *= (float)i / ramp;
		if (!keepEnd)
			for (int i = 0; i < ramp && i < o.Length; i++)
				o[o.Length - 1 - i] *= (float)i / ramp;
		return o;
	}

	// ---------------------------------------------------------------- the layers

	/// The first warning, from the reference's closing stretch: a lone low D throbbing every few seconds, nothing else.
	/// Saturated just enough to grow its octave and fifth (73, 110, 147Hz) so it carries on small speakers too.
	/// Tuned so the pulse and the tone both repeat exactly every 16s, for a clean loop.
	class PulseLayer : Voice
	{
		const double Root = 36.75; // D1, nudged so 16s holds a whole number of cycles
		const double Period = 16.0 / 6; // six throbs per loop
		LowPass lp = new LowPass(700, OSRate), lp2 = new LowPass(700, OSRate);
		Rumble rumble;
		public PulseLayer(int seed) { rumble = new Rumble(new Random(seed)); }
		public override double Next(double t)
		{
			double phase = (t % Period) / Period;
			// Swells in over the first fifth, sinks away over the rest, never quite to nothing.
			double env = phase < 0.2 ? Smooth(phase / 0.2) : Math.Exp(-(phase - 0.2) * 3.2);
			env = 0.18 + 0.82 * env;
			double v = Sin(Root, t) + 0.35 * Sin(Root * 2, t) + 0.15 * Sin(Root * 3, t);
			return lp2.Run(lp.Run(Sat(v * env * 0.8, 1.8))) + 0.06 * env * rumble.Next();
		}
	}

	/// D1 against G#1, saturated so it grows a dirty harmonic tail, kept dark. Slow ~4s swells.
	class LowLayer : Voice
	{
		LowPass lp = new LowPass(900, OSRate);
		Rumble rumble;
		public LowLayer(int seed) { rumble = new Rumble(new Random(seed)); }
		public override double Next(double t)
		{
			double swell = 0.7 + 0.3 * Sin(0.25, t);
			double v = Sin(D1, t) + 0.85 * Sin(GS1, t) + 0.25 * Sin(D1 * 2, t + 0.01);
			return lp.Run(swell * Sat(v * 0.6, 2.4)) + 0.12 * swell * rumble.Next();
		}
	}

	/// The same machine as the low layer, a little higher up: the G#1 harmonic bed it already implies,
	/// with the beating D4 (plus octave and its A5 fifth) growing out of it. Pitched up in-game from C#4.
	/// No sub of its own - that's the low layer's job - so the two never stack up in-game.
	class RiseLayer : Voice
	{
		LowPass lp = new LowPass(1400, OSRate), lp2 = new LowPass(1400, OSRate);
		HighPass hp = new HighPass(90, OSRate), hp2 = new HighPass(90, OSRate);
		public RiseLayer(int seed) { }
		public override double Next(double t)
		{
			double swell = 0.7 + 0.3 * Sin(0.25, t + 1.3);
			double bed = 0.35 * Sin(GS1 * 3, t) * (0.8 + 0.2 * Sin(0.07, t))
				+ 0.25 * Sin(GS1 * 4, t) * (0.8 + 0.2 * Sin(0.11, t + 2))
				+ 0.2 * Sin(GS1 * 5, t) * (0.8 + 0.2 * Sin(0.13, t + 5));
			double tone = Sin(D4, t) + 0.8 * Sin(D4 + 0.75, t)
				+ 0.45 * Sin(D4 * 2, t) + 0.25 * Sin(D4 * 2 + 2.6, t)
				+ 0.18 * Sin(D4 * 3, t);
			double v = 0.3 * Sin(D1, t) + 0.6 * bed + 0.45 * tone;
			return hp2.Run(hp.Run(lp2.Run(lp.Run(swell * Sat(v * 0.7, 2.2)))));
		}
	}

	/// Everything piled together and torn apart, throbbing just under once a second. The growl comes from the tones
	/// being driven hard into lopsided saturation - D1's own harmonics (73, 110, 147Hz) like the reference's - not from noise.
	/// It's the one complete layer - sub, growl and tone - since it carries the last stretch on its own as the others sink under it.
	class GrindLayer : Voice
	{
		LowPass lp = new LowPass(1600, OSRate), lp2 = new LowPass(1600, OSRate);
		Rumble rumble;
		public GrindLayer(int seed) { rumble = new Rumble(new Random(seed)); }
		public override double Next(double t)
		{
			double throb = 0.6 + 0.4 * Sin(0.9, t);
			double v = Sin(D1, t) + Sin(GS1, t) + 0.7 * Sin(D4, t) + 0.5 * Sin(D4 + 1.1, t) + 0.4 * Sin(D4 * 2, t)
				+ 0.5 * Sin(D1 * 2, t + 0.3) * throb;
			double y = Tear(v * 0.35, 3.5) * (0.75 + 0.25 * throb);
			return lp2.Run(lp.Run(y)) + 0.2 * throb * rumble.Next();
		}
	}

	/// Four seconds, as in the first version, modelled straight on the reference's climax: everything piles on, the drive
	/// climbs into heavy saturation, the high tone keeps bending up and it swells from quiet to a full peak - then it just
	/// stops. This is the one sound that's meant to tear, so it's left unlimited and allowed to hit the top.
	static float[] FinalSwell(double seconds)
	{
		int len = (int)(seconds * Rate);
		Random rng = new Random(1337);
		double[] s = new double[len];
		double lp = 0, rumble = 0, phaseHi = 0;
		for (int i = 0; i < len; i++)
		{
			double t = (double)i / Rate;
			double p = t / seconds; // 0 -> 1
			double hi = D4 * Math.Pow(2, p * 2.0 / 12); // bends up a further whole tone
			phaseHi += 2 * Math.PI * hi / Rate;
			rumble += 0.05 * ((rng.NextDouble() * 2 - 1) - rumble);
			double v = Sin(D1, t) + 0.9 * Sin(GS1, t)
				+ (0.4 + 0.8 * p) * (Math.Sin(phaseHi) + 0.7 * Math.Sin(phaseHi * 1.0026) + 0.5 * Math.Sin(phaseHi * 2))
				+ (1 + 5 * p) * rumble;
			double y = Sat(v * 0.5, 1.5 + 9 * p * p);
			lp += (0.15 + 0.5 * p) * (y - lp); // opens up as it climbs
			s[i] = lp * (0.25 + 0.75 * Math.Pow(p, 1.6));
		}
		float[] o = ToFloat(Scaled(s, 0.98 / Math.Max(Peak(s), 1e-9)));
		for (int i = 0; i < Rate / 100; i++)
			o[i] *= (float)i / (Rate / 100); // soften only the first few ms
		Console.WriteLine("  final: " + (20 * Math.Log10(Rms(s) * 0.98 / Peak(s))).ToString("F1") + "dB RMS, peaking at the very end");
		return o; // no fade out on purpose
	}

	/// Death itself: a monitor flatline on A5 - the fifth of the drone's D, so it still belongs - over a low D
	/// that fades out and closes up as it goes, like hearing leaving. Starts out of the silence after the cutoff.
	class Flatline : Voice
	{
		LowPass lowLp = new LowPass(500, OSRate), lowLp2 = new LowPass(500, OSRate);
		LowPass toneLp = new LowPass(4000, OSRate);
		Rumble rumble;
		public Flatline(int seed) { rumble = new Rumble(new Random(seed)); }
		public override double Next(double t)
		{
			// The low drone: D1 and its octave only - the tritone has resolved. Fades out over the whole 8s.
			double lowEnv = Math.Exp(-t / 2.6) * Smooth(t / 0.4);
			double cutoff = 500 * Math.Exp(-t / 3.0) + 60;
			lowLp.Set(cutoff); lowLp2.Set(cutoff);
			double low = lowLp2.Run(lowLp.Run(Sat((Sin(D1, t) + 0.5 * Sin(D1 * 2, t)) * 0.8, 2.0))) + 0.2 * rumble.Next();

			// The flatline: steady and flat for a long while, then fading with everything else.
			double toneEnv = Smooth(t / 0.03) * (t < 5.0 ? 1.0 : Math.Exp(-(t - 5.0) / 0.9));
			double tone = toneLp.Run(Sin(A5, t) + 0.12 * Sin(A5 * 2, t) + 0.04 * Sin(A5 * 3, t));

			return 0.9 * lowEnv * low + 0.32 * toneEnv * tone;
		}
	}

	// ---------------------------------------------------------------- output

	[StructLayout(LayoutKind.Sequential)]
	struct SF_INFO { public long frames; public int samplerate, channels, format, sections, seekable; }
	const int SFM_WRITE = 0x20, SF_FORMAT_OGG_VORBIS = 0x200060, SFC_SET_VBR_ENCODING_QUALITY = 0x1300;
	[DllImport("kernel32", CharSet = CharSet.Unicode)] static extern bool SetDllDirectory(string path);
	[DllImport("sndfile.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)] static extern IntPtr sf_open(string path, int mode, ref SF_INFO info);
	[DllImport("sndfile.dll", CallingConvention = CallingConvention.Cdecl)] static extern int sf_command(IntPtr f, int cmd, ref double data, int size);
	[DllImport("sndfile.dll", CallingConvention = CallingConvention.Cdecl)] static extern long sf_writef_float(IntPtr f, float[] buf, long frames);
	[DllImport("sndfile.dll", CallingConvention = CallingConvention.Cdecl)] static extern int sf_close(IntPtr f);
	[DllImport("sndfile.dll", CallingConvention = CallingConvention.Cdecl)] static extern IntPtr sf_strerror(IntPtr f);

	static void WriteOgg(string path, float[] samples)
	{
		SF_INFO info = new SF_INFO();
		info.samplerate = Rate;
		info.channels = 1;
		info.format = SF_FORMAT_OGG_VORBIS;
		IntPtr f = sf_open(path, SFM_WRITE, ref info);
		if (f == IntPtr.Zero)
			throw new Exception("Couldn't write " + path + ": " + Marshal.PtrToStringAnsi(sf_strerror(IntPtr.Zero)));
		double quality = Quality;
		sf_command(f, SFC_SET_VBR_ENCODING_QUALITY, ref quality, 8);
		sf_writef_float(f, samples, samples.Length);
		sf_close(f);
	}
}
