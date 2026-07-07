import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';

class HomeworkTypeSelector extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onTypeChanged;

  const HomeworkTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final types = [
      {'id': 'maison', 'label': 'Devoir de maison', 'icon': Icons.home_work, 'color': Colors.blue, 'desc': 'À faire chez soi'},
      {'id': 'classe', 'label': 'Devoir de classe', 'icon': Icons.school, 'color': Colors.green, 'desc': 'À faire en classe'},
      {'id': 'exercice', 'label': 'Exercice maison', 'icon': Icons.edit_note, 'color': Colors.orange, 'desc': 'Exercices pratiques'},
    ];

    return Column(
      children: types.map((type) {
        final isSelected = selectedType == type['id'];
        return GestureDetector(
          onTap: () => onTypeChanged(type['id'] as String),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? (type['color'] as Color).withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? (type['color'] as Color) : Colors.grey[200]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (type['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(type['icon'] as IconData, color: type['color'] as Color, size: 24),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type['label'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? (type['color'] as Color) : AppTheme.textDark,
                        ),
                      ),
                      Text(
                        type['desc'] as String,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: type['color'] as Color, size: 28),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
