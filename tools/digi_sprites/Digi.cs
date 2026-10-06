using System;
using System.Collections.Generic;
using System.Linq;

public class Shape {
	public bool Female;
	public int LegTop = 23; //first row of the lower-leg sprite: 23 standard, 24 slim female, 25 short, 27 dwarf, 28 short dwarf
	public static Shape For(string stateName, bool forceFemale, int forceTop) {
		var tokens = stateName.Split('_');
		var s = new Shape { Female = forceFemale || tokens.Contains("f") };
		if (s.Female) s.LegTop = 24;
		if (forceTop > 0) s.LegTop = forceTop;
		else if (tokens.Contains("dwarf")) s.LegTop = 27;
		return s;
	}
}

//Reshapes leg rows into the tgstation digitigrade silhouette (lizard/bodyparts.dmi "digitigrade_*_leg", CC BY-SA 3.0) using
//the item's own pixels per row: shape from TG, texture from Roguetown. Female and short bodies get narrowed/resampled versions.
public static class Digi {
	//TG silhouette, front/back, left leg (right leg mirrors about the x = 15 gap column). Index = TG row - 20. {x0, x1} inclusive.
	static readonly int[][] FrontLeft = {
		null, null, null,                                                  //20-22 thighs: TG flares 1px past Roguetown hips, left to the chest sprite
		new[]{11,14}, new[]{11,14}, new[]{11,14}, new[]{11,14},            //23-26 knee, kept to Roguetown leg width
		new[]{12,14}, new[]{12,14}, new[]{12,14},                          //27-29 slim metatarsus
		new[]{11,14}, new[]{11,14},                                        //30-31 clawed toes
	};
	//TG silhouette, side view facing east: {back leg x0,x1, front leg x0,x1}; null = untouched. West mirrors.
	//Front leg pulled up to 2px back from TG's so the waist stays inside the belly line (x <= 18); only toes reach past.
	static readonly int[][] SideEast = {
		null,
		new[]{12,15, 16,18}, new[]{12,15, 16,18},                                    //21-22 hips
		new[]{12,15, 16,18}, new[]{12,15, 16,18}, new[]{11,14, 15,18}, new[]{11,14, 15,17}, //23-26 knee
		new[]{11,14, 15,17}, new[]{10,13, 15,17}, new[]{10,13, 15,18},               //27-29 hock
		new[]{11,14, 16,19}, new[]{11,14, 16,19},                                    //30-31 toes
	};
	const int TgLegTop = 23;
	public const double BackLegShade = 0.85;

	//TG silhouette row for output row y on a body whose lower leg starts at `top` (-1 = untouched): 3 thigh rows above, toes fixed, shin resampled.
	public static int TgRow(int y, int top) {
		if (y < top - 3) return -1;
		if (y < top) return 20 + (y - (top - 3));
		if (y >= 30) return y;
		int shinRows = 30 - top, tgShin = 30 - TgLegTop; //rows top..29 -> TG rows 23..29
		return TgLegTop + (shinRows <= 1 ? 0 : (int)Math.Round((y - top) * (tgShin - 1) / (double)(shinRows - 1)));
	}

	static int[] FrontSeg(Shape s, int tgRow, bool right) {
		var seg = FrontLeft[tgRow - 20]; if (seg == null) return null;
		int x0 = seg[0], x1 = seg[1];
		if (s.Female) x0 += 1; //slimmer legs: outer edge pulled in, TG's 2px gap between the legs kept
		return right ? new[] { 30 - x1, 30 - x0 } : new[] { x0, x1 }; //legs are symmetric about the x=15 gap column
	}
	static int[] SideSeg(Shape s, int tgRow) {
		var seg = SideEast[tgRow - 20]; if (seg == null) return null;
		var r = (int[])seg.Clone();
		if (s.Female) { r[0] += 1; r[3] -= 1; } //each leg one pixel slimmer, trimmed on its outer side
		return r;
	}

