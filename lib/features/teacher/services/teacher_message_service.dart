import 'package:dio/dio.dart';
import 'package:app_mobile/shared/config/api_client.dart';
import 'package:app_mobile/shared/config/api_endpoints.dart';

class TeacherMessageService {
  TeacherMessageService._();
  static final TeacherMessageService instance = TeacherMessageService._();

  Future<Response> getConversations(int teacherId) async {
    return await ApiClient.instance.get(ApiEndpoints.teacherConversations(teacherId));
  }

  Future<Response> updateConversationStatus(int conversationId, String status) async {
    return await ApiClient.instance.put(
      '/messages/conversation/$conversationId/status',
      data: {'status': status},
    );
  }
}
