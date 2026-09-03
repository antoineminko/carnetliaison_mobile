import 'package:dio/dio.dart';
import 'package:app_mobile/shared/config/api_client.dart';
import 'package:app_mobile/shared/config/api_endpoints.dart';

class TeacherTextbookService {
  TeacherTextbookService._();
  static final TeacherTextbookService instance = TeacherTextbookService._();

  Future<Response> createTextbook(Map<String, dynamic> data) async {
    return await ApiClient.instance.post('/cahier-textes', data: data);
  }

  Future<Response> generateSummary(String content) async {
    return await ApiClient.instance.post('/ai/summarize', data: {'content': content});
  }

  Future<Response> getCourses(int classId, {String? subject}) async {
    final Map<String, dynamic> query = {};
    if (subject != null) query['matiere'] = subject;
    return await ApiClient.instance.get('/classes/$classId/cahier-textes', queryParameters: query);
  }
}
