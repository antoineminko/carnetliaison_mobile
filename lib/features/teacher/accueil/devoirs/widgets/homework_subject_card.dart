import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';

class HomeworkSubjectCard extends StatelessWidget {
  final String subject;

  const HomeworkSubjectCard({
    super.key,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.seaBlue.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.seaBlue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.seaBlue.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.calculate_outlined, color: AppTheme.seaBlue, size: 22),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'MATIÈRE ENSEIGNÉE',
                style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.textGrey,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subject,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.seaBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
