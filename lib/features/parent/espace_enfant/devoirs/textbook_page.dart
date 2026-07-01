import 'package:flutter/material.dart';

class TextbookPage extends StatefulWidget {
  final String? initialChildName;
  final String? schoolIcon;

  const TextbookPage({super.key, this.initialChildName, this.schoolIcon});

  @override
  State<TextbookPage> createState() => _TextbookPageState();
}

class _TextbookPageState extends State<TextbookPage> {
  late String _selectedChild;
  final List<String> _children = ['Yannick Nguema', 'Emmanuella Nguema', 'Junior Nguema'];

  @override
  void initState() {
    super.initState();
    _selectedChild = widget.initialChildName ?? 'Yannick Nguema';
  }

  final Map<String, List<Map<String, dynamic>>> _coursesData = {
    'Yannick Nguema': [
      {
        'subject': 'Mathématiques',
        'time': '08:00 - 09:30',
        'icon': Icons.calculate,
        'color': Colors.blue,
        'summary': 'Introduction aux équations du second degré. Discussion sur la méthode du discriminant et résolution de polynômes de base.',
        'homework': {'task': 'Livre page 142 : Ex 4, 5, 8', 'due': 'À rendre : 4 oct, 08:00', 'isDone': true},
      },
      {
        'subject': 'Français',
        'time': '10:00 - 11:30',
        'icon': Icons.menu_book,
        'color': Colors.purple,
        'summary': 'Analyse de \'Les Misérables\', Chapitre 3. Développement du personnage de Jean Valjean.',
        'homework': {'task': 'Rédiger une réflexion sur la rédemption de Valjean.', 'due': 'À rendre : 6 oct, 10:00', 'isDone': false},
      },
      {
        'subject': 'Histoire-Géographie',
        'time': '14:00 - 15:30',
        'icon': Icons.public,
        'color': Colors.orange,
        'summary': 'Seconde Guerre mondiale : le début du conflit et les grandes alliances de 1939.',
        'homework': null,
      },
    ],
    'Emmanuella Nguema': [
      {
        'subject': 'SVT',
        'time': '08:00 - 10:00',
        'icon': Icons.biotech,
        'color': Colors.green,
        'summary': 'Étude de la cellule et de ses composants. Observation au microscope.',
        'homework': {'task': 'Dessiner un schéma de cellule végétale.', 'due': 'Demain', 'isDone': false},
      },
      {
        'subject': 'Anglais',
        'time': '10:30 - 12:00',
        'icon': Icons.language,
        'color': Colors.redAccent,
        'summary': 'Vocabulaire de la famille et introduction au Present Continuous.',
        'homework': null,
      },
    ],
    'Junior Nguema': [
      {
        'subject': 'Français',
        'time': '08:00 - 10:00',
        'icon': Icons.edit,
        'color': Colors.redAccent,
        'summary': 'Grammaire : Le sujet et le verbe. Exercices d\'application.',
        'homework': {'task': 'Exercice 3 page 12 (Raté le début du cours)', 'due': 'Demain', 'isDone': false},
      },
      {
        'subject': 'Histoire',
        'time': '11:00 - 12:30',
        'icon': Icons.history_edu,
        'color': Colors.brown,
        'summary': 'Histoire du pays : Les grands royaumes précoloniaux.',
        'homework': {'task': 'Lire le chapitre 2.', 'due': 'Lundi', 'isDone': true},
      },
      {
        'subject': 'Éducation civique',
        'time': '15:00 - 17:00',
        'icon': Icons.diversity_3,
        'color': Colors.teal,
        'summary': 'Respect, Droits et Devoirs. Valeurs citoyennes.',
        'homework': {'task': 'Apprendre la leçon.', 'due': 'Prochain cours', 'isDone': false},
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('NOTRE DAME DE QUABEN', style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
            Text('Cahier de Texte', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header Child logic
            if (widget.initialChildName != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.schoolIcon != null)
                       Padding(
                         padding: const EdgeInsets.only(right: 10),
                         child: CircleAvatar(
                           backgroundImage: AssetImage(widget.schoolIcon!),
                           radius: 12,
                           backgroundColor: Colors.transparent,
                         ),
                       ),
                    Text(
                      'Cahier de : $_selectedChild',
                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedChild,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedChild = newValue!;
                      });
                    },
                    items: _children.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text('Cahier de : $value'),
                      );
                    }).toList(),
                  ),
                ),
              ),
            
            const SizedBox(height: 25),
            
            // Week Calendar Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven'].asMap().entries.map((entry) {
                  int idx = entry.key;
                  String day = entry.value;
                  bool isSelected = idx == 0; // Simulate Monday selected
                  return Container(
                    margin: const EdgeInsets.only(right: 15),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isSelected ? [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                    ),
                    child: Column(
                      children: [
                        Text(day, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontSize: 12)),
                        const SizedBox(height: 5),
                        Text('${2 + idx} Oct', style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 25),
            
            Row(
              children: [
                const Text('Cours du jour', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(20)),
                  child: Text('Classe ${_selectedChild.contains('Yannick') ? 'Tle C' : (_selectedChild.contains('Emmanuella') ? '3ème' : '5e année')}', 
                    style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Course List
            if (_coursesData[_selectedChild] != null)
              ..._coursesData[_selectedChild]!.map((course) => _buildCourseCard(course)).toList()
            else
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(child: Text("Aucun cours pour cet élève.")),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and Timeline
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (course['color'] as Color).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(course['icon'] as IconData, color: course['color'] as Color, size: 24),
              ),
              Container(
                width: 2,
                height: 180, // Approximate height
                color: Colors.grey[200],
              ),
            ],
          ),
          const SizedBox(width: 15),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(course['subject'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(course['time'] as String, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 15),
                // Resume Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('RÉSUMÉ DU COURS', style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 8),
                      Text(course['summary'] as String, style: TextStyle(color: Colors.black87, height: 1.5, fontSize: 14)),
                    ],
                  ),
                ),
                if (course['homework'] != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50]!.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue[100]!),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          (course['homework']['isDone'] as bool) ? Icons.check_circle : Icons.radio_button_unchecked, 
                          color: (course['homework']['isDone'] as bool) ? Colors.green : Colors.blue[300]
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('DEVOIRS', style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.bold, fontSize: 12)),
                              const SizedBox(height: 5),
                              Text(course['homework']['task'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(course['homework']['due'] as String, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
