import 'dart:io';

void main() {
  final file = File('lib/features/parent/espace_enfant/apercu/child_details_view.dart');
  final lines = file.readAsLinesSync();
  
  int start = -1;
  int end = -1;
  
  for(int i=0; i<lines.length; i++) {
    if(lines[i].contains('Widget _buildOverviewTab()')) {
      start = i;
      int braceCount = 0;
      bool started = false;
      for(int j=i; j<lines.length; j++) {
        for(int k=0; k<lines[j].length; k++) {
          if(lines[j][k] == '{') { braceCount++; started = true; }
          if(lines[j][k] == '}') { braceCount--; }
        }
        if(started && braceCount == 0) {
          end = j;
          break;
        }
      }
      break;
    }
  }
  print('start: $start, end: $end');
}
