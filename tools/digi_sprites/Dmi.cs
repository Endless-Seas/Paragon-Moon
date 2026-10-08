//Minimal BYOND .dmi reader/writer + preview exporter.
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;

public class DmiState {
	public string Name;
	public int Dirs = 1, Frames = 1;
	public List<string> Extra = new List<string>(); //raw "key = value" lines other than dirs/frames
	public List<int[]> Icons = new List<int[]>();   //frame-major, dir-minor; ARGB, W*H each
	public int[] Get(int dir, int frame) { return Icons[frame * Dirs + dir]; }
}

public class Dmi {
	public int W = 32, H = 32;
	public string Version = "4.0";
	public List<DmiState> States = new List<DmiState>();

	public DmiState Find(string name) { return States.FirstOrDefault(s => s.Name == name); }

	static uint[] crcTable;
	static uint Crc(byte[] data, int off, int len) {
		if (crcTable == null) {
			crcTable = new uint[256];
			for (uint n = 0; n < 256; n++) { uint c = n; for (int k = 0; k < 8; k++) c = (c & 1) != 0 ? 0xEDB88320u ^ (c >> 1) : c >> 1; crcTable[n] = c; }
		}
		uint crc = 0xFFFFFFFFu;
		for (int i = off; i < off + len; i++) crc = crcTable[(crc ^ data[i]) & 0xFF] ^ (crc >> 8);
		return crc ^ 0xFFFFFFFFu;
	}
	static int BE(byte[] b, int o) { return (b[o] << 24) | (b[o + 1] << 16) | (b[o + 2] << 8) | b[o + 3]; }

	static string ReadDescription(byte[] png) {
		int p = 8;
		while (p < png.Length) {
			int len = BE(png, p); string type = Encoding.ASCII.GetString(png, p + 4, 4);
			if (type == "zTXt" || type == "tEXt") {
				int s = p + 8; int z = Array.IndexOf(png, (byte)0, s);
				string key = Encoding.ASCII.GetString(png, s, z - s);
				if (key == "Description") {
					if (type == "tEXt") return Encoding.UTF8.GetString(png, z + 1, p + 8 + len - z - 1);
					int ds = z + 2 + 2; //skip method byte + 2-byte zlib header
					using (var ms = new MemoryStream(png, ds, p + 8 + len - ds))
					using (var df = new DeflateStream(ms, CompressionMode.Decompress))
					using (var sr = new StreamReader(df, Encoding.UTF8)) return sr.ReadToEnd();
				}
			}
			if (type == "IEND") break;
			p += 12 + len;
		}
		return null;
	}

