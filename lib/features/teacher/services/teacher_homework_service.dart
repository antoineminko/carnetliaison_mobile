import 'package:dio/dio.dart';
import 'package:app_mobile/shared/config/api_client.dart';

class TeacherHomeworkService {
  TeacherHomeworkService._();
  static final TeacherHomeworkService instance = TeacherHomeworkService._();

  Future<Response> createHomework(Map<String, dynamic> data) async {
    return await ApiClient.instance.post('/devoirs', data: data);
  }
}
