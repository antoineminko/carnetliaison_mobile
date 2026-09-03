import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';

void showConvocationChoiceDialog({
  required BuildContext context,
  required VoidCallback onSendMessage,
  required VoidCallback onScheduleAppointment,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Que souhaitez-vous faire ?', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          _buildChoiceButton(
            icon: Icons.message_rounded,
            title: 'Envoyer un message aux parents',
            color: AppTheme.seaBlue,
            onTap: () {
              Navigator.pop(context);
              onSendMessage();
            },
          ),
          const SizedBox(height: 15),
          _buildChoiceButton(
            icon: Icons.calendar_today_rounded,
            title: 'Prendre un rendez-vous',
            color: AppTheme.sunYellow,
            onTap: () {
              Navigator.pop(context);
              onScheduleAppointment();
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler', style: TextStyle(color: AppTheme.textGrey)),
        ),
      ],
    ),
  );
}

Widget _buildChoiceButton({
  required IconData icon,
  required String title,
  required Color color,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(15),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: color,
              ),
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: color, size: 16),
        ],
      ),
    ),
  );
}