	static bool Opaque(int c) { return ((c >> 24) & 0xFF) != 0; }
	static int Shade(int c, double f) {
		if (!Opaque(c)) return c;
		int r = (int)(((c >> 16) & 0xFF) * f), g = (int)(((c >> 8) & 0xFF) * f), b = (int)((c & 0xFF) * f);
		return (int)((uint)c & 0xFF000000u) | (r << 16) | (g << 8) | b;
	}

	static bool Extent(int[] src, int w, int sy, int lo, int hi, out int a, out int b) {
		a = b = -1;
		for (int x = lo; x <= hi; x++) if (Opaque(src[sy * w + x])) { if (a < 0) a = x; b = x; }
		return a >= 0;
	}

	//Copies [sa, sb] into [x0, x1] without stretching: outline ends kept, interior copied 1:1 from the anchored end
	//(cropped or extended at the far side), so plate/chain/stitch patterns survive.
	static void Fill(int[] src, int[] o, int w, int y, int sy, int sa, int sb, int x0, int x1, bool anchorRight, double shade) {
		int n = x1 - x0, m = sb - sa;
		for (int k = 0; k <= n; k++) {
			int sk;
			if (k == 0) sk = 0; else if (k == n) sk = m;
			else sk = Math.Min(k, Math.Max(m - 1, 0));
			int x = anchorRight ? x1 - k : x0 + k, sx = anchorRight ? sb - sk : sa + sk;
			int c = src[sy * w + sx];
			if (Opaque(c)) o[y * w + x] = shade < 1 ? Shade(c, shade) : c;
		}
	}

	//srcTop -2: source is TG body art, remapped from TG rows. legSide 1/2: single-leg sprite, which only fills its own leg
	//in side views (TG puts the left leg in front facing east, behind facing west).
	public static int[] Transform(int[] src, int w, int h, int dir, Shape shape, int srcTop = 0, int legSide = 0) {
		bool mirror = dir == 3;
		if (mirror) src = Mirror(src, w, h);
		bool fromTg = srcTop == -2;
		var res = fromTg ? new int[src.Length] : (int[])src.Clone(); //TG art only contributes through the silhouette
		int off = h - 32; //taller sheets (e.g. 32x64) keep the 32x32 figure in their bottom rows
		for (int y = 0; y < h; y++) {
			int tr = TgRow(y - off, shape.LegTop); if (tr < 0) continue;
			bool solid = y - off >= shape.LegTop;
			int sy = fromTg ? tr + off : y;
			int fallback = off + (fromTg ? TgLegTop : shape.LegTop); //thigh rows borrow the top leg row when the source has none
			if (dir <= 1) {
				for (int side = 0; side < 2; side++) {
					int lo = side == 0 ? 0 : 16, hi = side == 0 ? 15 : w - 1;
					var seg = FrontSeg(shape, tr, side == 1);
					if (seg == null) continue;
					int a, b, ry = sy;
					bool has = Extent(src, w, ry, lo, hi, out a, out b);
					if (!has && !solid) { ry = fallback; has = Extent(src, w, ry, lo, hi, out a, out b); }
					if (solid) for (int x = lo; x <= hi; x++) res[y * w + x] = 0;
					if (has) Fill(src, res, w, y, ry, a, b, seg[0], seg[1], side == 1, 1);
				}
			} else {
				var seg = SideSeg(shape, tr); if (seg == null) continue;
				int a, b, ry = sy;
				bool has = Extent(src, w, ry, 6, 25, out a, out b);
				if (!has && !solid) { ry = fallback; has = Extent(src, w, ry, 6, 25, out a, out b); }
				if (solid) for (int x = 6; x <= 25; x++) res[y * w + x] = 0;
				if (!has) continue;
				bool back = legSide == 0 || legSide == (dir == 2 ? 2 : 1), front = legSide == 0 || legSide == (dir == 2 ? 1 : 2);
				if (back) Fill(src, res, w, y, ry, a, b, seg[0], seg[1], false, BackLegShade); //back leg shows the back of the item
				if (front) Fill(src, res, w, y, ry, a, b, seg[2], seg[3], true, 1);         //front leg shows the front (toes)
			}
		}
		if (!fromTg) RemoveStrays(src, res, w, h, off + shape.LegTop - 3);
		return mirror ? Mirror(res, w, h) : res;
	}

