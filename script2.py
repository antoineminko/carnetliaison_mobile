import re

file_path = 'lib/features/parent/widgets/child_details_view.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Fix Teachers Tab
teachers_replacement = '''
  Widget _buildTeachersTab() {
    List<Map<String, dynamic>> teachers = [];
    if (widget.child['fromApi'] == true && _dashboardData != null) {
      final ts = _dashboardData!['teachers'] as List<dynamic>? ?? [];
      for (var t in ts) {
        teachers.add({
          'name': ' '.trim(),
          'subject': t['matiere'] ?? 'Général',
          'color': t['is_principal'] == true ? AppTheme.seaBlue : Colors.grey[700],
          'mode': 'Présentiel',
          'is_principal': t['is_principal'] == true,
        });
      }
    }

    if (teachers.isEmpty) {
      return const Center(child: Text('Aucun professeur trouvé', style: TextStyle(color: Colors.grey)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CORPS ENSEIGNANT',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 15),
          ...teachers.map((t) => _buildTeacherCard(t)),
        ],
      ),
    );
  }'''

content = re.sub(
    r"Widget _buildTeachersTab\(\) \{[\s\S]*?Widget _buildTeacherCard\(Map<String, dynamic> t\) \{",
    teachers_replacement.strip() + r"\n\n  Widget _buildTeacherCard(Map<String, dynamic> t) {",
    content
)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
