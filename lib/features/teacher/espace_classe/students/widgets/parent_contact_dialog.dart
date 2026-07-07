import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/shared/pages/appointment_page.dart';

void showParentContactDialog({
  required BuildContext context,
  required dynamic student,
}) {
  final name = student['prenom'] ?? 'Élève';
  final fullName = "${student['prenom'] ?? ''} ${student['nom'] ?? ''}".trim();
  final parentName = student['parent_nom'] ?? student['parent'] ?? 'Parent inconnu';
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Parent de $name'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.person)),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(parentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Text('Père', style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildContactRow(Icons.phone, '+241 07 45 89 12'),
            const SizedBox(height: 10),
            _buildContactRow(Icons.email, 'dgall.ewosso@email.com'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Retour', style: TextStyle(color: AppTheme.textGrey)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AppointmentPage(
                  source: AppointmentSource.teacher,
                  targetName: parentName,
                  studentName: fullName,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.sunYellow,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Convoquer'),
        ),
      ],
    ),
  );
}

Widget _buildContactRow(IconData icon, String text) {
  return Row(
    children: [
      Icon(icon, size: 16, color: AppTheme.seaBlue),
      const SizedBox(width: 10),
      Text(text, style: const TextStyle(fontSize: 13)),
    ],
  );
}
