import 'dart:io';

void main() {
  final file = File('lib/features/parent/accueil/dashboard/parent_home_page.dart');
  final lines = file.readAsLinesSync();
  
  int childCardStart = lines.indexWhere((l) => l.trim() == 'class _ChildCard extends StatelessWidget {');
  if (childCardStart != -1) {
    int childCardEnd = lines.lastIndexOf('}'); // end of the file is the end of the widget block usually
    // wait, it's safer to count braces
    int braceCount = 0;
    for(int i = childCardStart; i < lines.length; i++) {
      if (lines[i].contains('{')) braceCount += '{'.allMatches(lines[i]).length;
      if (lines[i].contains('}')) braceCount -= '}'.allMatches(lines[i]).length;
      if (braceCount == 0) {
        childCardEnd = i;
        break;
      }
    }
    
    if (childCardEnd != -1) {
      final childCardLines = lines.sublist(childCardStart, childCardEnd + 1);
      final widgetContent = """import 'package:flutter/material.dart';

${childCardLines.join('\n').replaceAll('class _ChildCard', 'class ChildCard')}
""";
      File('lib/features/parent/accueil/dashboard/child_card_widget.dart').writeAsStringSync(widgetContent);
      
      lines.removeRange(childCardStart, childCardEnd + 1);
      
      // replace all _ChildCard with ChildCard in the remaining lines
      for (int i=0; i<lines.length; i++) {
        lines[i] = lines[i].replaceAll('_ChildCard', 'ChildCard');
      }
      
      // Insert import
      lines.insert(0, "import 'package:app_mobile/features/parent/accueil/dashboard/child_card_widget.dart';");
      
      file.writeAsStringSync(lines.join('\n'));
      print('Extracted ChildCard widget');
    }
  }
}