	static int[] Mirror(int[] p, int w, int h) {
		var m = new int[p.Length];
		for (int y = 0; y < h; y++) for (int x = 0; x < w; x++) m[y * w + x] = p[y * w + (w - 1 - x)];
		return m;
	}

	//1/2 for single-leg states (*_l_leg_*, *_r_leg_*); clothing sleeves stay 0 since plantigrade sleeves cover both legs.
	public static int LegSide(string name) {
		var t = name.Split('_');
		for (int i = 0; i + 1 < t.Length; i++)
			if (t[i + 1] == "leg") { if (t[i] == "l") return 1; if (t[i] == "r") return 2; }
		return 0;
	}

	//Keeps the reference body's black claws uncovered by markings.
	static void MaskClaws(DmiState digi, Dmi refBody, int legSide) {
		var zones = legSide == 1 ? new[] { "l_leg_digi" } : legSide == 2 ? new[] { "r_leg_digi" } : new[] { "l_leg_digi", "r_leg_digi" };
		foreach (var z in zones) {
			var r = refBody.Find(z); if (r == null) continue;
			for (int i = 0; i < digi.Icons.Count; i++) {
				var mask = r.Get(Math.Min(i % digi.Dirs, r.Dirs - 1), 0);
				for (int p = 0; p < mask.Length && p < digi.Icons[i].Length; p++)
					if (Opaque(mask[p]) && Lum(mask[p]) < ClawLum) digi.Icons[i][p] = 0;
			}
		}
	}

	//Overlay suffixes the game appends after the (digi) worn state: "[t_state]_boob", "[t_state][detail_tag]", ...
	static readonly string[] OverlaySuffixes = { "_boob", "_detailalt", "_detailp", "_detail", "_det1", "_det", "_box", "_belt", "_dim", "_psy", "_quad", "_soaked", "_spl" };

	//Digi name for a state: overlays become "<stem>_digi<suffix>" (what update_icons looks up), everything else "<name>_digi".
	public static string DigiName(string name, HashSet<string> stateNames) {
		foreach (var suf in OverlaySuffixes) {
			for (int i = name.IndexOf(suf, StringComparison.Ordinal); i > 0; i = name.IndexOf(suf, i + 1, StringComparison.Ordinal)) {
				string stem = name.Substring(0, i), rest = name.Substring(i);
				if (stateNames.Contains(stem) && OverlaySuffixes.Any(o => rest.StartsWith(o))) return stem + "_digi" + rest;
			}
		}
		return name + "_digi";
	}

	//Drops pixels the squeeze stranded (no opaque 8-neighbour), unless the source had a lone pixel there too.
	static bool Lone(int[] p, int w, int h, int x, int y) {
		if (!Opaque(p[y * w + x])) return false;
		for (int dy = -1; dy <= 1; dy++) for (int dx = -1; dx <= 1; dx++) {
			int nx = x + dx, ny = y + dy;
			if ((dx != 0 || dy != 0) && nx >= 0 && nx < w && ny >= 0 && ny < h && Opaque(p[ny * w + nx])) return false;
		}
		return true;
	}
	static void RemoveStrays(int[] src, int[] res, int w, int h, int fromRow) {
		for (int y = Math.Max(fromRow, 0); y < h; y++)
			for (int x = 0; x < w; x++)
				if (Lone(res, w, h, x, y) && !Lone(src, w, h, x, y)) res[y * w + x] = 0;
	}

	public static DmiState MakeDigi(DmiState s, int w, int h, Shape shape, string digiName) {
		var d = new DmiState { Name = digiName, Dirs = s.Dirs, Frames = s.Frames, Extra = new List<string>(s.Extra) };
		for (int f = 0; f < s.Frames; f++) for (int dir = 0; dir < s.Dirs; dir++)
			d.Icons.Add(s.Dirs >= 4 && dir < 4 ? Transform(s.Get(dir, f), w, h, dir, shape, 0, LegSide(s.Name)) : (int[])s.Get(dir, f).Clone());
		return d;
	}

