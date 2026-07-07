import 'package:dio/dio.dart';
import 'package:app_mobile/shared/config/api_client.dart';

class TeacherAttendanceService {
  TeacherAttendanceService._();
  static final TeacherAttendanceService instance = TeacherAttendanceService._();

  Future<Response> submitAttendance(Map<String, dynamic> data) async {
    return await ApiClient.instance.post('/attendances', data: data);
  }

  Future<Response> resetAttendance(Map<String, dynamic> data) async {
    return await ApiClient.instance.post('/attendances/reset', data: data);
  }
}
