import 'dart:io';

void main() {
  final file = File('lib/features/parent/accueil/dashboard/parent_home_page.dart');
  final lines = file.readAsLinesSync();
  
  // Groupings
  final mappings = {
    'dashboard_cards_view.dart': [
      {'start': 985, 'end': 1028},
      {'start': 1030, 'end': 1060},
      {'start': 1083, 'end': 1158},
      {'start': 1805, 'end': 1824},
      {'start': 1826, 'end': 1861},
      {'start': 2095, 'end': 2157},
    ],
    'dashboard_header_view.dart': [
      {'start': 1160, 'end': 1280},
      {'start': 1282, 'end': 1378},
      {'start': 1380, 'end': 1418},
      {'start': 1691, 'end': 1758},
      {'start': 1760, 'end': 1803},
    ],
    'dashboard_modals_view.dart': [
      {'start': 1865, 'end': 1971},
      {'start': 1973, 'end': 2093},
    ],
    'dashboard_tiles_view.dart': [
      {'start': 927, 'end': 940},
      {'start': 942, 'end': 983},
      {'start': 1062, 'end': 1081},
    ],
  };

  Set<int> linesToRemove = {};

  for (var entry in mappings.entries) {
    String filename = entry.key;
    String className = filename.split('.').first.split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join('') + 'Extension';
    
    StringBuffer content = StringBuffer();
    content.writeln("part of 'parent_home_page.dart';");
    content.writeln("");
    content.writeln("extension $className on _ParentHomePageState {");
    
    for (var block in entry.value) {
      for (int i = block['start']!; i <= block['end']!; i++) {
        content.writeln(lines[i]);
        linesToRemove.add(i);
      }
      content.writeln(""); // separate blocks
    }
    content.writeln("}");
    
    // Path resolution from dashboard/
    String outPath = 'lib/features/parent/accueil/dashboard/' + filename;
    File(outPath).writeAsStringSync(content.toString());
  }

  // Rewrite parent_home_page.dart
  StringBuffer newMain = StringBuffer();
  
  // Find imports insertion point
  int importEnd = 0;
  for(int i=0; i<lines.length; i++) {
    newMain.writeln(lines[i]);
    if(lines[i].startsWith('import ') && !lines[i+1].startsWith('import ') && !lines[i+1].startsWith('//')) {
      importEnd = i;
      break;
    }
  }
  
  newMain.writeln("part 'dashboard_cards_view.dart';");
  newMain.writeln("part 'dashboard_header_view.dart';");
  newMain.writeln("part 'dashboard_modals_view.dart';");
  newMain.writeln("part 'dashboard_tiles_view.dart';");
  
  for(int i=importEnd+1; i<lines.length; i++) {
    if(!linesToRemove.contains(i)) {
      newMain.writeln(lines[i]);
    }
  }
  
  file.writeAsStringSync(newMain.toString());
  print('Extraction successfully completed!');
}
