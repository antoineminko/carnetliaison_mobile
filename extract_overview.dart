import 'dart:io';

void main() {
  final file = File('lib/features/parent/espace_enfant/apercu/child_details_view.dart');
  final lines = file.readAsLinesSync();
  
  int startIdx = -1;
  int endIdx = lines.lastIndexOf('}'); // the end of class _ChildDetailsViewState
  
  for(int i=0; i<lines.length; i++) {
    if(lines[i].contains('Widget _buildOverviewTab()')) {
      startIdx = i;
      break;
    }
  }
  
  if (startIdx != -1 && endIdx != -1) {
    // Extract methods
    final methodsLines = lines.sublist(startIdx, endIdx);
    
    // Create overview_tab_view.dart
    final newFileContent = """part of 'child_details_view.dart';

extension OverviewTabExtension on _ChildDetailsViewState {
${methodsLines.join('\n')}
}
""";
    File('lib/features/parent/espace_enfant/apercu/overview_tab_view.dart').writeAsStringSync(newFileContent);
    
    // Modify child_details_view.dart
    lines.removeRange(startIdx, endIdx);
    
    // Add part directive
    int partIdx = lines.indexWhere((l) => l.startsWith('part '));
    if (partIdx != -1) {
      lines.insert(partIdx, "part 'overview_tab_view.dart';");
    } else {
      lines.insert(0, "part 'overview_tab_view.dart';");
    }
    
    file.writeAsStringSync(lines.join('\n'));
    print('Extraction complete.');
  } else {
    print('Failed to find bounds.');
  }
}
