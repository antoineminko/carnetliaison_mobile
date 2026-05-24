import 'package:flutter/material.dart';

class CalendarPage extends StatefulWidget {
  final String? childName;
  final String? childImage;
  final String? childGrade;
  final String? childId;
  final String? initialDate;
  final List<Map<String, dynamic>>? incidents;

  const CalendarPage({
    super.key, 
    this.childName, 
    this.childImage, 
    this.childGrade,
    this.childId,
    this.initialDate, 
    this.incidents
  });

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        // ... existing appbar code ...
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('NOTRE DAME DE QUABEN', style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
            Text('Suivi des Présences', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        // ... existing actions ...
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CHILD SELECTOR - Hide if specific child selected
            if (widget.childName == null)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildChildTab('Yannick', true),
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey[300]!)),
                      child: const Icon(Icons.add, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            
            if (widget.childName == null) const SizedBox(height: 25),
            
            // PROFILE CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Row(
                children: [
                   Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)],
                      image: DecorationImage(
                        image: AssetImage(widget.childImage ?? 'assets/images/profil/eleve1.jpg'), 
                        fit: BoxFit.cover
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.childName ?? 'Yannick Nguema', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 4),
                        Text(
                          'Classe ${widget.childGrade ?? 'Tle C'} • ID: ${widget.childId ?? '#8829'}',
                          style: TextStyle(color: Colors.blue[800], fontSize: 12, fontWeight: FontWeight.w500)
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildBadge('92% Assiduité', Colors.green[50]!, Colors.green),
                            const SizedBox(width: 8),
                            _buildBadge('3 Absences', Colors.orange[50]!, Colors.orange),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 25),

            // CALENDAR WIDGET (MOCK)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.chevron_left),
                      const Text('Mars 2026', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['DIM', 'LUN', 'MAR', 'MER', 'JEU', 'VEN', 'SAM']
                        .map((day) => Text(day, style: TextStyle(color: Colors.blue[300], fontWeight: FontWeight.bold, fontSize: 12)))
                        .toList(),
                  ),
                  const SizedBox(height: 15),
                  _buildCalendarGrid(),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegend(Colors.redAccent, 'Absence'),
                      const SizedBox(width: 15),
                      _buildLegend(Colors.orange, 'Retard'),
                      const SizedBox(width: 15),
                      _buildLegend(Colors.green, 'Justifié'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),
            
            if (widget.incidents != null && widget.incidents!.isNotEmpty) ...[
              const Text('Incidents Récents', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              ...widget.incidents!.map((incident) => _buildIncidentCard(
                incident['icon'] as IconData,
                incident['color'] as Color,
                incident['title'] as String,
                incident['subtitle'] as String,
                incident['btnText'] as String,
              )).toList(),
            ] else ...[
               const SizedBox(height: 20),
               Container(
                 padding: const EdgeInsets.all(30),
                 width: double.infinity,
                 decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                 child: Column(
                   children: [
                     Icon(Icons.check_circle_outline, size: 50, color: Colors.green[200]),
                     const SizedBox(height: 10),
                     const Text('Aucun incident récent', style: TextStyle(color: Colors.grey, fontSize: 16)),
                   ],
                 ),
               ),
            ],
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildChildTab(String name, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? Colors.blue : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: isActive ? [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
      ),
      child: Text(name, style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    // Simulation simple de la grille
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: _buildWeekRow(['1', '2', '3', '4', '5', '6', '7'], selectedDay: '5', dots: {'3': Colors.orange})),
        const SizedBox(height: 15),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: _buildWeekRow(['8', '9', '10', '11', '12', '13', '14'], dots: {'12': Colors.redAccent})),
        const SizedBox(height: 15),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: _buildWeekRow(['15', '16', '17', '18', '19', '20', '21'])),
        const SizedBox(height: 15),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: _buildWeekRow(['22', '23', '24', '25', '26', '27', '28'], dots: {'24': Colors.redAccent})),
      ],
    );
  }

  List<Widget> _buildWeekRow(List<String> days, {String? selectedDay, Map<String, Color>? dots}) {
    return days.map((day) {
      bool isSelected = day == selectedDay;
      Color? dotColor = dots?[day];
      
      return Column(
        children: [
          Container(
            width: 35, height: 35,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              day,
              style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.black87),
            ),
          ),
          if (dotColor != null)
            Container(margin: const EdgeInsets.only(top: 4), width: 5, height: 5, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle))
          else 
            const SizedBox(height: 9),
        ],
      );
    }).toList();
  }

  Widget _buildIncidentCard(IconData icon, Color color, String title, String subtitle, String btnText) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: Colors.blue[600], fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          if (btnText == 'Justifier' || btnText == 'Ignorer')
             ElevatedButton(
                onPressed: () {
                  if (btnText == 'Justifier') {
                    _showJustificationModal(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: btnText == 'Justifier' ? Colors.blue : Colors.grey[200],
                  foregroundColor: btnText == 'Justifier' ? Colors.white : Colors.black,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  minimumSize: const Size(60, 36),
                ),
                child: Text(btnText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              )
          else 
             Container(
               width: 36, height: 36,
               decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
               child: const Icon(Icons.add, color: Colors.white),
             )
        ],
      ),
    );
  }

  void _showJustificationModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('Justifier une absence', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Veuillez sélectionner le motif de l\'absence ou du retard.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            
            Expanded(
              child: ListView(
                children: [
                  _buildJustificationOption(context, 'Maladie', Icons.medical_services_outlined, Colors.redAccent),
                  _buildJustificationOption(context, 'Rendez-vous médical', Icons.calendar_month_outlined, Colors.blue),
                  _buildJustificationOption(context, 'Problème de transport', Icons.directions_bus_outlined, Colors.orange),
                  _buildJustificationOption(context, 'Urgence familiale', Icons.family_restroom, Colors.purple),
                  _buildJustificationOption(context, 'Autre', Icons.more_horiz, Colors.grey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJustificationOption(BuildContext context, String title, IconData icon, Color color) {
    return ListTile(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Justification sent: $title'), backgroundColor: Colors.green),
        );
      },
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }
}
