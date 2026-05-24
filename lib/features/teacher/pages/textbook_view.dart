import 'package:flutter/material.dart';

class TextbookView extends StatefulWidget {
  final String className;
  final String subject;
  const TextbookView({super.key, required this.className, required this.subject});

  @override
  State<TextbookView> createState() => _TextbookViewState();
}

class _TextbookViewState extends State<TextbookView> {
  String? _selectedSubject;
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _homeworkController = TextEditingController();
  String _homeworkTime = '15 min';

  @override
  void initState() {
    super.initState();
    _selectedSubject = widget.subject;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100, left: 20, right: 20, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. IDENTIFICATION DU COURS
          _buildSectionHeader(Icons.book, 'Identification du cours'),
          _buildFormCard([
            _buildLabel('Sélectionner la matière'),
            _buildDropdown(
              hint: '-- Choisir une matière --',
              value: _selectedSubject,
              items: {
                'Mathématiques',
                'Français',
                'Histoire-Géo',
                'Sciences',
                'Philosophie',
                'Physique-Chimie',
                widget.subject,
              }.toList(),
              onChanged: (val) => setState(() => _selectedSubject = val),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Classe'),
                      _buildFixedText(widget.className),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Date du cours'),
                      _buildDatePicker('24/02/2026'),
                    ],
                  ),
                ),
              ],
            ),
          ]),

          const SizedBox(height: 25),

          // 2. RÉSUMÉ DU COURS
          _buildSectionHeader(Icons.edit_note, 'Résumé du cours'),
          _buildFormCard([
            _buildLabel('Contenu de la séance fait en classe'),
            _buildTextArea(
              controller: _contentController,
              hint: 'Décrivez les notions abordées aujourd\'hui...',
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                _buildActionChip(Icons.attach_file, 'Ajouter un document'),
                const SizedBox(width: 10),
                _buildActionChip(Icons.link, 'Lien externe'),
              ],
            ),
          ]),

          const SizedBox(height: 25),

          // 3. EXERCICES À FAIRE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionHeader(Icons.assignment_outlined, 'Exercices à faire'),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_circle, size: 18, color: Colors.blue),
                label: const Text('Ajouter', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          _buildFormCard([
            _buildLabel('Description du travail'),
            _buildTextField(
              controller: _homeworkController,
              hint: 'Ex: Exercices 1 à 5 page 42',
            ),
            const SizedBox(height: 15),
            _buildLabel('Date d\'échéance'),
            _buildDatePicker('mm/dd/yyyy'),
            const SizedBox(height: 15),
            _buildLabel('Estimation temps'),
            _buildDropdown(
              value: _homeworkTime,
              items: ['15 min', '30 min', '45 min', '1h+'],
              onChanged: (val) => setState(() => _homeworkTime = val!),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[700], size: 22),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey[600],
        ),
      ),
    );
  }

  Widget _buildDropdown({String? hint, String? value, required List<String> items, required Function(String?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: hint != null ? Text(hint, style: TextStyle(color: Colors.grey[400], fontSize: 14)) : null,
          value: value,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildFixedText(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildDatePicker(String hint) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(hint, style: TextStyle(color: hint.contains('/') ? Colors.black87 : Colors.grey[400], fontSize: 14)),
          Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
        ],
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        fillColor: const Color(0xFFF8FAFC),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blue),
        ),
      ),
    );
  }

  Widget _buildTextArea({required TextEditingController controller, required String hint}) {
    return TextField(
      controller: controller,
      maxLines: 5,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        fillColor: const Color(0xFFF8FAFC),
        filled: true,
        contentPadding: const EdgeInsets.all(12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blue),
        ),
      ),
    );
  }

  Widget _buildActionChip(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.blue[600]),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue[600]),
            ),
          ],
        ),
      ),
    );
  }
}
