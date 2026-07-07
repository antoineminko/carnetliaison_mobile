import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';

class HomeworkDatePicker extends StatelessWidget {
  final DateTime dueDate;
  final ValueChanged<DateTime> onDateChanged;

  const HomeworkDatePicker({
    super.key,
    required this.dueDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: dueDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          helpText: 'DATE DE REMISE DU DEVOIR',
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(primary: AppTheme.seaBlue),
            ),
            child: child!,
          ),
        );
        if (picked != null) {
          onDateChanged(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppTheme.seaBlue.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, color: AppTheme.seaBlue),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Date de remise', style: TextStyle(fontSize: 11, color: AppTheme.textGrey)),
                Text(
                  '${dueDate.day.toString().padLeft(2, '0')}/${dueDate.month.toString().padLeft(2, '0')}/${dueDate.year}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppTheme.seaBlue),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.edit_calendar_rounded, size: 20, color: AppTheme.textGrey),
          ],
        ),
      ),
    );
  }
}
