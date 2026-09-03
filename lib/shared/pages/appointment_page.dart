import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/shared/config/api_client.dart';
import 'package:app_mobile/features/auth/services/auth_service.dart';

enum AppointmentSource { parent, teacher }

class AppointmentPage extends StatefulWidget {
  final AppointmentSource source;
  final String targetName; // Nom du prof pour le parent, ou du parent pour le prof
  final String? studentName;
  final int? enseignantId;
  final int? eleveId;
  final List<int>? targetParentIds;

  const AppointmentPage({
    super.key,
    required this.source,
    required this.targetName,
    this.studentName,
    this.enseignantId,
    this.eleveId,
    this.targetParentIds,
  });

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  String selectedMode = 'video';
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
  String? selectedSlot;
  String? selectedMotive;
  final TextEditingController _objetController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<String> motives = [
    'Suivi des notes',
    'Comportement en classe',
    'Difficultés d\'apprentissage',
    'Orientation scolaire',
    'Autre motif'
  ];

  final List<String> timeSlots = [
    '08:00', '09:30', '11:00', '14:30', '16:00', '17:30'
  ];

  @override
  void dispose() {
    _objetController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Prendre Rendez-vous', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Target Info
            _buildTargetHeader(),
            
            const SizedBox(height: 25),
            
            // Mode Selection
            _buildSectionTitle('Mode de rencontre'),
            Row(
              children: [
                _buildModeCard('presentiel', Icons.location_on_outlined, 'Présentiel', 'À l\'école'),
                const SizedBox(width: 8),
                _buildModeCard('vocal', Icons.phone_outlined, 'Vocal', 'Téléphone'),
                const SizedBox(width: 8),
                _buildModeCard('video', Icons.videocam_outlined, 'Vidéo', 'En ligne'),
              ],
            ),

            const SizedBox(height: 25),

            // Objet du rendez-vous
            _buildSectionTitle('Objet du rendez-vous'),
            TextField(
              controller: _objetController,
              decoration: InputDecoration(
                hintText: 'Ex: Suivi trimestriel de ${widget.studentName ?? "l'élève"}',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: AppTheme.seaBlue, width: 2),
                ),
              ),
            ),
            
            const SizedBox(height: 25),

            // Motive Selection
            _buildSectionTitle('Motif du rendez-vous'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text('Choisir un motif'),
                  value: selectedMotive,
                  items: motives.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                  onChanged: (v) => setState(() => selectedMotive = v),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Date Selection
            _buildSectionTitle('Choisir une date'),
            _buildFullCalendar(),

            const SizedBox(height: 25),

            // Slots
            _buildSectionTitle('Créneaux disponibles'),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: timeSlots.map((slot) => _buildSlotChip(slot)).toList(),
            ),

            const SizedBox(height: 40),

            // Description optionnelle
            const SizedBox(height: 25),
            _buildSectionTitle('Description / Détails (optionnel)'),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Précisez ici les points que vous souhaitez aborder...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: AppTheme.seaBlue, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: selectedSlot != null && selectedMotive != null && _objetController.text.isNotEmpty && !_isSending
                    ? () => _submit() 
                    : null,
                style: AppTheme.primaryButtonStyle,
                child: _isSending 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Confirmer le rendez-vous', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSending = false;

  Future<void> _submit() async {
    setState(() => _isSending = true);

    try {
      final parts = selectedSlot!.split(':');
      final dateHeure = DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day,
        int.parse(parts[0]), int.parse(parts[1]),
      );

      if (widget.source == AppointmentSource.teacher && widget.targetParentIds != null && widget.targetParentIds!.isNotEmpty) {
        for (int pId in widget.targetParentIds!) {
          await ApiClient.instance.post('/appointments', data: {
            'enseignant_id': widget.enseignantId ?? 1,
            'parent_id': pId,
            'eleve_id': widget.eleveId,
            'objet': _objetController.text,
            'date_heure': dateHeure.toIso8601String(),
            'mode': selectedMode,
            'motif': selectedMotive,
            'requester': 'enseignant',
          });
        }
      } else {
        final parentId = await AuthService.getParentId();
        await ApiClient.instance.post('/appointments', data: {
          'enseignant_id': widget.enseignantId ?? 1,
          'parent_id': parentId ?? 1,
          'eleve_id': widget.eleveId,
          'objet': _objetController.text,
          'date_heure': dateHeure.toIso8601String(),
          'mode': selectedMode,
          'motif': selectedMotive,
          'requester': widget.source == AppointmentSource.parent ? 'parent' : 'enseignant',
        });
      }

      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Widget _buildTargetHeader() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.seaBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppTheme.seaBlue.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.seaBlue,
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.source == AppointmentSource.parent ? 'Enseignant :' : 'Parent :',
                style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
              ),
              Text(
                widget.targetName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              if (widget.studentName != null)
                Text(
                  'Élève : ${widget.studentName}',
                  style: TextStyle(color: AppTheme.seaBlue, fontSize: 12, fontWeight: FontWeight.w500),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textGrey, letterSpacing: 1.1),
      ),
    );
  }

  Widget _buildModeCard(String modeValue, IconData icon, String title, String subtitle) {
    bool isSelected = selectedMode == modeValue;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedMode = modeValue),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: isSelected ? AppTheme.seaBlue : Colors.grey[200]!, width: 2),
            boxShadow: isSelected ? [BoxShadow(color: AppTheme.seaBlue.withValues(alpha: 0.1), blurRadius: 10)] : [],
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppTheme.seaBlue : AppTheme.textGrey, size: 24),
              const SizedBox(height: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? AppTheme.seaBlue : AppTheme.textDark, fontSize: 12)),
              Text(subtitle, style: TextStyle(fontSize: 10, color: AppTheme.textGrey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: CalendarDatePicker(
        initialDate: selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 90)),
        onDateChanged: (date) {
          setState(() {
            selectedDate = date;
          });
        },
      ),
    );
  }

  Widget _buildSlotChip(String slot) {
    bool isSelected = selectedSlot == slot;
    return GestureDetector(
      onTap: () => setState(() => selectedSlot = slot),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.seaBlue : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppTheme.seaBlue : Colors.grey[200]!),
        ),
        child: Text(
          slot,
          style: TextStyle(color: isSelected ? Colors.white : AppTheme.textDark, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: AppTheme.forestGreen, size: 80),
            const SizedBox(height: 20),
            const Text('Demande envoyée !', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 10),
            Text(
              'Un message a été envoyé à ${widget.targetName}. Vous recevrez une notification dès confirmation.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textGrey),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Back to previous page
                },
                style: AppTheme.primaryButtonStyle,
                child: const Text('Fermer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

