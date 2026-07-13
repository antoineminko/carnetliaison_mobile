import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/shared/pages/appointment_page.dart';
import 'package:app_mobile/features/teacher/services/teacher_student_service.dart';
import 'widgets/incident_dialog.dart';
import 'widgets/multi_incident_dialog.dart';
import 'widgets/student_stats_dialog.dart';
import 'widgets/parent_contact_dialog.dart';
import 'package:intl/intl.dart';

class TeacherStudentListPage extends StatefulWidget {
  final String className;
  final int studentCount;
  final int? classId;
  final int? teacherId;

  const TeacherStudentListPage({
    super.key,
    required this.className,
    required this.studentCount,
    this.classId,
    this.teacherId,
  });

  @override
  State<TeacherStudentListPage> createState() => _TeacherStudentListPageState();
}

class _TeacherStudentListPageState extends State<TeacherStudentListPage> {
  List<dynamic> _students = [];
  bool _isLoading = true;
  Set<int> _selectedStudentIds = {}; 
  bool _isMultiSelectMode = false; 

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  void _toggleSelection(int studentId) {
    setState(() {
      if (_selectedStudentIds.contains(studentId)) {
        _selectedStudentIds.remove(studentId);
      } else {
        _selectedStudentIds.add(studentId);
      }
      // Désactiver le mode multi-sélection si aucun élève sélectionné
      if (_selectedStudentIds.isEmpty) {
        _isMultiSelectMode = false;
      }
    });
  }

