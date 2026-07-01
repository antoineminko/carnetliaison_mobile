import 'dart:io';

void main() {
  final file = File('lib/features/parent/accueil/dashboard/parent_home_page.dart');
  print('parent_home_page.dart has ${file.readAsLinesSync().length} lines');
}
