import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:app_mobile/features/teacher/services/teacher_textbook_service.dart';
import 'package:intl/intl.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';

class TextbookView extends StatefulWidget {
  final int classId;
  final int teacherId;
  final String className;
  final String subject;
  const TextbookView({super.key, required this.className, required this.subject, required this.classId, required this.teacherId});

  @override
  State<TextbookView> createState() => _TextbookViewState();
}

class _TextbookViewState extends State<TextbookView> {
  String? _selectedSubject;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  
  // Exercises
  final TextEditingController _hwDescriptionController = TextEditingController();
  final TextEditingController _hwPageController = TextEditingController();
  final TextEditingController _hwNumbersController = TextEditingController();
  final TextEditingController _hwInstructionsController = TextEditingController();
  DateTime? _hwDueDate;

  bool _isSubmitting = false;
  bool _isGeneratingAi = false;
  DateTime _dateCours = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedSubject = widget.subject;
  }

  Future<void> _selectDateCours() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateCours,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _dateCours) {
      setState(() {
        _dateCours = picked;
      });
    }
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _hwDueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _hwDueDate = picked;
      });
    }
  }

  Future<void> _generateAiSummary() async {
    if (_contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez saisir le contenu détaillé avant de générer le résumé.')));
      return;
    }

    setState(() => _isGeneratingAi = true);

    try {
      final response = await TeacherTextbookService.instance.generateSummary(_contentController.text);
      if (response.data['success'] == true) {
        setState(() {
          _summaryController.text = response.data['summary'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur lors de la génération IA.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur IA: $e')));
    } finally {
      if (mounted) setState(() => _isGeneratingAi = false);
    }
  }

  Future<void> _submitCahierTexte() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez remplir le titre et le contenu de la séance')));
      return;
    }

    setState(() => _isSubmitting = true);

    Map<String, dynamic>? exercices;
    if (_hwDescriptionController.text.isNotEmpty) {
      exercices = {
        'description': _hwDescriptionController.text,
        'page': _hwPageController.text,
        'numeros': _hwNumbersController.text,
        'consignes': _hwInstructionsController.text,
        'date_echeance': _hwDueDate != null ? DateFormat('yyyy-MM-dd').format(_hwDueDate!) : null,
      };
    }

    try {
      await TeacherTextbookService.instance.createTextbook({
        'classe_id': widget.classId,
        'enseignant_id': widget.teacherId,
        'titre': _titleController.text,
        'matiere': _selectedSubject ?? widget.subject,
        'date_cours': DateFormat('yyyy-MM-dd').format(_dateCours),
        'contenu_realise': _contentController.text,
        'resume_cours': _summaryController.text,
        'exercices_donnes': exercices != null ? jsonEncode(exercices) : null,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cahier de textes enregistré et notifié avec succès !')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(widget.className, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100, left: 20, right: 20, top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // 1. IDENTIFICATION DU COURS
          _buildSectionHeader(Icons.book, 'Identification du cours'),
          _buildFormCard([
            _buildLabel('Titre du cours'),
            _buildTextField(
              controller: _titleController,
              hint: 'Ex: Les fractions décimales',
            ),
            const SizedBox(height: 15),
            _buildLabel('Sélectionner la matière'),
            _buildDropdown(
              hint: '-- Choisir une matière --',
              value: _selectedSubject,
              items: <String>{
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
                      GestureDetector(
                        onTap: _selectDateCours,
                        child: _buildDatePicker(DateFormat('dd/MM/yyyy').format(_dateCours)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ]),

          const SizedBox(height: 25),

          // 2. CONTENU ET RÉSUMÉ DU COURS
          _buildSectionHeader(Icons.edit_note, 'Contenu du cours'),
          _buildFormCard([
            _buildLabel('Contenu détaillé fait en classe'),
            _buildTextArea(
              controller: _contentController,
              hint: 'Décrivez les notions abordées aujourd\'hui de manière détaillée...',
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _buildLabel('Résumé pédagogique')),
                TextButton.icon(
                  onPressed: _isGeneratingAi ? null : _generateAiSummary,
                  icon: _isGeneratingAi 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.auto_awesome, color: Colors.purple, size: 18),
                  label: Text(
                    _isGeneratingAi ? 'Génération...' : '✨ Générer avec l\'IA', 
                    style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)
                  ),
                ),
              ],
            ),
            _buildTextArea(
              controller: _summaryController,
              hint: 'Résumé concis pour les parents...',
            ),
          ]),

          const SizedBox(height: 25),

          // 3. EXERCICES À FAIRE
          _buildSectionHeader(Icons.assignment_outlined, 'Exercices à faire'),
          _buildFormCard([
            _buildLabel('Description générale'),
            _buildTextField(
              controller: _hwDescriptionController,
              hint: 'Ex: Faire les exercices sur les fractions',
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Page du manuel'),
                      _buildTextField(
                        controller: _hwPageController,
                        hint: 'Ex: p. 42',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Numéros'),
                      _buildTextField(
                        controller: _hwNumbersController,
                        hint: 'Ex: n° 1, 2 et 3',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _buildLabel('Consignes particulières'),
            _buildTextField(
              controller: _hwInstructionsController,
              hint: 'Ex: Ne pas utiliser la calculatrice',
            ),
            const SizedBox(height: 15),
            _buildLabel('Date d\'échéance'),
            GestureDetector(
              onTap: _selectDueDate,
              child: _buildDatePicker(_hwDueDate != null ? DateFormat('dd/MM/yyyy').format(_hwDueDate!) : '-- / -- / ----'),
            ),
          ]),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitCahierTexte,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.seaBlue,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Valider et Envoyer', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    ));
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
}
