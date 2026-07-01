import 'dart:io';

void main() {
  final file = File('lib/features/parent/espace_enfant/apercu/child_details_view.dart');
  final lines = file.readAsLinesSync();
  
  // Create directories if not exist
  Directory('lib/features/parent/espace_enfant/actualites').createSync(recursive: true);
  Directory('lib/features/parent/espace_enfant/devoirs').createSync(recursive: true);
  Directory('lib/features/parent/espace_enfant/professeurs').createSync(recursive: true);
  Directory('lib/features/parent/espace_enfant/informations').createSync(recursive: true);
  Directory('lib/features/parent/espace_enfant/statistiques').createSync(recursive: true);
  Directory('lib/features/parent/espace_enfant/historique').createSync(recursive: true);
  Directory('lib/features/parent/espace_enfant/notes').createSync(recursive: true);

  // Groupings
  final mappings = {
    'actualites/actualites_view.dart': [
      {'start': 1664, 'end': 1679},
      {'start': 1681, 'end': 1696},
      {'start': 1698, 'end': 1706},
      {'start': 1708, 'end': 1855},
      {'start': 1857, 'end': 1874},
    ],
    'devoirs/devoirs_view.dart': [
      {'start': 1271, 'end': 1309},
      {'start': 1311, 'end': 1413},
      {'start': 1415, 'end': 1599},
      {'start': 1601, 'end': 1615},
      {'start': 1617, 'end': 1625},
      {'start': 1627, 'end': 1637},
      {'start': 1639, 'end': 1649},
      {'start': 1651, 'end': 1661},
      {'start': 1876, 'end': 1891},
    ],
    'professeurs/professeurs_view.dart': [
      {'start': 1893, 'end': 2071},
    ],
    'notes/notes_view.dart': [
      {'start': 2073, 'end': 2107},
      {'start': 2109, 'end': 2206},
    ],
    'historique/historique_view.dart': [
      {'start': 2208, 'end': 2294},
    ],
    'informations/informations_view.dart': [
      {'start': 2296, 'end': 2669},
      {'start': 2671, 'end': 2710},
    ],
    'statistiques/statistiques_view.dart': [
      {'start': 2712, 'end': 2744},
      {'start': 2746, 'end': 2834},
      {'start': 2836, 'end': 2854},
      {'start': 2856, 'end': 2882},
      {'start': 2884, 'end': 2913},
      {'start': 2915, 'end': 2975},
      {'start': 2977, 'end': 3002},
      {'start': 3004, 'end': 3043},
    ],
  };

  Set<int> linesToRemove = {};

  for (var entry in mappings.entries) {
    String filename = entry.key;
    String className = filename.split('/').last.split('_')[0];
    className = className[0].toUpperCase() + className.substring(1) + 'ViewExtension';
    
    StringBuffer content = StringBuffer();
    content.writeln("part of '../apercu/child_details_view.dart';");
    content.writeln("");
    content.writeln("extension $className on _ChildDetailsViewState {");
    
    for (var block in entry.value) {
      for (int i = block['start']!; i <= block['end']!; i++) {
        content.writeln(lines[i]);
        linesToRemove.add(i);
      }
      content.writeln(""); // separate blocks
    }
    content.writeln("}");
    
    File('lib/features/parent/espace_enfant/' + filename).writeAsStringSync(content.toString());
  }

  // Rewrite child_details_view.dart
  StringBuffer newMain = StringBuffer();
  
  // Find imports insertion point
  int importEnd = 0;
  for(int i=0; i<lines.length; i++) {
    newMain.writeln(lines[i]);
    if(lines[i].startsWith('import ') && !lines[i+1].startsWith('import ')) {
      importEnd = i;
      break;
    }
  }
  
  newMain.writeln("part '../actualites/actualites_view.dart';");
  newMain.writeln("part '../devoirs/devoirs_view.dart';");
  newMain.writeln("part '../professeurs/professeurs_view.dart';");
  newMain.writeln("part '../notes/notes_view.dart';");
  newMain.writeln("part '../historique/historique_view.dart';");
  newMain.writeln("part '../informations/informations_view.dart';");
  newMain.writeln("part '../statistiques/statistiques_view.dart';");
  
  for(int i=importEnd+1; i<lines.length; i++) {
    if(!linesToRemove.contains(i)) {
      newMain.writeln(lines[i]);
    }
  }
  
  file.writeAsStringSync(newMain.toString());
  print('Extraction successfully completed!');
}
