import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';

void showStudentStatsDialog({
  required BuildContext context,
  required dynamic student,
  required VoidCallback onShowParent,
}) {
  final name = student['prenom'];
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Statistiques : $name'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (name == 'Junior') ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.sunYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.sunYellow.withOpacity(0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.trending_down, color: AppTheme.sunYellow),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Baisse de performance détectée en Sciences.',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
            ],
            _buildStatRow('Moyenne Générale', name == 'Junior' ? '09.5/20' : '14.2/20'),
            _buildStatRow('Devoirs Rendus', name == 'Junior' ? '65%' : '98%'),
            _buildStatRow('Participation', name == 'Junior' ? 'Faible' : 'Excellente'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fermer'),
        ),
        if (name == 'Junior')
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onShowParent();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.seaBlue, foregroundColor: Colors.white),
            child: const Text('Discuter avec le parent'),
          ),
      ],
    ),
  );
}

Widget _buildStatRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textGrey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
      ],
    ),
  );
}
