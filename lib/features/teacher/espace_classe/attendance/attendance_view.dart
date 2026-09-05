import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/features/teacher/agenda/create_appointment_page.dart';
import 'package:app_mobile/features/teacher/espace_classe/students/parent_info_page.dart';
import 'package:app_mobile/features/teacher/espace_classe/attendance/widgets/attendance_global_button.dart';
import 'package:app_mobile/features/teacher/espace_classe/attendance/widgets/attendance_student_card.dart';
import 'package:app_mobile/features/teacher/espace_classe/attendance/widgets/attendance_modal_status_button.dart';
import 'package:app_mobile/features/teacher/espace_classe/attendance/viewmodels/attendance_viewmodel.dart';

class AttendanceView extends StatefulWidget {
  final int studentCount;
  final String className;
  final int classeId;

  const AttendanceView({
    super.key,
    required this.studentCount,
    required this.className,
    this.classeId = 1,
  });

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
  late final AttendanceViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AttendanceViewModel();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    try {
      final alreadyMarked = await _viewModel.fetchStudents(widget.classeId);
      if (alreadyMarked && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'L\'appel a déjà été fait aujourd\'hui. Vous pouvez le modifier ou le réinitialiser dans "Actions".',
            ),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur chargement élèves: $e')),
        );
      }
    }
  }

  void _showGlobalActionsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'ACTIONS GLOBALES',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 25),
            AttendanceGlobalButton(
              label: 'TOUT PRÉSENT',
              color: const Color(0xFF48C774),
              icon: Icons.check_circle,
              onTap: () {
                _applyGlobalStatus(AttendanceStatus.present);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            AttendanceGlobalButton(
              label: 'TOUT ABSENT',
              color: const Color(0xFFF14668),
              icon: Icons.cancel,
              onTap: () {
                _applyGlobalStatus(AttendanceStatus.absent);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            AttendanceGlobalButton(
              label: 'TOUT EN RETARD',
              color: const Color(0xFFFFDD57),
              icon: Icons.access_time_filled,
              textColor: Colors.black87,
              onTap: () {
                _applyGlobalStatus(AttendanceStatus.late);
                Navigator.pop(context);
              },
            ),
            if (_viewModel.markedCount > 0) ...[
              const Divider(height: 30),
              AttendanceGlobalButton(
                label: 'RÉINITIALISER L\'APPEL',
                color: Colors.grey[800]!,
                icon: Icons.refresh,
                onTap: () {
                  _resetAttendance();
                  Navigator.pop(context);
                },
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _resetAttendance() async {
    try {
      await _viewModel.resetAttendance(widget.classeId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('L\'appel a été réinitialisé.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la réinitialisation: $e')),
        );
      }
    }
  }

  void _applyGlobalStatus(AttendanceStatus status) {
    _viewModel.applyGlobalStatus(status);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Statut appliqué à tous les élèves')),
    );
  }

  Color _getStatusColor(AttendanceStatus? status) {
    switch (status) {
      case AttendanceStatus.present:
        return const Color(0xFF48C774); // Green
      case AttendanceStatus.absent:
        return const Color(0xFFF14668); // Red
      case AttendanceStatus.late:
        return const Color(0xFFFFDD57); // Yellow/Orange
      default:
        return Colors.grey[200]!; // Neutral
    }
  }

  String _getStatusText(AttendanceStatus? status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'Présent';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Retard';
      default:
        return 'Non marqué';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<AttendanceViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Text('📊', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              '${viewModel.markedCount} / ${widget.studentCount} marqués',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _showGlobalActionsModal,
                      icon: const Icon(Icons.settings, size: 18),
                      label: const Text('Actions'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF0F7F4),
                        foregroundColor: AppTheme.seaBlue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: viewModel.students.length,
                  itemBuilder: (context, index) {
                    final student = viewModel.students[index];
                    final status = student['status'] as AttendanceStatus?;
                    final color = _getStatusColor(status);

                    return AttendanceStudentCard(
                      index: index,
                      name: student['name'],
                      hasStatus: status != null,
                      statusColor: color,
                      statusText: _getStatusText(status),
                      isLate: status == AttendanceStatus.late,
                      arrivalTime: student['arrivalTime'],
                      onTap: () => _showStudentProfileModal(index),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        bool hasStudents = await viewModel.submitAttendance(widget.classeId);
                        
                        if (!hasStudents) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Veuillez marquer au moins un élève.'),
                              ),
                            );
                          }
                          return;
                        }

                        if (!context.mounted) return;
                        
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: const Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF48C774),
                                  size: 28,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Appel validé !',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            content: Text(
                              'La présence pour la classe ${widget.className} a été enregistrée avec succès.\n\n${viewModel.markedCount} élèves marqués.',
                              style: const TextStyle(fontSize: 14, height: 1.5),
                            ),
                            actions: [
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    Navigator.pop(context); // Optional depending on nav structure
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.forestGreen,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'OK',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        String errorMsg = e.toString();
                        if (e is DioException && e.response?.data != null) {
                          errorMsg = e.response!.data.toString();
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur backend: $errorMsg'),
                            duration: const Duration(seconds: 10),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.forestGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: AppTheme.forestGreen.withOpacity(0.4),
                    ),
                    child: const Text(
                      'VALIDER',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showStudentProfileModal(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final student = _viewModel.students[index];

        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 30),
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFFF0F4F8),
                  child: student['photo_url'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: Image.network(
                            student['photo_url'],
                            fit: BoxFit.cover,
                            width: 80,
                            height: 80,
                            errorBuilder: (c, e, s) => Text(
                              '${index + 1}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E3192),
                              ),
                            ),
                          ),
                        )
                      : Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E3192),
                          ),
                        ),
                ),
                const SizedBox(height: 15),
                Text(
                  student['name'],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                  textAlign: TextAlign.center,
                ),
                Builder(
                  builder: (context) {
                    int? age;
                    if (student['date_naissance'] != null) {
                      try {
                        final dob = DateTime.parse(student['date_naissance']);
                        final today = DateTime.now();
                        age = today.year - dob.year;
                        if (today.month < dob.month ||
                            (today.month == dob.month && today.day < dob.day)) {
                          age--;
                        }
                      } catch (e) {
                        debugPrint('Error parsing dob: $e');
                      }
                    }
                    return Text(
                      'Âge: ${age != null ? "$age ans" : "Inconnu"} | Code Secret: ${student['code_secret']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context); // Close the modal
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ParentInfoPage(
                              studentId: student['id'],
                              studentName: student['name'],
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.info_outline, size: 18),
                      label: const Text(
                        'Info Parent',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.seaBlue.withOpacity(0.1),
                        foregroundColor: AppTheme.seaBlue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                if (student['name'].toString().toLowerCase().contains('junior')) ...[
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.sunYellow.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.sunYellow.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: AppTheme.sunYellow,
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Absences répétées détectées (3 cette semaine). Un contact parent est recommandé.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textDark,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 30),
                const Text(
                  'MARQUER LA PRÉSENCE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: AttendanceModalStatusButton(
                          label: 'PRÉSENT',
                          color: const Color(0xFF48C774),
                          icon: Icons.check_circle,
                          onTap: () => _updateStatusAndClose(
                            index,
                            AttendanceStatus.present,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AttendanceModalStatusButton(
                          label: 'ABSENT',
                          color: const Color(0xFFF14668),
                          icon: Icons.cancel,
                          onTap: () => _updateStatusAndClose(
                            index,
                            AttendanceStatus.absent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AttendanceModalStatusButton(
                    label: student['arrivalTime'] != null
                        ? 'RETARD (${student['arrivalTime']})'
                        : 'MARQUER RETARD',
                    color: const Color(0xFFFFDD57),
                    icon: Icons.access_time_filled,
                    textColor: Colors.black87,
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        helpText: 'HEURE D\'ARRIVÉE DE L\'ÉLÈVE',
                      );
                      if (picked != null && context.mounted) {
                        _viewModel.updateStudentArrivalTime(index, picked.format(context));
                        _updateStatusAndClose(index, AttendanceStatus.late);
                      }
                    },
                  ),
                ),
                if (student['name'].toString().toLowerCase().contains('junior')) ...[
                  const SizedBox(height: 25),
                  const Divider(),
                  const SizedBox(height: 15),
                  const Text(
                    'COORDONNÉES PARENT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: AppTheme.seaBlue,
                                child: Text(
                                  'PA',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Parent',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Contact parent',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(
                                  Icons.phone,
                                  color: AppTheme.forestGreen,
                                ),
                                onPressed: () {},
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context); // Fermer le bottomsheet
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateAppointmentPage(
                                    studentId: student['id'],
                                    parentId: student['parent_id'] ?? 1,
                                    parentName: 'Parent',
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.seaBlue,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 45),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Convoquer le parent'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 30),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Fermer',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _updateStatusAndClose(int index, AttendanceStatus status) {
    _viewModel.updateStudentStatus(index, status);
    Navigator.pop(context);
  }
}
