import 'package:app_mobile/shared/config/api_client.dart';
import 'package:app_mobile/shared/config/api_endpoints.dart';

class ParentService {
  static Future<List<Map<String, dynamic>>> getChildren(int parentId) async {
    final response = await ApiClient.instance.get(
      ApiEndpoints.parentChildren(parentId),
    );
    if (response.statusCode == 200) {
      final data = response.data;
      if (data is List) {
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      }
      // Réponse inattendue (ex: DB vide, erreur backend)
      throw Exception('Unexpected children response format');
    }
    throw Exception('Failed to fetch children: ${response.statusCode}');
  }

  static Future<List<Map<String, dynamic>>> getConversations(int parentId) async {
    final response = await ApiClient.instance.get(
      ApiEndpoints.parentConversations(parentId),
    );

    final data = response.data;
    if (data != null && data['conversations'] is List) {
      return (data['conversations'] as List)
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    return [];
  }

  static Future<List<Map<String, dynamic>>> getEvents(int parentId) async {
    final response = await ApiClient.instance.get('/parents/$parentId/events');
    final data = response.data;
    if (data != null && data['appointments'] is List) {
      return (data['appointments'] as List).map((item) => Map<String, dynamic>.from(item)).toList();
    }
    return [];
  }

  static Future<bool> verifyChildAccess(int parentId, int eleveId, String code) async {
    try {
      final response = await ApiClient.instance.post(
        '/parents/$parentId/children/$eleveId/verify',
        data: {'code': code},
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
