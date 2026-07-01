import 'dart:io';

void main() {
  final file = File('lib/features/parent/espace_enfant/apercu/overview_tab_view.dart');
  print('overview_tab_view.dart has ${file.readAsLinesSync().length} lines');
}
