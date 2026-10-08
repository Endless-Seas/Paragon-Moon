public static class Verify { public static bool Same(string a, string b) {
	var x = Dmi.Load(a); var y = Dmi.Load(b);
	if (x.States.Count != y.States.Count) return false;
	for (int i = 0; i < x.States.Count; i++) { var s = x.States[i]; var t = y.States[i];
		if (s.Name != t.Name || s.Dirs != t.Dirs || s.Frames != t.Frames || string.Join("|", s.Extra) != string.Join("|", t.Extra)) return false;
		for (int j = 0; j < s.Icons.Count; j++) for (int p = 0; p < s.Icons[j].Length; p++) { int c1 = s.Icons[j][p], c2 = t.Icons[j][p]; if (c1 != c2 && !(((c1>>24)&0xFF)==0 && ((c2>>24)&0xFF)==0)) return false; } }
	return true; } }
