import 'dart:io';

void main() {
  final file = File('lib/features/parent/espace_enfant/apercu/child_details_view.dart');
  final lines = file.readAsLinesSync();
  
  for(int i=871; i<=1310; i++) {
    if(lines[i].trim().startsWith('Widget ') || lines[i].trim().startsWith('void ')) {
      print(lines[i].trim());
    }
  }
}