	//"<prefix><base><rest>" where prefix is a sleeve prefix (r_, l_, xr_, xl_) and rest is empty or starts with '_' (e.g. _f, _dwarf, detail tags).
	static bool Matches(string name, HashSet<string> bases) {
		foreach (var p in new[] { "", "r_", "l_", "xr_", "xl_" })
			foreach (var b in bases) {
				string full = p + b;
				if (name == full || (name.StartsWith(full + "_"))) return true;
			}
		return false;
	}

	static int Lum(int c) { return (((c >> 16) & 0xFF) * 3 + ((c >> 8) & 0xFF) * 6 + (c & 0xFF)) / 10; }
	const int ClawLum = 0x20; //TG claws are near-black and stay that way so skin tinting can't colour them

	//Rank-maps the distinct luminance levels of `from` onto the distinct grey levels of `to`.
	static Dictionary<int, int> GreyMap(DmiState from, DmiState to) {
		var src = from.Icons.SelectMany(i => i).Where(Opaque).Select(Lum).Where(l => l >= ClawLum).Distinct().OrderBy(l => l).ToList();
		var dst = to.Icons.SelectMany(i => i).Where(Opaque).Select(Lum).Distinct().OrderBy(l => l).ToList();
		var map = new Dictionary<int, int>();
		for (int i = 0; i < src.Count; i++) map[src[i]] = dst[src.Count == 1 ? dst.Count - 1 : (int)Math.Round(i * (dst.Count - 1) / (double)(src.Count - 1))];
		return map;
	}
	static int Recolor(int c, Dictionary<int, int> map) {
		if (!Opaque(c)) return 0;
		int l = Lum(c); if (l < ClawLum) return c;
		int g = map[l]; return (int)((uint)c & 0xFF000000u) | (g << 16) | (g << 8) | g;
	}
	static void Put(Dmi dmi, DmiState after, DmiState s) {
		dmi.States.RemoveAll(x => x.Name == s.Name);
		dmi.States.Insert(dmi.States.IndexOf(after) + 1, s);
	}

	static List<string> Options(IEnumerable<string> args, out bool female, out int top) {
		female = false; top = -1; var rest = new List<string>();
		foreach (var x in args) {
			if (x == "female") female = true;
			else if (x.StartsWith("top=")) top = int.Parse(x.Substring(4));
			else rest.Add(x);
		}
		return rest;
	}

