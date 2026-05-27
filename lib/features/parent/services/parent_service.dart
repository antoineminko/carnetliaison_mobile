import 'package:app_mobile/shared/config/api_client.dart';
import 'package:app_mobile/shared/config/api_endpoints.dart';

class ParentService {
  static Future<List<Map<String, dynamic>>> getChildren(int parentId) async {
    final response = await ApiClient.instance.get(
      ApiEndpoints.parentChildren(parentId),
    );

    final data = response.data;
    if (data is List) {
      return data.map((item) => Map<String, dynamic>.from(item)).toList();
    }

    return [];
  }
}
