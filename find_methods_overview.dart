import 'dart:io';

void main() {
  final file = File('lib/features/parent/espace_enfant/apercu/overview_tab_view.dart');
  final lines = file.readAsLinesSync();
  
  for(int i=0; i<lines.length; i++) {
    if(lines[i].trim().startsWith('Widget ') || lines[i].trim().startsWith('void ') || lines[i].trim().startsWith('Future ')) {
      print('Line ${i+1}: ${lines[i].trim()}');
    }
  }
}
