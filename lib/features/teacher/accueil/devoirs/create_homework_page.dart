import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/features/teacher/services/teacher_dashboard_service.dart';
import 'package:app_mobile/features/teacher/services/teacher_student_service.dart';
import 'package:app_mobile/features/teacher/services/teacher_homework_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/homework_type_selector.dart';
import 'widgets/homework_subject_card.dart';
import 'widgets/homework_class_selector.dart';
import 'widgets/homework_student_selector.dart';
import 'widgets/homework_details_form.dart';
import 'widgets/homework_date_picker.dart';

class CreateHomeworkPage extends StatefulWidget {
  const CreateHomeworkPage({super.key});

  @override
  State<CreateHomeworkPage> createState() => _CreateHomeworkPageState();
}

class _CreateHomeworkPageState extends State<CreateHomeworkPage> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  int? _teacherId;
  String _subject = 'Mathématiques';
  
  
  List<Map<String, dynamic>> _classes = [];
  Map<String, dynamic>? _selectedClass;
  

  List<Map<String, dynamic>> _students = [];
  List<int> _selectedStudents = []; 
  bool _selectAllStudents = true;
  
  String _selectedType = 'maison'; 
  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  
  DateTime _dueDate = DateTime.now().add(const Duration(days: 2));

  @override
  void initState() {
    super.initState();
    _loadTeacherData();
  }

  Future<void> _loadTeacherData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _teacherId = prefs.getInt('teacher_id');
      _subject = prefs.getString('teacher_matiere') ?? 'Mathématiques';
    });
    await _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    if (_teacherId == null) {
      setState(() => _isLoading = false);
      return;
    }
    
    try {
      final response = await TeacherDashboardService.instance.getDashboard(_teacherId!);
      setState(() {
        _classes = List<Map<String, dynamic>>.from(response.data['classes'] ?? []);
        if (_classes.isNotEmpty) {
          _selectedClass = _classes.first;
          _fetchStudents(_selectedClass!['id']);
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur chargement classes: $e')),
      );
    }
  }

  Future<void> _fetchStudents(int classId) async {
    setState(() => _isLoading = true);
    try {
      final response = await TeacherStudentService.instance.getStudentsByClassId(classId);
      setState(() {
        _students = List<Map<String, dynamic>>.from(response.data as List);
        _selectedStudents = _students.map((s) => s['id'] as int).toList();
        _selectAllStudents = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur chargement élèves: $e')),
      );
    }
  }

  void _toggleStudentSelection(int studentId) {
    setState(() {
      if (_selectedStudents.contains(studentId)) {
        _selectedStudents.remove(studentId);
      } else {
        _selectedStudents.add(studentId);
      }
      _selectAllStudents = _selectedStudents.length == _students.length;
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (_selectAllStudents) {
        _selectedStudents = [];
      } else {
        _selectedStudents = _students.map((s) => s['id'] as int).toList();
      }
      _selectAllStudents = !_selectAllStudents;
    });
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'maison':
        return 'Devoir de maison';
      case 'classe':
        return 'Devoir de classe';
      case 'exercice':
        return 'Exercice maison';
      default:
        return 'Devoir';
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'maison':
        return Icons.home_work;
      case 'classe':
        return Icons.school;
      case 'exercice':
        return Icons.edit_note;
      default:
        return Icons.assignment;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'maison':
        return Colors.blue;
      case 'classe':
        return Colors.green;
      case 'exercice':
        return Colors.orange;
      default:
        return AppTheme.seaBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: const Text('Créer un devoir', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.textDark,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.seaBlue),
        ),
      );
    }

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
            // Type de devoir
            _buildSectionTitle('Type de devoir'),
            const SizedBox(height: 10),
            HomeworkTypeSelector(
              selectedType: _selectedType,
              onTypeChanged: (type) => setState(() => _selectedType = type),
            ),
            
            const SizedBox(height: 25),
            
            // Matière
            _buildSectionTitle('Matière'),
            const SizedBox(height: 10),
            HomeworkSubjectCard(subject: _subject),

            const SizedBox(height: 25),
            
            // Classe cible
            _buildSectionTitle('Classe cible'),
            const SizedBox(height: 10),
            HomeworkClassSelector(
              classes: _classes,
              selectedClass: _selectedClass,
              onChanged: (val) {
                setState(() {
                  _selectedClass = val;
                  if (val != null) {
                    _fetchStudents(val['id']);
                  }
                });
              },
            ),

            const SizedBox(height: 25),
            
            // Sélection des élèves
            _buildSectionTitle('Élèves concernés'),
            const SizedBox(height: 10),
            HomeworkStudentSelector(
              students: _students,
              selectedStudents: _selectedStudents,
              selectAllStudents: _selectAllStudents,
              onToggleSelectAll: _toggleSelectAll,
              onToggleStudent: _toggleStudentSelection,
            ),

            const SizedBox(height: 25),
            
            // Détails du devoir
            _buildSectionTitle('Détails du devoir'),
            const SizedBox(height: 10),
            HomeworkDetailsForm(
              titleController: _titleController,
              descController: _descController,
              durationController: _durationController,
              selectedType: _selectedType,
            ),

            const SizedBox(height: 25),
            
            // Date de remise
            _buildSectionTitle('Date de remise'),
            const SizedBox(height: 10),
            HomeworkDatePicker(
              dueDate: _dueDate,
              onDateChanged: (date) => setState(() => _dueDate = date),
            ),

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

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: _isSubmitting ? null : _publishDevoir,
        icon: _isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Icon(Icons.upload_file_rounded, color: Colors.white),
        label: Text(
          _isSubmitting ? 'Publication...' : 'Publier le devoir',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.forestGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
      ),
    );
  }

  Future<void> _publishDevoir() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();
    
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un titre')),
      );
      return;
    }
    
    if (_selectedClass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une classe')),
      );
      return;
    }
    
    if (_selectedStudents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner au moins un élève')),
      );
      return;
    }

    final due = '${_dueDate.year}-${_dueDate.month.toString().padLeft(2, '0')}-${_dueDate.day.toString().padLeft(2, '0')}';
    final dueDisplay = '${_dueDate.day.toString().padLeft(2, '0')}/${_dueDate.month.toString().padLeft(2, '0')}/${_dueDate.year}';

    setState(() => _isSubmitting = true);

    try {
      final response = await TeacherHomeworkService.instance.createHomework({
        'classe_id': _selectedClass!['id'],
        'enseignant_id': _teacherId,
        'matiere': _subject,
        'type': _selectedType,
        'titre': title,
        'description': desc,
        'date_remise': due,
        'eleves': _selectedStudents,
      });

      setState(() => _isSubmitting = false);

      if (response.statusCode == 201) {
        final data = response.data;
        final notificationsCount = data['notifications_envoyees'] ?? 0;
        
        if (!mounted) return;
        _showSuccessDialog(title, dueDisplay, notificationsCount);
      } else {
        throw Exception('Erreur serveur');
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la publication : $e')),
      );
    }
  }

  void _showSuccessDialog(String title, String dueDisplay, int notificationsCount) {
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
            const SizedBox(height: 8),
            Text(
              '$notificationsCount parent${notificationsCount > 1 ? 's' : ''} notifié${notificationsCount > 1 ? 's' : ''}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
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
                  _buildRecapRow(Icons.class_outlined, 'Classe', _selectedClass?['nom'] ?? '', AppTheme.forestGreen),
                  const Divider(height: 16),
                  _buildRecapRow(_getTypeIcon(_selectedType), 'Type', _getTypeLabel(_selectedType), _getTypeColor(_selectedType)),
                  const Divider(height: 16),
                  _buildRecapRow(Icons.people, 'Élèves', '${_selectedStudents.length} élève${_selectedStudents.length > 1 ? 's' : ''}', Colors.purple),
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
                  Navigator.pop(ctx);
                  Navigator.pop(context);
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
}

