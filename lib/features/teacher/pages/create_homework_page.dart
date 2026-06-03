import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/shared/config/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  
  // Classes dynamiques depuis l'API
  List<Map<String, dynamic>> _classes = [];
  Map<String, dynamic>? _selectedClass;
  
  // Élèves de la classe sélectionnée
  List<Map<String, dynamic>> _students = [];
  List<int> _selectedStudents = []; // IDs des élèves sélectionnés
  bool _selectAllStudents = true;
  
  // Type de devoir
  String _selectedType = 'maison'; // maison, classe, exercice
  
  // Contrôleurs
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
      final response = await ApiClient.instance.get('/enseignants/$_teacherId/classes');
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
      final response = await ApiClient.instance.get('/classes/$classId/eleves');
      setState(() {
        _students = List<Map<String, dynamic>>.from(response.data['eleves'] ?? []);
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
            _buildTypeSelector(),
            
            const SizedBox(height: 25),
            
            // Matière
            _buildSectionTitle('Matière'),
            const SizedBox(height: 10),
            _buildSubjectCard(),

            const SizedBox(height: 25),
            
            // Classe cible
            _buildSectionTitle('Classe cible'),
            const SizedBox(height: 10),
            _buildClassSelector(),

            const SizedBox(height: 25),
            
            // Sélection des élèves
            _buildSectionTitle('Élèves concernés'),
            const SizedBox(height: 10),
            _buildStudentSelector(),

            const SizedBox(height: 25),
            
            // Détails du devoir
            _buildSectionTitle('Détails du devoir'),
            const SizedBox(height: 10),
            _buildDetailsCard(),

            const SizedBox(height: 25),
            
            // Date de remise
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

  Widget _buildTypeSelector() {
    final types = [
      {'id': 'maison', 'label': 'Devoir de maison', 'icon': Icons.home_work, 'color': Colors.blue, 'desc': 'À faire chez soi'},
      {'id': 'classe', 'label': 'Devoir de classe', 'icon': Icons.school, 'color': Colors.green, 'desc': 'À faire en classe'},
      {'id': 'exercice', 'label': 'Exercice maison', 'icon': Icons.edit_note, 'color': Colors.orange, 'desc': 'Exercices pratiques'},
    ];

    return Column(
      children: types.map((type) {
        final isSelected = _selectedType == type['id'];
        return GestureDetector(
          onTap: () => setState(() => _selectedType = type['id'] as String),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? (type['color'] as Color).withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? (type['color'] as Color) : Colors.grey[200]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (type['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(type['icon'] as IconData, color: type['color'] as Color, size: 24),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type['label'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? (type['color'] as Color) : AppTheme.textDark,
                        ),
                      ),
                      Text(
                        type['desc'] as String,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: type['color'] as Color, size: 28),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubjectCard() {
    return Container(
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
    );
  }

  Widget _buildClassSelector() {
    if (_classes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text('Aucune classe assignée', style: TextStyle(color: Colors.grey)),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sélectionner une classe', style: TextStyle(fontSize: 12, color: AppTheme.textGrey)),
          const SizedBox(height: 10),
          DropdownButtonFormField<Map<String, dynamic>>(
            value: _selectedClass,
            isExpanded: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.seaBlue),
              ),
            ),
            items: _classes.map((classe) {
              return DropdownMenuItem(
                value: classe,
                child: Text('${classe['nom']} ${classe['ecole_nom'] != null ? '(${classe['ecole_nom']})' : ''}'),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _selectedClass = val;
                if (val != null) {
                  _fetchStudents(val['id']);
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStudentSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_selectedStudents.length} élève${_selectedStudents.length > 1 ? 's' : ''} sélectionné${_selectedStudents.length > 1 ? 's' : ''}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: _toggleSelectAll,
                icon: Icon(_selectAllStudents ? Icons.deselect : Icons.select_all, size: 18),
                label: Text(_selectAllStudents ? 'Tout désélectionner' : 'Tout sélectionner'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.seaBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),
          if (_students.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('Aucun élève dans cette classe', style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _students.map((student) {
                final isSelected = _selectedStudents.contains(student['id']);
                return FilterChip(
                  avatar: CircleAvatar(
                    radius: 14,
                    backgroundImage: student['photo_url'] != null
                        ? NetworkImage(student['photo_url'])
                        : null,
                    child: student['photo_url'] == null
                        ? Text('${student['prenom']?[0] ?? ''}${student['nom']?[0] ?? ''}')
                        : null,
                  ),
                  label: Text('${student['prenom']} ${student['nom']}'),
                  selected: isSelected,
                  onSelected: (_) => _toggleStudentSelection(student['id']),
                  selectedColor: AppTheme.seaBlue.withOpacity(0.2),
                  checkmarkColor: AppTheme.seaBlue,
                  backgroundColor: Colors.grey[100],
                );
              }).toList(),
            ),
        ],
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
              labelText: 'Titre du devoir',
              hintText: 'Ex: Fonctions linéaires — Chapitre 4',
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
              labelText: 'Consignes et détails',
              hintText: 'Exercices à faire, chapitres concernés, consignes spéciales...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.seaBlue)),
            ),
          ),
          // Champ durée estimée uniquement pour devoir de maison
          if (_selectedType == 'maison' || _selectedType == 'exercice') ...[
            const SizedBox(height: 15),
            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Durée estimée (minutes)',
                hintText: 'Ex: 30',
                prefixIcon: const Icon(Icons.timer),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.seaBlue)),
              ),
            ),
          ],
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
      final response = await ApiClient.instance.post('/devoirs', data: {
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
