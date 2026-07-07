import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';

class HomeworkDetailsForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descController;
  final TextEditingController durationController;
  final String selectedType;

  const HomeworkDetailsForm({
    super.key,
    required this.titleController,
    required this.descController,
    required this.durationController,
    required this.selectedType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              labelText: 'Titre du devoir',
              hintText: 'Ex: Fonctions linéaires — Chapitre 4',
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
          ),
          const SizedBox(height: 15),
          TextField(
            controller: descController,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: 'Consignes et détails',
              hintText: 'Exercices à faire, chapitres concernés, consignes spéciales...',
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
          ),
          // Champ durée estimée uniquement pour devoir de maison
          if (selectedType == 'maison' || selectedType == 'exercice') ...[
            const SizedBox(height: 15),
            TextField(
              controller: durationController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Durée estimée (minutes)',
                hintText: 'Ex: 30',
                prefixIcon: const Icon(Icons.timer),
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
            ),
          ],
        ],
      ),
    );
  }
}
