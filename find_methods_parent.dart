import 'dart:io';

void main() {
  final file = File('lib/features/parent/accueil/dashboard/parent_home_page.dart');
  final lines = file.readAsLinesSync();
  
  for(int i=0; i<lines.length; i++) {
    if(lines[i].trim().startsWith('Widget ') || lines[i].trim().startsWith('void ')) {
      print('Line ${i+1}: ${lines[i].trim()}');
    }
  }
}
