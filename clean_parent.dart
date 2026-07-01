import 'dart:io';

void main() {
  final file = File('lib/features/parent/accueil/dashboard/parent_home_page.dart');
  final lines = file.readAsLinesSync();
  
  // 1. Delete _buildBodyOld
  int buildBodyOldStart = lines.indexWhere((l) => l.trim() == 'Widget _buildBodyOld() {');
  if (buildBodyOldStart != -1) {
    int braceCount = 0;
    int buildBodyOldEnd = -1;
    for(int i = buildBodyOldStart; i < lines.length; i++) {
      if (lines[i].contains('{')) braceCount += '{'.allMatches(lines[i]).length;
      if (lines[i].contains('}')) braceCount -= '}'.allMatches(lines[i]).length;
      if (braceCount == 0) {
        buildBodyOldEnd = i;
        break;
      }
    }
    if (buildBodyOldEnd != -1) {
      lines.removeRange(buildBodyOldStart, buildBodyOldEnd + 1);
    }
  }

  // 2. Delete _buildGlobalDashboard
  int globalDashboardStart = lines.indexWhere((l) => l.trim() == 'Widget _buildGlobalDashboard() {');
  if (globalDashboardStart != -1) {
    int braceCount = 0;
    int globalDashboardEnd = -1;
    for(int i = globalDashboardStart; i < lines.length; i++) {
      if (lines[i].contains('{')) braceCount += '{'.allMatches(lines[i]).length;
      if (lines[i].contains('}')) braceCount -= '}'.allMatches(lines[i]).length;
      if (braceCount == 0) {
        globalDashboardEnd = i;
        break;
      }
    }
    if (globalDashboardEnd != -1) {
      lines.removeRange(globalDashboardStart, globalDashboardEnd + 1);
    }
  }

  // Write back
  file.writeAsStringSync(lines.join('\n'));
  print('Removed dead code from parent_home_page.dart');
}