	public static int[] ReadPixels(Bitmap bmp) {
		var d = bmp.LockBits(new Rectangle(0, 0, bmp.Width, bmp.Height), ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
		var px = new int[bmp.Width * bmp.Height];
		for (int y = 0; y < bmp.Height; y++) Marshal.Copy(d.Scan0 + y * d.Stride, px, y * bmp.Width, bmp.Width);
		bmp.UnlockBits(d); return px;
	}
	public static Bitmap ToBitmap(int[] px, int w, int h) {
		var bmp = new Bitmap(w, h, PixelFormat.Format32bppArgb);
		var d = bmp.LockBits(new Rectangle(0, 0, w, h), ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);
		for (int y = 0; y < h; y++) Marshal.Copy(px, y * w, d.Scan0 + y * d.Stride, w);
		bmp.UnlockBits(d); return bmp;
	}

	public static Dmi Load(string path) {
		byte[] png = File.ReadAllBytes(path);
		var dmi = new Dmi();
		string desc = ReadDescription(png);
		int[] sheet; int sw, sh;
		using (var ms = new MemoryStream(png)) using (var img = new Bitmap(ms)) { sw = img.Width; sh = img.Height; sheet = ReadPixels(img); }
		if (desc == null) throw new Exception("no DMI description in " + path);
		DmiState cur = null;
		foreach (var raw in desc.Split('\n')) {
			string line = raw.Trim(); if (line.Length == 0 || line.StartsWith("#")) continue;
			int eq = line.IndexOf('='); if (eq < 0) continue;
			string k = line.Substring(0, eq).Trim(), v = line.Substring(eq + 1).Trim();
			if (k == "version") dmi.Version = v;
			else if (k == "width") dmi.W = int.Parse(v);
			else if (k == "height") dmi.H = int.Parse(v);
			else if (k == "state") { cur = new DmiState { Name = v.Trim('"') }; dmi.States.Add(cur); }
			else if (cur != null && k == "dirs") cur.Dirs = int.Parse(v);
			else if (cur != null && k == "frames") cur.Frames = int.Parse(v);
			else if (cur != null) cur.Extra.Add(k + " = " + v);
		}
		int cols = Math.Max(1, sw / dmi.W); int idx = 0;
		foreach (var s in dmi.States)
			for (int i = 0; i < s.Dirs * s.Frames; i++, idx++) {
				int cx = (idx % cols) * dmi.W, cy = (idx / cols) * dmi.H;
				var ic = new int[dmi.W * dmi.H];
				if (cy + dmi.H <= sh)
					for (int y = 0; y < dmi.H; y++) Array.Copy(sheet, (cy + y) * sw + cx, ic, y * dmi.W, dmi.W);
				s.Icons.Add(ic);
			}
		return dmi;
	}

	public string BuildDescription() {
		var sb = new StringBuilder();
		sb.Append("# BEGIN DMI\nversion = " + Version + "\n\twidth = " + W + "\n\theight = " + H + "\n");
		foreach (var s in States) {
			sb.Append("state = \"" + s.Name + "\"\n\tdirs = " + s.Dirs + "\n\tframes = " + s.Frames + "\n");
			foreach (var e in s.Extra) sb.Append("\t" + e + "\n");
		}
		sb.Append("# END DMI\n");
		return sb.ToString();
	}

	public void Save(string path) {
		int total = States.Sum(s => s.Icons.Count);
		int cols = Math.Max(1, (int)Math.Ceiling(Math.Sqrt(total))); int rows = Math.Max(1, (int)Math.Ceiling(total / (double)cols));
		int sw = cols * W, sh = rows * H; var sheet = new int[sw * sh]; int idx = 0;
		foreach (var s in States) foreach (var ic in s.Icons) {
			int cx = (idx % cols) * W, cy = (idx / cols) * H;
			for (int y = 0; y < H; y++) Array.Copy(ic, y * W, sheet, (cy + y) * sw + cx, W);
			idx++;
		}
		byte[] png;
		using (var bmp = ToBitmap(sheet, sw, sh)) using (var ms = new MemoryStream()) { bmp.Save(ms, ImageFormat.Png); png = ms.ToArray(); }
		//zTXt chunk: keyword\0 method(0) zlib-stream
		byte[] text = Encoding.UTF8.GetBytes(BuildDescription());
		byte[] deflated; using (var ms = new MemoryStream()) { using (var df = new DeflateStream(ms, CompressionLevel.Optimal, true)) df.Write(text, 0, text.Length); deflated = ms.ToArray(); }
		uint adler; { uint a = 1, b = 0; foreach (var t in text) { a = (a + t) % 65521; b = (b + a) % 65521; } adler = (b << 16) | a; }
		var body = new List<byte>(Encoding.ASCII.GetBytes("zTXtDescription")); body.Add(0); body.Add(0); body.Add(0x78); body.Add(0x9C);
		body.AddRange(deflated); body.Add((byte)(adler >> 24)); body.Add((byte)(adler >> 16)); body.Add((byte)(adler >> 8)); body.Add((byte)adler);
		var chunk = body.ToArray(); uint crc = Crc(chunk, 0, chunk.Length); int clen = chunk.Length - 4;
		int ihdrEnd = 8 + 12 + BE(png, 8);
		using (var fs = File.Create(path)) {
			fs.Write(png, 0, ihdrEnd);
			fs.Write(new byte[] { (byte)(clen >> 24), (byte)(clen >> 16), (byte)(clen >> 8), (byte)clen }, 0, 4);
			fs.Write(chunk, 0, chunk.Length);
			fs.Write(new byte[] { (byte)(crc >> 24), (byte)(crc >> 16), (byte)(crc >> 8), (byte)crc }, 0, 4);
			fs.Write(png, ihdrEnd, png.Length - ihdrEnd);
		}
	}

	//Renders dirs of frame 0 of each state side by side, scaled, on a checkerboard, with optional underlay state.
	public static void Preview(string outPath, int scale, List<KeyValuePair<string, int[][]>> rows, int w, int h) {
		int maxDirs = rows.Max(r => r.Value.Length);
		int cw = w * scale + 4, ch = h * scale + 4;
		using (var bmp = new Bitmap(maxDirs * cw, rows.Count * ch))
		using (var g = Graphics.FromImage(bmp)) {
			g.Clear(Color.FromArgb(40, 40, 48));
			for (int r = 0; r < rows.Count; r++)
				for (int d = 0; d < rows[r].Value.Length; d++) {
					int ox = d * cw + 2, oy = r * ch + 2; var ic = rows[r].Value[d];
					for (int y = 0; y < h; y++) for (int x = 0; x < w; x++) {
						int c = ic[y * w + x]; bool chk = ((x + y) & 1) == 0;
						Color bg = chk ? Color.FromArgb(150, 150, 160) : Color.FromArgb(120, 120, 130);
						int a = (c >> 24) & 0xFF;
						int rr = (((c >> 16) & 0xFF) * a + bg.R * (255 - a)) / 255, gg = (((c >> 8) & 0xFF) * a + bg.G * (255 - a)) / 255, bb = ((c & 0xFF) * a + bg.B * (255 - a)) / 255;
						using (var br = new SolidBrush(Color.FromArgb(rr, gg, bb))) g.FillRectangle(br, ox + x * scale, oy + y * scale, scale, scale);
					}
				}
			bmp.Save(outPath, ImageFormat.Png);
		}
	}
}
