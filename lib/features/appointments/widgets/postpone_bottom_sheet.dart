import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';

class PostponeBottomSheet extends StatefulWidget {
  final int appointmentId;
  final Function(int, DateTime, String) onPostpone;

  const PostponeBottomSheet({
    super.key,
    required this.appointmentId,
    required this.onPostpone,
  });

  @override
  State<PostponeBottomSheet> createState() => _PostponeBottomSheetState();
}

class _PostponeBottomSheetState extends State<PostponeBottomSheet> {
  late DateTime _selectedDate;
  String? _selectedTime;
  final _reasonController = TextEditingController();

  final List<String> _allTimeSlots = [
    '08:00', '09:00', '10:00', '11:00', 
    '14:00', '15:00', '16:00', '17:00', '18:00'
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().add(const Duration(days: 1));
    _updateAvailableTimeSlots();
  }
  
  List<String> get _availableTimeSlots {
    final now = DateTime.now();
    // Si la date choisie est aujourd'hui, on filtre les heures passées
    if (_selectedDate.year == now.year && 
        _selectedDate.month == now.month && 
        _selectedDate.day == now.day) {
      return _allTimeSlots.where((time) {
        final parts = time.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        
        final slotTime = DateTime(now.year, now.month, now.day, hour, minute);
        return slotTime.isAfter(now);
      }).toList();
    }
    return _allTimeSlots;
  }

  void _updateAvailableTimeSlots() {
    final available = _availableTimeSlots;
    if (available.isNotEmpty) {
      if (_selectedTime == null || !available.contains(_selectedTime)) {
        _selectedTime = available.first;
      }
    } else {
      _selectedTime = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableSlots = _availableTimeSlots;
    
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.schedule, color: Colors.orange),
                ),
                const SizedBox(width: 15),
                const Expanded(
                  child: Text(
                    'Proposer une nouvelle date',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Sélection de la date
            const Text(
              'Nouvelle date proposée',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 90)),
                onDateChanged: (date) {
                  setState(() {
                    _selectedDate = date;
                    _updateAvailableTimeSlots();
                  });
                },
              ),
            ),
            const SizedBox(height: 20),

            // Sélection du créneau horaire
            const Text(
              'Créneau horaire',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 10),
            if (availableSlots.isEmpty)
              const Text(
                'Aucun créneau disponible pour cette date.',
                style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availableSlots.map((time) {
                  final isSelected = _selectedTime == time;
                  return ChoiceChip(
                    label: Text(time),
                    selected: isSelected,
                    selectedColor: AppTheme.seaBlue,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedTime = time);
                      }
                    },
                  );
                }).toList(),
              ),
            const SizedBox(height: 20),

            // Raison du report
            const Text(
              'Raison du report (optionnel)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _reasonController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Ex: Indisponibilité, congés...',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Bouton de confirmation
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _selectedTime == null ? null : () {
                  final parts = _selectedTime!.split(':');
                  final newDate = DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                    int.parse(parts[0]),
                    int.parse(parts[1]),
                  );
                  Navigator.pop(context);
                  widget.onPostpone(
                    widget.appointmentId,
                    newDate,
                    _reasonController.text,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Proposer cette date',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
