import 'package:dio/dio.dart';
import 'package:app_mobile/shared/config/api_client.dart';
import 'package:app_mobile/shared/config/api_endpoints.dart';
import 'package:app_mobile/features/communication/models/message.dart';
import 'package:app_mobile/features/communication/models/conversation.dart';

class MessageService {
  final Dio _dio = ApiClient.instance;

  Future<List<Conversation>> getConversationsForParent(int parentId) async {
    try {
      final response = await _dio.get('/parents/$parentId/conversations');
      if (response.statusCode == 200 && response.data['success']) {
        final List data = response.data['conversations'];
        return data.map((c) => Conversation.fromJson(c)).toList();
      }
      return [];
    } catch (e) {
      print('Error getting parent conversations: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getConversation(int parentId, int? enseignantId) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.getConversation,
        queryParameters: {
          'parent_id': parentId,
          if (enseignantId != null) 'enseignant_id': enseignantId,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        List<Message> messages = (data['messages'] as List)
            .map((msg) => Message.fromJson(msg))
            .toList();

        return {
          'conversation_id': data['conversation_id'],
          'messages': messages,
        };
      }
      throw Exception('Failed to load conversation');
    } catch (e) {
      print('Error getting conversation: $e');
      rethrow;
    }
  }

  Future<Message> sendMessage({
    required int conversationId,
    required String senderType,
    required int senderId,
    required String content,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.sendMessage,
        data: {
          'conversation_id': conversationId,
          'sender_type': senderType,
          'sender_id': senderId,
          'content': content,
        },
      );

      if (response.statusCode == 201) {
        return Message.fromJson(response.data);
      }
      throw Exception('Failed to send message');
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }
}
