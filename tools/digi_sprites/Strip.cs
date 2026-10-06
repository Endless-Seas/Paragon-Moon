public static class Strip { public static void Run(string i, string o) { var d = Dmi.Load(i); d.States.RemoveAll(s => s.Name.EndsWith("_digi") || s.Name.Contains("_digi_")); d.Save(o); } }
