import 'dart:io';

void main() {
  final file = File('lib/features/parent/accueil/dashboard/parent_home_page.dart');
  final lines = file.readAsLinesSync();
  
  for(int i=941; i<=1000; i++) {
    print(lines[i]);
  }
}
