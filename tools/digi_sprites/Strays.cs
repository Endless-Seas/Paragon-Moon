using System; using System.Linq;
public static class Strays { public static void Run(string path, bool onlyDigi, int fromRow) {
	var d = Dmi.Load(path); int w = d.W, h = d.H, off = h - 32;
	foreach (var s in d.States) { if (onlyDigi && !(s.Name.EndsWith("_digi") || s.Name.Contains("_digi_"))) continue;
		for (int i = 0; i < s.Icons.Count && i < 4; i++) { var p = s.Icons[i]; var hits = new System.Collections.Generic.List<string>();
			for (int y = off + fromRow; y < h; y++) for (int x = 0; x < w; x++) { if (((p[y*w+x]>>24)&0xFF)==0) continue;
				bool n = false; for (int dy=-1; dy<=1; dy++) for (int dx=-1; dx<=1; dx++) { int nx=x+dx, ny=y+dy; if ((dx!=0||dy!=0) && nx>=0 && nx<w && ny>=0 && ny<h && ((p[ny*w+nx]>>24)&0xFF)!=0) n = true; }
				if (!n) hits.Add(x+","+(y-off)); }
			if (hits.Count > 0) Console.WriteLine(System.IO.Path.GetFileName(path)+" "+s.Name+" dir"+i+": "+string.Join(" ", hits)); } } } }
