import 'package:dio/dio.dart';
import 'package:app_mobile/shared/config/api_client.dart';

class TeacherGradesService {
  TeacherGradesService._();
  static final TeacherGradesService instance = TeacherGradesService._();

  Future<Response> saveGrades(Map<String, dynamic> data) async {
    // Expected to be integrated with real backend endpoint, ex: /notes or /evaluations
    return await ApiClient.instance.post('/notes', data: data);
  }
}
