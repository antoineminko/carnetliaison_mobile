import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:app_mobile/features/teacher/services/teacher_student_service.dart';
import 'package:app_mobile/features/teacher/services/teacher_grades_service.dart';

class GradesEntryView extends StatefulWidget {
  final int classId;
  const GradesEntryView({super.key, required this.classId});

  @override
  State<GradesEntryView> createState() => _GradesEntryViewState();
}

class _GradesEntryViewState extends State<GradesEntryView> {
  String selectedTrimester = '1er Trimestre';
  String selectedAssignmentNum = '1';
  String selectedType = 'Devoir maison 1';
  String selectedSubject = 'Philosophie';
  DateTime? evaluationDate = DateTime.now();
  final TextEditingController titleController = TextEditingController();

  final List<String> trimesters = ['1er Trimestre', '2ème Trimestre', '3ème Trimestre'];
  final List<String> assignmentNums = ['1', '2', '3', '4', '5'];
  final List<String> types = ['Devoir maison 1', 'Devoir maison 2', 'Interrogation classe', 'Contrôle', 'Examen', 'Autre'];
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
  bool isLoadingStudents = true;

  List<Map<String, dynamic>> students = [];

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    try {
      final response = await TeacherStudentService.instance.getStudentsByClassId(widget.classId);
      final data = response.data as List;
      
      setState(() {
        students = data.map((e) => {
          'id': e['code_secret'] ?? e['matricule'] ?? e['id'].toString(), 
          'name': '${e['nom']} ${e['prenom']}',
          'grade': '',
          'raw_id': e['id'],
        }).toList();
        isLoadingStudents = false;
      });
    } catch (e) {
      setState(() => isLoadingStudents = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des élèves : $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  Future<void> _importExcelData() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null) {
        setState(() => isUploading = true);
        
        File file = File(result.files.single.path!);
        var bytes = file.readAsBytesSync();
        var excel = Excel.decodeBytes(bytes);

        int matchedCount = 0;
        List<String> unmappedNames = [];

        for (var table in excel.tables.keys) {
          var sheet = excel.tables[table];
          if (sheet == null) continue;

       
          for (int i = 1; i < sheet.maxRows; i++) {
            var row = sheet.row(i);
            if (row.length >= 2) {
              var excelName = row[0]?.value?.toString().trim();
              var grade = row[1]?.value?.toString().trim();
              var appreciation = row.length > 2 ? row[2]?.value?.toString().trim() : null;

              if (excelName != null && excelName.isNotEmpty && grade != null) {
                bool matched = false;
                String normalizedExcelName = excelName.toLowerCase().replaceAll(RegExp(r'\s+'), '');
                
                // Find student by name
                for (var student in students) {
                  String normalizedStudentName = student['name'].toString().toLowerCase().replaceAll(RegExp(r'\s+'), '');
                  
                  // Flexible matching: check if names are equal, or if all parts of excel name exist in student name
                  if (normalizedStudentName == normalizedExcelName || 
                      _nameMatches(excelName, student['name'])) {
                    setState(() {
                      student['grade'] = grade;
                      if (appreciation != null && appreciation.isNotEmpty) {
                        student['commentaires'] = appreciation;
                      }
                    });
                    matchedCount++;
                    matched = true;
                    break;
                  }
                }
                if (!matched) {
                  unmappedNames.add(excelName);
                }
              }
            }
          }
        }

        setState(() {
          isUploading = false;
          isExcelImported = true;
        });

        if (unmappedNames.isNotEmpty && mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Attention - Élèves non trouvés', style: TextStyle(color: Colors.orange)),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Text('Les élèves suivants du fichier Excel n\'ont pas été reconnus et leurs notes n\'ont pas été importées. Veuillez vérifier leur nom complet :\n'),
                    ...unmappedNames.map((name) => Text('- $name', style: const TextStyle(fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fermer'),
                ),
              ],
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Succès : Notes importées pour $matchedCount élèves.'),
              backgroundColor: AppTheme.forestGreen,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la lecture du fichier Excel : $e')),
        );
      }
    }
  }

  void _showExcelFormatInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.info_outline, color: AppTheme.seaBlue),
            SizedBox(width: 10),
            Expanded(child: Text('Format du fichier Excel')),
          ],
        ),
        content: const Text(
          'Le fichier Excel (.xlsx) doit comporter deux ou trois colonnes :\n\n'
          'Colonne A : Nom complet de l\'élève\n'
          'Colonne B : Note sur 20 (ex: 15.5)\n'
          'Colonne C : Appréciation (optionnelle)\n\n'
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

  Future<void> _publishGrades() async {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un titre pour l\'évaluation.')),
      );
      return;
    }

    // Collect grades
    List<Map<String, dynamic>> notesData = [];
    for (var student in students) {
      if (student['grade'] != null && student['grade'].toString().isNotEmpty) {
        notesData.add({
          'eleve_id': student['raw_id'],
          'note': student['grade'],
          'commentaires': student['commentaires'],
        });
      }
    }

    if (notesData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir au moins une note.')),
      );
      return;
    }

    _showPreviewModal(notesData);
  }

  void _showPreviewModal(List<Map<String, dynamic>> notesData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Aperçu avant validation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              Expanded(
                child: ListView.builder(
                  itemCount: notesData.length,
                  itemBuilder: (context, index) {
                    var note = notesData[index];
                    var student = students.firstWhere((s) => s['raw_id'] == note['eleve_id']);
                    bool isOk = double.tryParse(note['note'].toString()) != null;
                    return ListTile(
                      title: Text(student['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Note : ${note['note']}'),
                      trailing: isOk 
                        ? const Icon(Icons.check_circle, color: AppTheme.forestGreen) 
                        : const Icon(Icons.error, color: Colors.red),
                    );
                  },
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _executePublish(notesData);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.seaBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('VALIDER LES NOTES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _executePublish(List<Map<String, dynamic>> notesData) async {
    try {
      final payload = {
        'classe_id': widget.classId,
        'trimestre': selectedTrimester,
        'numero': selectedAssignmentNum,
        'type': selectedType,
        'matiere': selectedSubject,
        'titre': titleController.text.trim(),
        'date': evaluationDate != null ? DateFormat('yyyy-MM-dd').format(evaluationDate!) : null,
        'notes': notesData,
      };

      await TeacherGradesService.instance.saveGrades(payload);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notes transmises et notifications envoyées !'),
            backgroundColor: AppTheme.forestGreen,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de sauvegarde : $e')),
        );
      }
    }
  }

  bool _nameMatches(String excelName, String studentName) {
    var excelParts = excelName.toLowerCase().trim().split(RegExp(r'\s+'));
    var studentNameLower = studentName.toLowerCase();
    for (var part in excelParts) {
      if (!studentNameLower.contains(part)) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingStudents) {
      return const Center(child: CircularProgressIndicator());
    }

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
                                  onPressed: _importExcelData,
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
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Trimestre',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: trimesters.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis))).toList(),
                              onChanged: (val) => setState(() => selectedTrimester = val!),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedAssignmentNum,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'N° Évaluation',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: assignmentNums.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis))).toList(),
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
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Matière',
                                prefixIcon: Icon(Icons.book_outlined, size: 18),
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: subjects.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis))).toList(),
                              onChanged: (val) => setState(() => selectedSubject = val!),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            flex: 3,
                            child: DropdownButtonFormField<String>(
                              value: selectedType,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Type',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: types.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis))).toList(),
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
                              decoration: const InputDecoration(
                                labelText: 'Titre du devoir',
                                hintText: 'ex: Contrôle sur les vecteurs',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  onPressed: _publishGrades,
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
