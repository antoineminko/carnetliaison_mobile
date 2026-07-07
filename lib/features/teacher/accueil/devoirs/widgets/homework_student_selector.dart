import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';

class HomeworkStudentSelector extends StatelessWidget {
  final List<Map<String, dynamic>> students;
  final List<int> selectedStudents;
  final bool selectAllStudents;
  final VoidCallback onToggleSelectAll;
  final ValueChanged<int> onToggleStudent;

  const HomeworkStudentSelector({
    super.key,
    required this.students,
    required this.selectedStudents,
    required this.selectAllStudents,
    required this.onToggleSelectAll,
    required this.onToggleStudent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${selectedStudents.length} élève${selectedStudents.length > 1 ? 's' : ''} sélectionné${selectedStudents.length > 1 ? 's' : ''}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: onToggleSelectAll,
                icon: Icon(selectAllStudents ? Icons.deselect : Icons.select_all, size: 18),
                label: Text(selectAllStudents ? 'Tout désélectionner' : 'Tout sélectionner'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.seaBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),
          if (students.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('Aucun élève dans cette classe', style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: students.map((student) {
                final isSelected = selectedStudents.contains(student['id']);
                return FilterChip(
                  avatar: CircleAvatar(
                    radius: 14,
                    backgroundImage: student['photo_url'] != null
                        ? NetworkImage(student['photo_url'])
                        : null,
                    child: student['photo_url'] == null
                        ? Text('${student['prenom']?[0] ?? ''}${student['nom']?[0] ?? ''}')
                        : null,
                  ),
                  label: Text('${student['prenom']} ${student['nom']}'),
                  selected: isSelected,
                  onSelected: (_) => onToggleStudent(student['id'] as int),
                  selectedColor: AppTheme.seaBlue.withOpacity(0.2),
                  checkmarkColor: AppTheme.seaBlue,
                  backgroundColor: Colors.grey[100],
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
