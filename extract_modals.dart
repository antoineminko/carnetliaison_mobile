import 'dart:io';

void main() {
  final file = File('lib/features/parent/espace_enfant/apercu/overview_tab_view.dart');
  final lines = file.readAsLinesSync();
  
  // Find where the helper methods start:
  int helperStartIdx = lines.indexWhere((l) => l.contains('Widget _buildPriorityNotifications()'));
  
  if (helperStartIdx != -1) {
    int endIdx = lines.lastIndexOf('}'); // the end of extension OverviewTabExtension
    
    if (endIdx != -1) {
      final helperLines = lines.sublist(helperStartIdx, endIdx);
      
      final modalsContent = """part of 'child_details_view.dart';

extension OverviewModalsExtension on _ChildDetailsViewState {
${helperLines.join('\n')}
}
""";
      File('lib/features/parent/espace_enfant/apercu/overview_modals.dart').writeAsStringSync(modalsContent);
      
      lines.removeRange(helperStartIdx, endIdx);
      
      file.writeAsStringSync(lines.join('\n'));
      
      // Update child_details_view.dart to include part 'overview_modals.dart';
      final parentFile = File('lib/features/parent/espace_enfant/apercu/child_details_view.dart');
      final parentLines = parentFile.readAsLinesSync();
      int partIdx = parentLines.indexWhere((l) => l.startsWith('part '));
      parentLines.insert(partIdx, "part 'overview_modals.dart';");
      parentFile.writeAsStringSync(parentLines.join('\n'));
      
      print('Extracted modals into overview_modals.dart');
    }
  }
}
