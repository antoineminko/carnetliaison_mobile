import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:intl/intl.dart';

class GradesEntryView extends StatefulWidget {
  const GradesEntryView({super.key});

  @override
  State<GradesEntryView> createState() => _GradesEntryViewState();
}

class _GradesEntryViewState extends State<GradesEntryView> {
  String selectedTrimester = '1er Trimestre';
  String selectedAssignmentNum = '1er Devoir';
  String selectedType = 'Devoir Maison';
  String selectedSubject = 'Philosophie';
  DateTime? evaluationDate = DateTime.now();
  final TextEditingController titleController = TextEditingController();

  final List<String> trimesters = ['1er Trimestre', '2ème Trimestre', '3ème Trimestre'];
  final List<String> assignmentNums = ['1er Devoir', '2ème Devoir', '3ème Devoir', '4ème Devoir', '5ème Devoir'];
  final List<String> types = ['Devoir Maison', 'Interrogation en Classe', 'Contrôle Continu', 'Examen Blanc'];
  final List<String> subjects = [
    'Philosophie',
    'Mathématiques',
    'Littérature',
    'Histoire-Géo',
    'Anglais',
    'Sciences Physiques',
    'SVT',
    'EPS'
  ];
  
  bool isExcelImported = false;
  bool isUploading = false;

  // Mock student list
  final List<Map<String, dynamic>> students = [
    {'id': 'STU-001', 'name': 'Yannick MPIGA', 'grade': ''},
    {'id': 'STU-002', 'name': 'Awa NDIAYE', 'grade': ''},
    {'id': 'STU-003', 'name': 'Jean-Marc ONDO', 'grade': ''},
    {'id': 'STU-004', 'name': 'Marie-Claire EYI', 'grade': ''},
    {'id': 'STU-005', 'name': 'Kévin MVE', 'grade': ''},
  ];

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  Future<void> _simulateExcelImport() async {
    setState(() => isUploading = true);
    
    // Simulate loading
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isUploading = false;
      isExcelImported = true;
      for (var student in students) {
        student['grade'] = (10 + (students.indexOf(student) % 10)).toStringAsFixed(1);
      }
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Succès : Notes importées pour ${students.length} élèves via Excel.'),
        backgroundColor: AppTheme.forestGreen,
      ),
    );
  }

  void _showExcelFormatInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.info_outline, color: AppTheme.seaBlue),
            SizedBox(width: 10),
            Text('Format du fichier Excel'),
          ],
        ),
        content: const Text(
          'Le fichier Excel doit comporter deux colonnes :\n\n'
          'Colonne A : Matricule de l\'élève (ex: STU-001)\n'
          'Colonne B : Note sur 20 (ex: 15.5)\n\n'
          'Veuillez inclure l\'en-tête sur la première ligne.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: evaluationDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.seaBlue,
              onPrimary: Colors.white,
              onSurface: AppTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != evaluationDate) {
      setState(() {
        evaluationDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
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
                            child: Text('PARAMÉTRAGE DE L\'ÉVALUATION', 
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey, letterSpacing: 1.1)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.info_outline, color: AppTheme.seaBlue),
                            onPressed: _showExcelFormatInfo,
                            tooltip: 'Format Excel',
                          ),
                          isUploading
                              ? const SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.forestGreen),
                                )
                              : TextButton.icon(
                                  onPressed: _simulateExcelImport,
                                  icon: const Icon(Icons.upload_file, size: 18, color: AppTheme.forestGreen),
                                  label: const Text('Importer', style: TextStyle(color: AppTheme.forestGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                                  style: TextButton.styleFrom(backgroundColor: AppTheme.forestGreen.withOpacity(0.1)),
                                ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Trimestre & Numéro
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedTrimester,
                              decoration: const InputDecoration(
                                labelText: 'Trimestre',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: trimesters.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)))).toList(),
                              onChanged: (val) => setState(() => selectedTrimester = val!),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedAssignmentNum,
                              decoration: const InputDecoration(
                                labelText: 'N° Évaluation',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: assignmentNums.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13)))).toList(),
                              onChanged: (val) => setState(() => selectedAssignmentNum = val!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Matière & Type
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: DropdownButtonFormField<String>(
                              value: selectedSubject,
                              decoration: const InputDecoration(
                                labelText: 'Matière',
                                prefixIcon: Icon(Icons.book_outlined, size: 18),
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: subjects.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12)))).toList(),
                              onChanged: (val) => setState(() => selectedSubject = val!),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            flex: 3,
                            child: DropdownButtonFormField<String>(
                              value: selectedType,
                              decoration: const InputDecoration(
                                labelText: 'Type',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: types.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12)))).toList(),
                              onChanged: (val) => setState(() => selectedType = val!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Titre & Date
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: titleController,
                              decoration: InputDecoration(
                                labelText: 'Titre du devoir',
                                hintText: 'ex: Contrôle sur les vecteurs',
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () => _selectDate(context),
                              child: AbsorbPointer(
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Date',
                                    hintText: evaluationDate != null ? DateFormat('dd/MM/yyyy').format(evaluationDate!) : '',
                                    suffixIcon: const Icon(Icons.calendar_today, size: 18),
                                    border: const OutlineInputBorder(),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  controller: TextEditingController(text: evaluationDate != null ? DateFormat('dd/MM/yyyy').format(evaluationDate!) : ''),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Liste des élèves
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

        // Footer Validation
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('En validant, un devoir spécifique sera publié dans l\'espace de chaque enfant, et une notification push sera envoyée.', 
                textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Colors.grey)),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notes transmises et notifications envoyées !'),
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
                  child: const Text('PUBLIER LES RÉSULTATS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
