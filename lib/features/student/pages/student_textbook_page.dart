import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'student_details_pages.dart';

class StudentTextbookPage extends StatelessWidget {
  const StudentTextbookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Cahier de Texte', style: TextStyle(color: AppTheme.seaBlue, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildTextbookItem(
            context,
            subject: 'Philosophie',
            title: 'La conscience et l\'inconscient',
            date: 'Hier, 08:30',
            hasAttachment: true,
            color: AppTheme.seaBlue,
          ),
          _buildTextbookItem(
            context,
            subject: 'Mathématiques',
            title: 'Nombres Complexes : Forme algébrique',
            date: 'Hier, 10:30',
            hasAttachment: true,
            color: Colors.red,
          ),
          _buildTextbookItem(
            context,
            subject: 'Français - Littérature',
            title: 'Analyse : Les Fleurs du Mal (Baudelaire)',
            date: '24 Fév, 14:00',
            hasAttachment: false,
            color: AppTheme.forestGreen,
          ),
          _buildTextbookItem(
            context,
            subject: 'Histoire-Géo',
            title: 'Le monde en 1945 : Nouveau rapport de force',
            date: '23 Fév, 11:15',
            hasAttachment: true,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildTextbookItem(BuildContext context, {required String subject, required String title, required String date, required bool hasAttachment, required Color color}) {
    return InkWell(
      onTap: () => Navigator.push(
        context, 
        MaterialPageRoute(
          builder: (_) => LessonDetailPage(
            title: title,
            subject: subject,
            date: date,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
              child: Icon(Icons.book, color: color, size: 24),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subject, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark)),
                  const SizedBox(height: 4),
                  Text(date, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                ],
              ),
            ),
            if (hasAttachment)
              const Icon(Icons.attach_file, color: Colors.grey, size: 18),
            const SizedBox(width: 5),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
