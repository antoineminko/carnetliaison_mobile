import 'dart:io';

void main() {
  final file = File('lib/features/parent/accueil/dashboard/parent_home_page.dart');
  final lines = file.readAsLinesSync();
  
  // Create directories if not exist
  Directory('lib/features/parent/notifications').createSync(recursive: true);
  Directory('lib/features/parent/messages').createSync(recursive: true);
  Directory('lib/features/parent/evenements').createSync(recursive: true);

  // Groupings
  final mappings = {
    '../../notifications/parent_notifications_view.dart': [
      {'start': 1859, 'end': 2198},
      {'start': 2200, 'end': 2443},
    ],
    '../../messages/messages_view.dart': [
      {'start': 2739, 'end': 2784},
      {'start': 2786, 'end': 2848},
      {'start': 3017, 'end': 3162},
    ],
    '../../evenements/evenements_view.dart': [
      {'start': 3164, 'end': 3229},
      {'start': 3242, 'end': 3351},
      {'start': 3353, 'end': 3583},
      {'start': 3585, 'end': 3655},
    ],
  };

  Set<int> linesToRemove = {};

  for (var entry in mappings.entries) {
    String filename = entry.key;
    String className = filename.split('/').last.split('.')[0].split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join('') + 'Extension';
    
    StringBuffer content = StringBuffer();
    content.writeln("part of '../accueil/dashboard/parent_home_page.dart';");
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
    String outPath = 'lib/features/parent/' + filename.replaceAll('../../', '');
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
  
  newMain.writeln("part '../../notifications/parent_notifications_view.dart';");
  newMain.writeln("part '../../messages/messages_view.dart';");
  newMain.writeln("part '../../evenements/evenements_view.dart';");
  
  for(int i=importEnd+1; i<lines.length; i++) {
    if(!linesToRemove.contains(i)) {
      newMain.writeln(lines[i]);
    }
  }
  
  file.writeAsStringSync(newMain.toString());
  print('Extraction successfully completed!');
}
