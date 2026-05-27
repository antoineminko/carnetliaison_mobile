import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/shared/config/api_client.dart';

class CreateHomeworkPage extends StatefulWidget {
  const CreateHomeworkPage({super.key});

  @override
  State<CreateHomeworkPage> createState() => _CreateHomeworkPageState();
}

class _CreateHomeworkPageState extends State<CreateHomeworkPage> {
  final String _subject = 'Mathématiques';
  String? _selectedClass = '3ème B';
  int _selectedClassId = 1; // ID de la classe pour la démo
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  DateTime _dueDate = DateTime.now().add(const Duration(days: 2));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Créer un devoir', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Matière fixée (non modifiable)
            _buildSectionTitle('Matière'),
            const SizedBox(height: 10),
            Container(
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
                      const Text('MATIÈRE ENSEIGNÉE', style: TextStyle(fontSize: 10, color: AppTheme.textGrey, letterSpacing: 1.0, fontWeight: FontWeight.bold)),
                      Text(_subject, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.seaBlue)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
            _buildSectionTitle('Classe cible'),
            const SizedBox(height: 10),
            _buildSelectionCard(),

            const SizedBox(height: 25),
            _buildSectionTitle('Détails du devoir'),
            const SizedBox(height: 10),
            _buildDetailsCard(),

            const SizedBox(height: 25),
            _buildSectionTitle('Date de remise'),
            const SizedBox(height: 10),
            _buildDatePicker(),

            const SizedBox(height: 40),
            _buildSubmitButton(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textGrey, letterSpacing: 1.1),
    );
  }

  Widget _buildSelectionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: _buildDropdown(
        label: 'Classe',
        value: _selectedClass,
        items: ['3ème B', 'Terminale A', 'Terminale C', '2nde S'],
        onChanged: (val) {
          setState(() {
            _selectedClass = val;
            if (val == '3ème B') _selectedClassId = 1;
            if (val == 'Terminale A') _selectedClassId = 2;
            if (val == 'Terminale C') _selectedClassId = 3;
            if (val == '2nde S') _selectedClassId = 4;
          });
        },
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'Titre du devoir (ex: Fonctions linéaires — Chapitre 4)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.seaBlue)),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _descController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Consignes, exercices à faire, chapitres concernés...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.seaBlue)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _dueDate,
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
        if (picked != null) setState(() => _dueDate = picked);
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
                  '${_dueDate.day.toString().padLeft(2, '0')}/${_dueDate.month.toString().padLeft(2, '0')}/${_dueDate.year}',
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

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: _publishDevoir,
        icon: const Icon(Icons.upload_file_rounded, color: Colors.white),
        label: const Text('Publier le devoir', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.forestGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
      ),
    );
  }

  Future<void> _publishDevoir() async {
    final title = _titleController.text.trim().isEmpty ? 'Devoir de Mathématiques' : _titleController.text.trim();
    final desc = _descController.text.trim().isEmpty ? 'Aucune description' : _descController.text.trim();
    final due = '${_dueDate.year}-${_dueDate.month.toString().padLeft(2, '0')}-${_dueDate.day.toString().padLeft(2, '0')}';
    final dueDisplay = '${_dueDate.day.toString().padLeft(2, '0')}/${_dueDate.month.toString().padLeft(2, '0')}/${_dueDate.year}';

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator(color: AppTheme.seaBlue)),
      );

      final response = await ApiClient.instance.post('/devoirs', data: {
        'classe_id': _selectedClassId,
        'enseignant_id': 1, // Fixé pour la démo
        'matiere': _subject,
        'titre': title,
        'description': desc,
        'date_remise': due,
      });

      // Fermer le loader
      if (mounted) Navigator.pop(context);

      if (response.statusCode == 201) {
        if (!mounted) return;
        _showSuccessDialog(title, dueDisplay);
      } else {
        throw Exception('Erreur serveur');
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Fermer le loader
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la publication : $e')),
      );
    }
  }

  void _showSuccessDialog(String title, String dueDisplay) {

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.forestGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppTheme.forestGreen, size: 48),
            ),
            const SizedBox(height: 16),
            const Text('Devoir publié !', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            // Récap structuré
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRecapRow(Icons.calculate_outlined, 'Matière', _subject, AppTheme.seaBlue),
                  const Divider(height: 16),
                  _buildRecapRow(Icons.class_outlined, 'Classe', _selectedClass ?? '3ème B', AppTheme.forestGreen),
                  const Divider(height: 16),
                  _buildRecapRow(Icons.title_rounded, 'Titre', title, AppTheme.textDark),
                  const Divider(height: 16),
                  _buildRecapRow(Icons.event_rounded, 'Date de remise', dueDisplay, Colors.orange),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);    // ferme le dialog
                  Navigator.pop(context); // retour page accueil M.Obiang
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.seaBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecapRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 10),
        Text('$label : ', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildDropdown({required String label, required String? value, required List<String> items, required Function(String?) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
        DropdownButton<String>(
          value: value,
          isExpanded: true,
          underline: const SizedBox(),
          items: items.map((String val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
