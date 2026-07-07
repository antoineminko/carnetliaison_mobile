import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';

class HomeworkClassSelector extends StatelessWidget {
  final List<Map<String, dynamic>> classes;
  final Map<String, dynamic>? selectedClass;
  final ValueChanged<Map<String, dynamic>?> onChanged;

  const HomeworkClassSelector({
    super.key,
    required this.classes,
    required this.selectedClass,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (classes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text('Aucune classe assignée', style: TextStyle(color: Colors.grey)),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sélectionner une classe', style: TextStyle(fontSize: 12, color: AppTheme.textGrey)),
          const SizedBox(height: 10),
          DropdownButtonFormField<Map<String, dynamic>>(
            value: selectedClass,
            isExpanded: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.seaBlue),
              ),
            ),
            items: classes.map((classe) {
              return DropdownMenuItem(
                value: classe,
                child: Text('${classe['nom']} ${classe['ecole_nom'] != null ? '(${classe['ecole_nom']})' : ''}'),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