	public static int Run(string[] a) {
		switch (a[0]) {
			case "tgbody": { //tgbody <body.dmi> <tg_bodyparts.dmi> [female] [top=N]
				bool female; int top; var pos = Options(a.Skip(1), out female, out top);
				var body = Dmi.Load(pos[0]); var tg = Dmi.Load(pos[1]);
				var shape = new Shape { Female = female, LegTop = top > 0 ? top : (female ? 24 : 23) };
				foreach (var zone in new[] { "l_leg", "r_leg" }) {
					var orig = body.Find(zone); var tgs = tg.Find("digitigrade_" + zone);
					if (orig == null || tgs == null) { Console.Error.WriteLine("missing " + zone); return 1; }
					var map = GreyMap(tgs, orig);
					var leg = new DmiState { Name = zone + "_digi", Dirs = orig.Dirs, Frames = 1, Extra = new List<string>(orig.Extra) };
					for (int d = 0; d < orig.Dirs; d++) {
						var art = tgs.Get(Math.Min(d, tgs.Dirs - 1), 0).Select(c => Recolor(c, map)).ToArray();
						const bool fit = true;
						leg.Icons.Add(fit && d < 4 ? Transform(art, body.W, body.H, d, shape, -2) : art);
					}
					Put(body, orig, leg);
					var above = body.Find(zone + "_above");
					if (above != null) {
						var ad = new DmiState { Name = zone + "_above_digi", Dirs = above.Dirs, Frames = 1, Extra = new List<string>(above.Extra) };
						for (int d = 0; d < above.Dirs; d++)
							ad.Icons.Add(above.Get(d, 0).Any(Opaque) ? (int[])leg.Get(Math.Min(d, leg.Dirs - 1), 0).Clone() : new int[body.W * body.H]);
						Put(body, above, ad);
					}
				}
				body.Save(pos[0]); Console.WriteLine("tg digi legs (" + (female ? "female" : "male") + ", top " + shape.LegTop + ") written to " + pos[0]); return 0;
			}
			case "digiapply": { //digiapply file.dmi (base... | all) [skip=a,b] [female] [top=N]  -> writes digi states for matching states, in place
				bool female; int top; var pos = Options(a.Skip(1), out female, out top);
				var skip = new HashSet<string>(pos.Where(x => x.StartsWith("skip=")).SelectMany(x => x.Substring(5).Split(',')));
				//claws=<male body.dmi>,<female body.dmi>: keep the reference bodies' black claws uncovered (markings)
				var clawRefs = pos.Where(x => x.StartsWith("claws=")).Select(x => x.Substring(6).Split(',').Select(Dmi.Load).ToArray()).FirstOrDefault();
				pos = pos.Where(x => !x.StartsWith("skip=") && !x.StartsWith("claws=")).ToList();
				var dmi = Dmi.Load(pos[0]); int made = 0;
				Func<string, bool> isDigi = n => n.EndsWith("_digi") || n.Contains("_digi_");
				var names = new HashSet<string>(dmi.States.Where(s => !isDigi(s.Name)).Select(s => s.Name));
				bool all = pos.Count == 2 && pos[1] == "all";
				var bases = all ? new HashSet<string>(names.Where(n => n.Length > 0)) : new HashSet<string>(pos.Skip(1));
				var skipped = skip.Count == 0 ? new HashSet<string>() : new HashSet<string>(names.Where(n => Matches(n, skip)));
				var sources = dmi.States.Where(s => !isDigi(s.Name) && s.Name.Length > 0 && !skipped.Contains(s.Name) && Matches(s.Name, bases)).ToList();
				if (sources.Count == 0) { Console.Error.WriteLine("no matching states"); return 1; }
				foreach (var s in sources) {
					var shape = Shape.For(s.Name, female, top);
					string dn = DigiName(s.Name, names);
					dmi.States.RemoveAll(x => x.Name == dn || x.Name == s.Name + "_digi");
					var digi = MakeDigi(s, dmi.W, dmi.H, shape, dn);
					if (clawRefs != null) MaskClaws(digi, clawRefs[shape.Female && clawRefs.Length > 1 ? 1 : 0], LegSide(s.Name));
					dmi.States.Insert(dmi.States.IndexOf(s) + 1, digi); made++;
				}
				dmi.Save(pos[0]); Console.WriteLine(made + " digi states written to " + pos[0]); return 0;
			}
			case "digipreview": { //digipreview out.png scale spec... [female] [top=N]  (each spec rendered normal then digi)
				bool female; int top; var pos = Options(a.Skip(1), out female, out top);
				var rows = new List<KeyValuePair<string, int[][]>>(); int w = 32, h = 32;
				var shape = new Shape { Female = female, LegTop = top > 0 ? top : (female ? 24 : 23) };
				foreach (var spec in pos.Skip(2)) {
					var n = Program.Compose(spec, out w, out h);
					rows.Add(new KeyValuePair<string, int[][]>(spec, n));
					rows.Add(new KeyValuePair<string, int[][]>(spec, n.Select((ic, dir) => Transform(ic, w, h, dir, shape)).ToArray()));
				}
				Dmi.Preview(pos[0], int.Parse(pos[1]), rows, w, h); return 0;
			}
		}
		Console.Error.WriteLine("unknown command " + a[0]); return 1;
	}
}
