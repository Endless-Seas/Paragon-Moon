using System;
using System.Collections.Generic;
using System.Linq;

public static class Program {
	static Dictionary<string, Dmi> cache = new Dictionary<string, Dmi>();
	public static Dmi Get(string path) { Dmi d; if (!cache.TryGetValue(path, out d)) { d = Dmi.Load(path); cache[path] = d; } return d; }

	public static int Mul(int c, int tint) {
		int a = (c >> 24) & 0xFF; if (a == 0) return 0;
		int r = ((c >> 16) & 0xFF) * ((tint >> 16) & 0xFF) / 255, g = ((c >> 8) & 0xFF) * ((tint >> 8) & 0xFF) / 255, b = (c & 0xFF) * (tint & 0xFF) / 255;
		return (a << 24) | (r << 16) | (g << 8) | b;
	}
	public static int Over(int dst, int src) {
		int sa = (src >> 24) & 0xFF; if (sa == 255) return src; if (sa == 0) return dst;
		int da = (dst >> 24) & 0xFF; int oa = sa + da * (255 - sa) / 255; if (oa == 0) return 0;
		Func<int, int> ch = sh => ((((src >> sh) & 0xFF) * sa + ((dst >> sh) & 0xFF) * da * (255 - sa) / 255) / oa) & 0xFF;
		return (oa << 24) | (ch(16) << 16) | (ch(8) << 8) | ch(0);
	}

	//spec: file.dmi:state[@RRGGBB][#frame]  layers joined with '+'
	public static int[][] Compose(string spec, out int w, out int h) {
		int[][] result = null; w = 32; h = 32;
		foreach (var layer in spec.Split('+')) {
			string s = layer; int tint = -1; int frame = 0;
			int hash = s.LastIndexOf('#'); if (hash > 0) { frame = int.Parse(s.Substring(hash + 1)); s = s.Substring(0, hash); }
			int at = s.LastIndexOf('@'); if (at > 0) { tint = Convert.ToInt32(s.Substring(at + 1), 16); s = s.Substring(0, at); }
			int colon = s.LastIndexOf(':'); var dmi = Get(s.Substring(0, colon)); var st = dmi.Find(s.Substring(colon + 1));
			if (st == null) throw new Exception("missing state " + s);
			w = dmi.W; h = dmi.H;
			if (result == null) { result = new int[Math.Max(4, st.Dirs)][]; for (int i = 0; i < result.Length; i++) result[i] = new int[w * h]; }
			for (int d = 0; d < result.Length; d++) {
				var ic = st.Get(Math.Min(d, st.Dirs - 1), Math.Min(frame, st.Frames - 1));
				for (int p = 0; p < ic.Length; p++) result[d][p] = Over(result[d][p], tint >= 0 ? Mul(ic[p], tint) : ic[p]);
			}
		}
		return result;
	}

	public static int Main(string[] args) {
		try {
			switch (args[0]) {
				case "list": {
					var d = Get(args[1]); string f = args.Length > 2 ? args[2] : null;
					Console.WriteLine(d.W + "x" + d.H + " states=" + d.States.Count);
					foreach (var s in d.States) if (f == null || s.Name.Contains(f)) Console.WriteLine(s.Name + "\t" + s.Dirs + "d" + (s.Frames > 1 ? " " + s.Frames + "f" : ""));
					return 0;
				}
				case "preview": { //preview out.png scale row1 row2 ...
					var rows = new List<KeyValuePair<string, int[][]>>(); int w = 32, h = 32;
					for (int i = 3; i < args.Length; i++) rows.Add(new KeyValuePair<string, int[][]>(args[i], Compose(args[i], out w, out h)));
					Dmi.Preview(args[1], int.Parse(args[2]), rows, w, h); return 0;
				}
				case "roundtrip": { Get(args[1]).Save(args[2]); return 0; }
				default:
					if (args[0]=="strays") { Strays.Run(args[1], args.Length < 3 || args[2] != "orig", 20); return 0; } if (args[0]=="probe") { Probe.Run(args[1]); return 0; } if (args[0]=="desc") { Desc.Run(args[1]); return 0; } if (args[0]=="strip") { Strip.Run(args[1], args[2]); return 0; } if (args[0]=="dump") { Dump.Run(args[1], int.Parse(args[2])); return 0; } if (args[0]=="same") { System.Console.WriteLine(Verify.Same(args[1], args[2])); return 0; } return Digi.Run(args);
			}
		} catch (Exception e) { Console.Error.WriteLine(e); return 1; }
	}
}
