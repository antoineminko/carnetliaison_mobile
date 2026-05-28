import re

file_path = 'lib/features/parent/widgets/child_details_view.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Clean _buildTeachersTab
teachers_pattern = r"Widget _buildTeachersTab\(\) \{[\s\S]*?final List<Map<String, dynamic>> teachers;[\s\S]*?if \(childName == 'Yannick'\) \{[\s\S]*?\}\s*return ListView\.builder\("

teachers_replace = '''Widget _buildTeachersTab() {
    final List<dynamic> teachers = _dashboardData?['teachers'] ?? [];

    if (teachers.isEmpty) {
      return const Center(child: Text('Aucun professeur trouvé.', style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder('''

content = re.sub(teachers_pattern, teachers_replace, content)

# 2. Clean _buildNotesTab
notes_pattern = r"Widget _buildNotesTab\(\) \{[\s\S]*?final List<Map<String, dynamic>> grades;[\s\S]*?if \(childName == 'Yannick'\) \{[\s\S]*?\}\s*return SingleChildScrollView\("

notes_replace = '''Widget _buildNotesTab() {
    final List<dynamic> grades = _dashboardData?['grades'] ?? [];

    return SingleChildScrollView('''

content = re.sub(notes_pattern, notes_replace, content)

# 3. Clean _buildStatsTab
stats_pattern = r"String average = '10\.00';\s*String absences = '0j';\s*String conduite = 'A';\s*if \(childName == 'Yannick'\) \{[\s\S]*?\}\s*return Container\("

stats_replace = '''String average = 'N/A';
    String absences = 'N/A';
    String conduite = 'N/A';
    
    // In a real scenario we could get this from _dashboardData
    if (_dashboardData != null && _dashboardData!['attendance'] != null) {
      absences = _dashboardData!['attendance']['statut'] == 'Absente' || _dashboardData!['attendance']['statut'] == 'Absent' ? '1j' : '0j';
    }

    return Container('''

content = re.sub(stats_pattern, stats_replace, content)

# 4. Clean _buildEvolutionGraph
graph_pattern = r"Widget _buildEvolutionGraph\(\) \{[\s\S]*?if \(childName == 'Yannick'\) \{[\s\S]*?\}\s*return Container\("

graph_replace = '''Widget _buildEvolutionGraph() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            termBadge('1er Trimestre', '12', '10ᵉ'),
            const SizedBox(width: 10),
            termBadge('2ᵉ Trimestre', '10', '20ᵉ'),
            const SizedBox(width: 10),
            termBadge('3ᵉ Trimestre', '', '', isPending: true),
          ],
        ),
      ],
    );
  }

  Widget _oldBuildEvolutionGraph() {
    return Container('''

content = re.sub(graph_pattern, graph_replace, content)

# 5. Clean _buildAssignmentAlertNotification
alert_pattern = r"String title = 'Alerte Régression';[\s\S]*?if \(childName == 'Yannick'\) \{[\s\S]*?color = Colors\.blue;\s*\}\s*return Container\("

alert_replace = '''String title = 'Point de vigilance';
    String message = 'Maintenez les efforts pour ce trimestre.';
    Color color = Colors.blue;

    return Container('''

content = re.sub(alert_pattern, alert_replace, content)


with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

