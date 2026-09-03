import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';

class HomeworkDynamicForm extends StatelessWidget {
  final String selectedType;
  final TextEditingController titleController;
  
  // Dynamic fields
  final Map<String, TextEditingController> dynamicControllers;

  const HomeworkDynamicForm({
    super.key,
    required this.selectedType,
    required this.titleController,
    required this.dynamicControllers,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(titleController, 'Titre du devoir', 'Ex: Fonctions linéaires — Chapitre 4'),
          const SizedBox(height: 15),
          
          if (selectedType == 'maison' || selectedType == 'autre') ...[
            _buildTextField(dynamicControllers['consignes']!, 'Consignes et détails', 'Consignes spéciales...', maxLines: 5),
          ] else if (selectedType == 'classe') ...[
            _buildTextField(dynamicControllers['chapitre']!, 'Chapitre', 'Ex: Chapitre 4'),
            const SizedBox(height: 15),
            _buildTextField(dynamicControllers['objectif']!, 'Objectif', 'Ex: Évaluer la compréhension'),
            const SizedBox(height: 15),
            _buildTextField(dynamicControllers['consignes']!, 'Consignes', 'Matériel autorisé...', maxLines: 3),
          ] else if (selectedType == 'exercice') ...[
            _buildTextField(dynamicControllers['livre']!, 'Livre', 'Ex: Mathématiques 3e'),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: _buildTextField(dynamicControllers['page']!, 'Page', 'Ex: 42')),
                const SizedBox(width: 15),
                Expanded(child: _buildTextField(dynamicControllers['numeros']!, 'Numéros', 'Ex: 1, 2 et 3')),
              ],
            ),
            const SizedBox(height: 15),
            _buildTextField(dynamicControllers['consignes']!, 'Consignes particulières', 'Ex: Sans calculatrice', maxLines: 3),
          ] else if (selectedType == 'recherche') ...[
            _buildTextField(dynamicControllers['sujet']!, 'Sujet', 'Ex: La révolution française'),
            const SizedBox(height: 15),
            _buildTextField(dynamicControllers['documents']!, 'Documents attendus', 'Ex: 2 pages, 1 image'),
            const SizedBox(height: 15),
            _buildTextField(dynamicControllers['format']!, 'Format de rendu', 'Ex: PDF, Exposé'),
          ] else if (selectedType == 'revision') ...[
            _buildTextField(dynamicControllers['chapitre']!, 'Chapitre concerné', 'Ex: Chapitre 4'),
            const SizedBox(height: 15),
            _buildTextField(dynamicControllers['notions']!, 'Notions à revoir', 'Ex: Théorème de Pythagore', maxLines: 3),
            const SizedBox(height: 15),
            _buildTextField(dynamicControllers['conseils']!, 'Conseils de révision', 'Ressources utiles...', maxLines: 3),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
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
    );
  }
}
