public static class Dump { public static void Run(string spec, int y0) {
	int w, h; var icons = Program.Compose(spec, out w, out h);
	string[] dn = {"S","N","E","W"};
	for (int d = 0; d < 4; d++) { System.Console.WriteLine("== " + dn[d] + "   x: 0123456789abcdef0123456789abcdef");
		for (int y = y0; y < h; y++) { var sb = new System.Text.StringBuilder(); sb.Append(y.ToString("D2") + "         ");
			for (int x = 0; x < w; x++) { int c = icons[d][y*w+x]; int a=(c>>24)&0xFF; if (a==0) { sb.Append('.'); continue; }
				int l = (((c>>16)&0xFF)*3 + ((c>>8)&0xFF)*6 + (c&0xFF))/10; sb.Append("0123456789ABCDEF"[l/16]); }
			System.Console.WriteLine(sb.ToString()); } } } }
