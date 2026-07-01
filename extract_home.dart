import 'dart:io';

void main() {
  final file = File('lib/features/parent/accueil/dashboard/parent_home_page.dart');
  final lines = file.readAsLinesSync();
  
  // Create directories if not exist
  Directory('lib/features/parent/notifications').createSync(recursive: true);
  Directory('lib/features/parent/messages').createSync(recursive: true);
  Directory('lib/features/parent/evenements').createSync(recursive: true);

  final methods = <String, Map<String, int>>{};
  
  for(int i=0; i<lines.length; i++) {
    final line = lines[i];
    if (line.startsWith('  Widget _build') || 
        line.startsWith('  void _show')) {
      
      String name = line.trim().split(RegExp(r'[\s(]'))[1];
      
      int braceCount = 0;
      int end = i;
      bool started = false;
      for(int j=i; j<lines.length; j++) {
        String l = lines[j];
        for(int k=0; k<l.length; k++) {
          if(l[k] == '{') { braceCount++; started = true; }
          if(l[k] == '}') { braceCount--; }
        }
        if(started && braceCount == 0) {
          end = j;
          break;
        }
      }
      methods[name] = {'start': i, 'end': end};
    }
  }
  
  for(var entry in methods.entries) {
    print('${entry.key}:${entry.value['start']}:${entry.value['end']}');
  }
}
