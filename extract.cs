using System;
using System.IO;
using System.Text;
using System.Collections.Generic;

class Program {
    static void Main() {
        string path = @"lib\features\parent\espace_enfant\apercu\child_details_view.dart";
        string[] lines = File.ReadAllLines(path, Encoding.UTF8);
        
        var methods = new Dictionary<string, (int start, int end)>();
        
        // simple parsing
        for(int i=0; i<lines.Length; i++) {
            if(lines[i].StartsWith("  Widget _build") || lines[i].StartsWith("  void _show") || lines[i].StartsWith("  List<") || lines[i].StartsWith("  Color _get") || lines[i].StartsWith("  IconData _get") || lines[i].StartsWith("  String _get") || lines[i].StartsWith("  String _format")) {
                string name = lines[i].Trim().Split(new char[]{' ', '('})[1];
                if(lines[i].Trim().StartsWith("List<")) name = lines[i].Trim().Split(new char[]{' ', '('})[2];
                if(lines[i].Trim().StartsWith("Color ")) name = lines[i].Trim().Split(new char[]{' ', '('})[1];
                if(lines[i].Trim().StartsWith("IconData ")) name = lines[i].Trim().Split(new char[]{' ', '('})[1];
                if(lines[i].Trim().StartsWith("String ")) name = lines[i].Trim().Split(new char[]{' ', '('})[1];
                
                int braceCount = 0;
                int end = i;
                bool started = false;
                for(int j=i; j<lines.Length; j++) {
                    if(lines[j].Contains("{")) { braceCount++; started=true; }
                    if(lines[j].Contains("}")) { braceCount--; }
                    if(started && braceCount == 0) {
                        end = j;
                        break;
                    }
                }
                methods[name] = (i, end);
            }
        }
        
        foreach(var m in methods) {
            Console.WriteLine(m.Key + " : " + m.Value.start + " -> " + m.Value.end);
        }
    }
}
