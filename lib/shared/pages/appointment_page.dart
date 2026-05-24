import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';

enum AppointmentSource { parent, teacher }

class AppointmentPage extends StatefulWidget {
  final AppointmentSource source;
  final String targetName; // Nom du prof pour le parent, ou du parent pour le prof
  final String? studentName;

  const AppointmentPage({
    super.key,
    required this.source,
    required this.targetName,
    this.studentName,
  });

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  String selectedMode = 'Visio';
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
  String? selectedSlot;
  String? selectedMotive;

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
                _buildModeCard('Présentiel', Icons.location_on_outlined, 'À l\'école'),
                const SizedBox(width: 15),
                _buildModeCard('Visio', Icons.videocam_outlined, 'En ligne'),
              ],
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

            // Confirm Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: selectedSlot != null && selectedMotive != null 
                    ? () => _showSuccessDialog() 
                    : null,
                style: AppTheme.primaryButtonStyle,
                child: const Text('Confirmer le rendez-vous', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetHeader() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.seaBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppTheme.seaBlue.withOpacity(0.1)),
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

  Widget _buildModeCard(String mode, IconData icon, String subtitle) {
    bool isSelected = selectedMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedMode = mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: isSelected ? AppTheme.seaBlue : Colors.grey[200]!, width: 2),
            boxShadow: isSelected ? [BoxShadow(color: AppTheme.seaBlue.withOpacity(0.1), blurRadius: 10)] : [],
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppTheme.seaBlue : AppTheme.textGrey, size: 30),
              const SizedBox(height: 10),
              Text(mode, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? AppTheme.seaBlue : AppTheme.textDark)),
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

  String _getWeekDay(int day) {
    const days = ['LUN', 'MAR', 'MER', 'JEU', 'VEN', 'SAM', 'DIM'];
    return days[day - 1];
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
