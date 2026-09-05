import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:app_mobile/features/teacher/services/teacher_student_service.dart';
import 'package:app_mobile/features/teacher/services/teacher_attendance_service.dart';

enum AttendanceStatus { present, absent, late }

class AttendanceViewModel extends ChangeNotifier {
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = true;
  int _markedCount = 0;

 
  List<Map<String, dynamic>> get students => _students;
  bool get isLoading => _isLoading;
  int get markedCount => _markedCount;

  Future<bool> fetchStudents(int classeId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await TeacherStudentService.instance.getStudentsByClassId(classeId);
      final data = response.data as List;

      _markedCount = 0;
      _students = data.map((e) {
        AttendanceStatus? currentStatus;
        if (e['statut_presence'] == 'present') {
          currentStatus = AttendanceStatus.present;
        } else if (e['statut_presence'] == 'absent') {
          currentStatus = AttendanceStatus.absent;
        } else if (e['statut_presence'] == 'late') {
          currentStatus = AttendanceStatus.late;
        }

        if (currentStatus != null) _markedCount++;

        return {
          'id': e['id'],
          'name': '${e['prenom']} ${e['nom']}',
          'status': currentStatus,
          'arrivalTime': null,
          'matricule': e['matricule'] ?? 'N/A',
          'photo_url': e['photo_url'],
          'date_naissance': e['date_naissance'],
          'code_secret': e['code_secret'] ?? 'Non défini',
          'parent_id': e['parent_id'],
        };
      }).toList();

      _isLoading = false;
      notifyListeners();

      return _markedCount > 0;
    } catch (e) {
      _students = [];
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void updateMarkedCount() {
    _markedCount = _students.where((s) => s['status'] != null).length;
    notifyListeners();
  }

  Future<void> resetAttendance(int classeId) async {
    final response = await TeacherAttendanceService.instance.resetAttendance({
      'classe_id': classeId,
      'date': DateTime.now().toIso8601String().split('T')[0],
    });

    if (response.data['success']) {
      for (var student in _students) {
        student['status'] = null;
        student['arrivalTime'] = null;
      }
      _markedCount = 0;
      notifyListeners();
    }
  }

  void applyGlobalStatus(AttendanceStatus status) {
    for (var student in _students) {
      student['status'] = status;
      if (status == AttendanceStatus.late && student['arrivalTime'] == null) {
        student['arrivalTime'] = '08:15'; 
      }
    }
    updateMarkedCount();
  }

  void updateStudentStatus(int index, AttendanceStatus status) {
    _students[index]['status'] = status;
    updateMarkedCount();
  }

  void updateStudentArrivalTime(int index, String time) {
    _students[index]['arrivalTime'] = time;
    notifyListeners();
  }

  Future<bool> submitAttendance(int classeId) async {
    final attendances = _students
        .where((s) => s['status'] != null)
        .map((s) {
          String statusStr = 'present';
          if (s['status'] == AttendanceStatus.absent) statusStr = 'absent';
          if (s['status'] == AttendanceStatus.late) statusStr = 'late';
          return {'eleve_id': s['id'], 'status': statusStr};
        })
        .toList();

    if (attendances.isEmpty) {
      return false; 
    }

    final response = await TeacherAttendanceService.instance.submitAttendance({
      'classe_id': classeId,
      'date': DateTime.now().toIso8601String().split('T')[0],
      'attendances': attendances,
    });

    return response.data['success'] == true;
  }
}
