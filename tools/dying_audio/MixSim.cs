//Mix simulation for the dying decline: plays the layers together the way dying_decline.dm's apply_layers() mixes
//them, at a spread of intensities and start offsets, and reports the worst peak - anything over ~0.95 will crackle.
//The layer windows below mirror the DYING_* defines; keep them in step if you change either.
//Build: csc /platform:x64 /out:mixsim.exe MixSim.cs   Run: mixsim.exe <repo>\sound\health 0.87 0.21 0.85
//(the three numbers are DYING_CREST_ONE, DYING_CREST_STEP, DYING_DRONE_TARGET). Set NOBEAT=1 to leave the heartbeat out.
using System;
using System.Runtime.InteropServices;
static class MixSim
{
	[StructLayout(LayoutKind.Sequential)] struct SF_INFO { public long frames; public int samplerate, channels, format, sections, seekable; }
	[DllImport("kernel32", CharSet = CharSet.Unicode)] static extern bool SetDllDirectory(string p);
	[DllImport("sndfile.dll", CallingConvention = CallingConvention.Cdecl, CharSet = CharSet.Ansi)] static extern IntPtr sf_open(string path, int mode, ref SF_INFO info);
	[DllImport("sndfile.dll", CallingConvention = CallingConvention.Cdecl)] static extern long sf_readf_float(IntPtr f, float[] buf, long frames);
	[DllImport("sndfile.dll", CallingConvention = CallingConvention.Cdecl)] static extern int sf_close(IntPtr f);
	static float[] Load(string p)
	{
		SF_INFO info = new SF_INFO(); IntPtr f = sf_open(p, 0x10, ref info);
		float[] b = new float[info.frames * info.channels]; sf_readf_float(f, b, info.frames); sf_close(f);
		if (info.channels == 1) return b;
		float[] m = new float[info.frames]; for (long i = 0; i < info.frames; i++) m[i] = (b[2 * i] + b[2 * i + 1]) / 2; return m;
	}
	static double Ss(double a, double b, double x) { double t = Math.Max(0, Math.Min(1, (x - a) / (b - a))); return t * t * (3 - 2 * t); }

	static void Main(string[] a)
	{
		SetDllDirectory(@"C:\Program Files\Audacity");
		string h = a[0];
		float[][] L = { Load(h + @"\dying_pulse.ogg"), Load(h + @"\dying_low.ogg"), Load(h + @"\dying_rise.ogg"), Load(h + @"\dying_grind.ogg"), Load(h + @"\slowbeat.ogg") };
		int sr = 44100, n = L[1].Length;
		double[][] offs = { new double[] { 0, 0, 0, 0 }, new double[] { 3.7, 9.1, 5.2, 2 }, new double[] { 7.3, 2.2, 12.1, 9 }, new double[] { 11.9, 5.5, 1.3, 4 }, new double[] { 1.1, 14.3, 8.8, 13 }, new double[] { 5, 10, 15, 7 } };
		double c1 = double.Parse(a[1]), step = double.Parse(a[2]), target = double.Parse(a[3]);
		{
			double Pmax = 0;
			double worstAll = 0;
			Console.WriteLine("crest " + c1 + " + " + step + "*(n-1), target " + target);
			foreach (double I in new double[] { 0.04, 0.09, 0.13, 0.18, 0.22, 0.27, 0.32, 0.38, 0.43, 0.48, 0.53, 0.58, 0.63, 0.68, 0.75 })
			{
				double pu = Ss(0, 0.088, I) * (1 - Ss(0.15, 0.3, I)), lo = Ss(0.088, 0.206, I) * (1 - Ss(0.45, 0.676, I)), ri = Ss(0.206, 0.471, I) * (1 - 0.75 * Ss(0.5, 0.676, I)), gr = Ss(0.353, 0.676, I);
				double p = pu * pu + lo * lo + ri * ri + gr * gr, sum = pu + lo + ri + gr;
				double neff = p > 0 ? sum * sum / p : 1;
				double crest = c1 + step * (neff - 1);
				Pmax = Math.Pow(target / crest, 2);
				double fit = p > Pmax ? Math.Sqrt(Pmax / p) : 1;
				double[] v = { fit * pu, fit * lo, fit * ri, fit * gr };
				double dv = fit * Math.Sqrt(p) * crest;
				double depth = Math.Min(1, I / 0.676);
				double beat = Environment.GetEnvironmentVariable("NOBEAT") != null ? 0 : Math.Max(0, Math.Min((40 + 10 * depth) / 100, (0.97 - dv) / 0.73));
				double worst = 0;
				foreach (double[] o in offs)
				{
					double pk = 0;
					for (int i = 0; i < n; i++)
					{
						double s = 0;
						for (int k = 0; k < 4; k++) { int sh = (int)(o[k == 0 ? 3 : k - 1] * sr * (k == 0 ? 1 : 1)); if (k == 1) sh = 0; s += L[k][(i + sh) % L[k].Length] * v[k]; }
						s += L[4][(i + (int)(o[3] * sr)) % L[4].Length] * beat;
						pk = Math.Max(pk, Math.Abs(s));
					}
					worst = Math.Max(worst, pk);
				}
				worstAll = Math.Max(worstAll, worst);
				Console.WriteLine("  neff=" + neff.ToString("F2") + " est=" + dv.ToString("F2") + " rms=" + (-8.5 + 20 * Math.Log10(Math.Max(fit * Math.Sqrt(p), 1e-9))).ToString("F1") + "dB");
				Console.WriteLine("  I=" + I.ToString("F2") + " vols " + (100 * v[0]).ToString("F0") + "/" + (100 * v[1]).ToString("F0") + "/" + (100 * v[2]).ToString("F0") + "/" + (100 * v[3]).ToString("F0") + " beat " + (100 * beat).ToString("F0") + "  worst peak " + worst.ToString("F2"));
			}
			Console.WriteLine("  => worst " + worstAll.ToString("F2"));
		}
	}
}
