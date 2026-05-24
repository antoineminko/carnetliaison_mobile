import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';

class GradesEntryView extends StatefulWidget {
  const GradesEntryView({super.key});

  @override
  State<GradesEntryView> createState() => _GradesEntryViewState();
}

class _GradesEntryViewState extends State<GradesEntryView> {
  String selectedType = 'Interrogation';
  String selectedSubject = 'Philosophie';
  final List<String> types = ['Interrogation', 'Devoir'];
  final List<String> subjects = ['Philosophie', 'Mathématiques', 'Littérature', 'Histoire-Géo', 'Anglais'];
  bool isExcelImported = false;

  // Mock student list with IDs for Excel matching simulation
  final List<Map<String, dynamic>> students = [
    {'id': 'STU-001', 'name': 'Yannick MPIGA', 'grade': ''},
    {'id': 'STU-002', 'name': 'Awa NDIAYE', 'grade': ''},
    {'id': 'STU-003', 'name': 'Jean-Marc ONDO', 'grade': ''},
    {'id': 'STU-004', 'name': 'Marie-Claire EYI', 'grade': ''},
    {'id': 'STU-005', 'name': 'Kévin MVE', 'grade': ''},
    {'id': 'STU-006', 'name': 'Béatrice MBOUMBA', 'grade': ''},
    {'id': 'STU-007', 'name': 'Christian OBAME', 'grade': ''},
    {'id': 'STU-008', 'name': 'Daphnée KOUMBA', 'grade': ''},
    {'id': 'STU-009', 'name': 'Émile BIGNAN', 'grade': ''},
    {'id': 'STU-010', 'name': 'Fatou DIOME', 'grade': ''},
    {'id': 'STU-011', 'name': 'Gabin MONDJO', 'grade': ''},
    {'id': 'STU-012', 'name': 'Hélène NGUEMA', 'grade': ''},
    {'id': 'STU-013', 'name': 'Ismaël KONÉ', 'grade': ''},
    {'id': 'STU-014', 'name': 'Juliette ESSONO', 'grade': ''},
    {'id': 'STU-015', 'name': 'Karl EBANG', 'grade': ''},
  ];

  void _simulateExcelImport() {
    setState(() {
      isExcelImported = true;
      // Simulate data filling from an Excel file using IDs
      for (var student in students) {
        student['grade'] = (10 + (students.indexOf(student) % 10)).toStringAsFixed(1);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Succès : Notes de $selectedSubject ($selectedType) importées pour 5 élèves via Excel.'),
        backgroundColor: AppTheme.seaBlue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              // Header section (Fixed elements)
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text('CONFIGURATION & IMPORT EXCEL', 
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey, letterSpacing: 1.1)),
                          ),
                          TextButton.icon(
                            onPressed: _simulateExcelImport,
                            icon: const Icon(Icons.upload_file, size: 18, color: AppTheme.forestGreen),
                            label: const Text('Importer Excel', style: TextStyle(color: AppTheme.forestGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                            style: TextButton.styleFrom(backgroundColor: AppTheme.forestGreen.withOpacity(0.1)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      // Subject Selection
                      DropdownButtonFormField<String>(
                        value: selectedSubject,
                        decoration: const InputDecoration(
                          labelText: 'Sélectionner la Matière',
                          prefixIcon: Icon(Icons.book_outlined, size: 20),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: subjects.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)))).toList(),
                        onChanged: (val) => setState(() => selectedSubject = val!),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedType,
                              decoration: const InputDecoration(
                                labelText: 'Type d\'évaluation',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: types.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13)))).toList(),
                              onChanged: (val) => setState(() => selectedType = val!),
                            ),
                          ),
                          const SizedBox(width: 15),
                          const Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Date',
                                suffixIcon: Icon(Icons.calendar_today, size: 18),
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Titre de l\'évaluation',
                          hintText: 'ex: $selectedType de $selectedSubject n°1',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Students list section
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: isExcelImported ? Border.all(color: AppTheme.forestGreen.withOpacity(0.3)) : null,
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppTheme.seaBlue.withOpacity(0.1),
                              child: Text(students[index]['name'][0], style: const TextStyle(color: AppTheme.seaBlue, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(students[index]['name'], style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                                  Text('ID: ${students[index]['id']}', style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              child: TextFormField(
                                key: ValueKey('${students[index]['id']}_${students[index]['grade']}'),
                                initialValue: students[index]['grade'],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  hintText: '/20',
                                  isDense: true,
                                  filled: isExcelImported,
                                  fillColor: AppTheme.forestGreen.withOpacity(0.05),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onChanged: (val) => students[index]['grade'] = val,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: students.length,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Fixed footer with submit button
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('En validant, les notes seront transmises à l\'administration pour le bulletin, et notifiées aux parents/élèves.', 
                textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Colors.grey)),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notes transmises avec succès !'),
                        backgroundColor: AppTheme.forestGreen,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.seaBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('VALIDER ET ENVOYER LES RÉSULTATS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
