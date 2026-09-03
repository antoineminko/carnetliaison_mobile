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

  Future<Map<String, dynamic>> getConversation(int? parentId, int? enseignantId) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.getConversation,
        queryParameters: {
          if (parentId != null) 'parent_id': parentId,
          if (enseignantId != null) 'enseignant_id': enseignantId,
          'viewer_type': 'teacher',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        List<Message> messages = (data['messages'] as List)
            .map((msg) => Message.fromJson(msg))
            .toList();

        return {
          'conversation_id': data['conversation_id'],
          'status': data['status'],
          'subject': data['subject'],
          'messages': messages,
        };
      }
      throw Exception('Failed to load conversation');
    } catch (e) {
      print('Error getting conversation: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> initiateConversation({
    int? parentId,
    required int enseignantId,
    required String initialMessage,
    String? subject,
  }) async {
    try {
      final response = await _dio.post(
        '/messages/conversation/initiate',
        data: {
          if (parentId != null) 'parent_id': parentId,
          'enseignant_id': enseignantId,
          'initial_message': initialMessage,
          'sender_type': 'enseignant',
          if (subject != null) 'subject': subject,
        },
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to initiate conversation');
    } catch (e) {
      print('Error initiating conversation: $e');
      rethrow;
    }
  }

  Future<Message> sendMessage({
    required int conversationId,
    required String senderType,
    required int senderId,
    required String content,
    String? filePath,
    String? fileName,
  }) async {
    try {
      final Map<String, dynamic> dataMap = {
        'conversation_id': conversationId,
        'sender_type': senderType,
        'sender_id': senderId,
        'content': content,
      };

      final formData = FormData.fromMap(dataMap);

      if (filePath != null) {
        formData.files.add(MapEntry(
          'fichier',
          await MultipartFile.fromFile(
            filePath,
            filename: fileName ?? 'attachment',
          ),
        ));
      }

      final response = await _dio.post(
        ApiEndpoints.sendMessage,
        data: formData,
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

  Future<List<Map<String, dynamic>>> getCallHistory(String role, int userId) async {
    try {
      final response = await _dio.get(
        '/calls/history',
        queryParameters: {
          'role': role,
          'user_id': userId,
        },
      );
      if (response.statusCode == 200 && response.data['success']) {
        return List<Map<String, dynamic>>.from(response.data['calls']);
      }
      return [];
    } catch (e) {
      print('Error fetching call history: $e');
      return [];
    }
  }
}
