import 'package:dio/dio.dart';
import 'package:app_mobile/shared/config/api_client.dart';
import 'package:app_mobile/shared/config/api_endpoints.dart';

class TeacherStudentService {
  TeacherStudentService._();
  static final TeacherStudentService instance = TeacherStudentService._();

  Future<Response> getStudentsByClassId(int classId) async {
    return await ApiClient.instance.get('/classes/$classId/eleves');
  }

  Future<Response> getTeacherStudentsByClass(int teacherId, int classId) async {
    return await ApiClient.instance.get(ApiEndpoints.classDetails(teacherId, classId));
  }

  Future<Response> getStudentInfo(int studentId) async {
    return await ApiClient.instance.get(ApiEndpoints.studentInfo(studentId));
  }

  Future<Response> submitIncident(Map<String, dynamic> data) async {
    return await ApiClient.instance.post('/incidents', data: data);
  }
}