  void _enterMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = true;
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedStudentIds.clear();
      _isMultiSelectMode = false;
    });
  }

  void _selectAll() {
    setState(() {
      _selectedStudentIds = _students.map((s) => s['id'] as int).toSet();
    });
  }

  Future<void> _fetchStudents() async {
    if (widget.classId == null || widget.teacherId == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final response = await TeacherStudentService.instance.getTeacherStudentsByClass(widget.teacherId!, widget.classId!);
      if (response.statusCode == 200 && response.data['success']) {
        setState(() {
          _students = response.data['eleves'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Erreur de récupération des élèves : $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Élèves - ${widget.className}',
          style: const TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppTheme.textDark),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de statut et contrôles de sélection
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppTheme.seaBlue, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${widget.studentCount} élèves inscrits',
                        style: const TextStyle(color: AppTheme.textGrey, fontWeight: FontWeight.w500),
                      ),
                    ),
                    // Boutons de sélection
                    if (!_isMultiSelectMode)
                      TextButton.icon(
                        onPressed: _enterMultiSelectMode,
                        icon: const Icon(Icons.check_box_outlined, size: 18),
                        label: const Text('Sélection multiple'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.seaBlue,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      )
                    else ...[
                      TextButton.icon(
                        onPressed: _selectedStudentIds.length == _students.length ? _clearSelection : _selectAll,
                        icon: Icon(
                          _selectedStudentIds.length == _students.length 
                            ? Icons.indeterminate_check_box 
                            : Icons.check_box,
                          size: 18,
                        ),
                        label: Text(_selectedStudentIds.length == _students.length ? 'Tout désélectionner' : 'Tout sélectionner'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.seaBlue,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                      TextButton(
                        onPressed: _clearSelection,
                        child: const Text('Annuler'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ],
                  ],
                ),
                // Barre de sélection actif
                if (_isMultiSelectMode && _selectedStudentIds.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.red[700], size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${_selectedStudentIds.length} élève(s) sélectionné(s)',
                            style: TextStyle(
                              color: Colors.red[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showMultiIncidentDialog(),
                          icon: const Icon(Icons.warning_amber_rounded, size: 18),
                          label: const Text('Signaler'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      return _buildStudentCard(context, student);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _buildPhotoUrl(dynamic student) {
    // Si photo_url existe et contient http, l'utiliser directement
    final photoUrl = student['photo_url'];
    if (photoUrl != null && photoUrl.toString().startsWith('http')) {
      return photoUrl;
    }
    
    // Si photo existe, construire l'URL complète
    final photo = student['photo'];
    if (photo != null && photo.toString().isNotEmpty) {
      const baseUrl = 'https://sirh.alwaysdata.net/api_carnet_liaison/storage';
      return '$baseUrl/$photo';
    }
    
    return '';
  }

  Widget _buildStudentCard(BuildContext context, dynamic student) {
    final name = "${student['prenom']} ${student['nom']}";
    final matricule = "MAT-${student['id']}";
    // Construire l'URL complète de la photo
    final photo = _buildPhotoUrl(student);
    final studentId = student['id'] as int;
    final isSelected = _selectedStudentIds.contains(studentId);

    return GestureDetector(
      onTap: _isMultiSelectMode
          ? () => _toggleSelection(studentId)
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.red.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: isSelected
              ? Border.all(color: Colors.red.withOpacity(0.5), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Checkbox en mode sélection
            if (_isMultiSelectMode)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Checkbox(
                  value: isSelected,
                  onChanged: (_) => _toggleSelection(studentId),
                  activeColor: Colors.red,
                ),
              ),
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.seaBlue.withOpacity(0.1),
                border: Border.all(
                  color: isSelected ? Colors.red.withOpacity(0.3) : AppTheme.seaBlue.withOpacity(0.1),
                  width: isSelected ? 3 : 2,
                ),
                image: photo.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(photo),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: photo.isEmpty
                  ? Center(
                      child: Text(
                        '${student['prenom']?[0] ?? ''}${student['nom']?[0] ?? ''}'.toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.seaBlue,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.red[700] : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              matricule,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            if (!_isMultiSelectMode)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIconButton(
                    context: context,
                    icon: Icons.bar_chart_rounded,
                    color: AppTheme.sunYellow,
                    tooltip: 'Statistiques',
                    onTap: () => _showStatsDialog(context, student),
                  ),
                  const SizedBox(width: 8),
                  _buildIconButton(
                    context: context,
                    icon: Icons.warning_amber_rounded,
                    color: Colors.redAccent,
                    tooltip: 'Signaler Incident',
                    onTap: () => _showIncidentDialog(context, student),
                  ),
                  const SizedBox(width: 8),
                  _buildIconButton(
                    context: context,
                    icon: Icons.person_search_rounded,
                    color: AppTheme.seaBlue,
                    tooltip: 'Info Parent',
                    onTap: () => _showParentDialog(context, student),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  void _showStatsDialog(BuildContext context, dynamic student) {
    showStudentStatsDialog(context: context, student: student, onShowParent: () => _showParentDialog(context, student));
  }

  void _showIncidentDialog(BuildContext context, dynamic student) {
    showIncidentDialog(context: context, student: student, onSubmit: _submitIncident);
  }

  Future<void> _submitIncident(int eleveId, String type, String description, BuildContext modalContext) async {
    try {
      final response = await TeacherStudentService.instance.submitIncident({
        'eleve_id': eleveId,
        'enseignant_id': widget.teacherId,
        'classe_id': widget.classId,
        'type': type,
        'description': description.isNotEmpty ? description : null,
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      });

      if (response.statusCode == 201 && response.data['success'] == true) {
        if (mounted) {
          Navigator.pop(modalContext);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Incident signalé avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception(response.data['message'] ?? 'Erreur inconnue');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Modal pour signaler un incident à plusieurs élèves sélectionnés
  void _showMultiIncidentDialog() {
    if (_selectedStudentIds.isEmpty) return;
    showMultiIncidentDialog(context: context, selectedCount: _selectedStudentIds.length, onSubmit: _submitMultiIncident);
  }

  Future<void> _submitMultiIncident(String type, String description, BuildContext modalContext) async {
    try {
      final elevesIds = _selectedStudentIds.toList();
      
      final response = await TeacherStudentService.instance.submitIncident({
        'eleves_ids': elevesIds,
        'enseignant_id': widget.teacherId,
        'classe_id': widget.classId,
        'type': type,
        'description': description.isNotEmpty ? description : null,
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      });

      if (response.statusCode == 201 && response.data['success'] == true) {
        if (mounted) {
          Navigator.pop(modalContext);
          _clearSelection(); // Réinitialiser la sélection
          
          final count = response.data['data']?['count'] ?? elevesIds.length;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$count incident(s) signalé(s) avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception(response.data['message'] ?? 'Erreur inconnue');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textGrey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        ],
      ),
    );
  }

  void _showParentDialog(BuildContext context, dynamic student) {
    showParentContactDialog(context: context, student: student);
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.seaBlue),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}

