import 'package:app_mobile/shared/config/api_client.dart';
import 'package:app_mobile/shared/config/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParentService {
  static Future<List<Map<String, dynamic>>> getChildren(int defaultParentId) async {
    List<Map<String, dynamic>> allChildren = [];
    final prefs = await SharedPreferences.getInstance();

    for (final prefix in ApiClient.schoolServers.keys) {
      final dio = ApiClient.getInstanceForUrl(ApiClient.schoolServers[prefix]!);
      int targetParentId = defaultParentId;

      if (dio.options.baseUrl != ApiClient.defaultServerUrl) {
        targetParentId = prefs.getInt('parent_id_$prefix') ?? -1;
        if (targetParentId == -1) {
          final email = prefs.getString('parent_email');
          final password = prefs.getString('parent_password');
          if (email != null && password != null) {
            try {
              final loginResp = await dio.post(ApiEndpoints.login, data: {'identifier': email, 'password': password});
              if (loginResp.statusCode == 200 && loginResp.data['success']) {
                targetParentId = loginResp.data['parent']['id'];
                await prefs.setInt('parent_id_$prefix', targetParentId);
              }
            } catch (_) {}
          }
        }
      }

      if (targetParentId != -1) {
        try {
          final response = await dio.get(ApiEndpoints.parentChildren(targetParentId));
          if (response.statusCode == 200) {
            final data = response.data;
            if (data is List) {
              for (var item in data) {
                final childMap = Map<String, dynamic>.from(item);
                childMap['_school_prefix'] = prefix;
                allChildren.add(childMap);
              }
            }
          }
        } catch (_) {
          // Ignore errors for a specific server to allow others to load
        }
      }
    }
    return allChildren;
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

  static const String _verifiedChildrenKey = 'locally_verified_children';

  static Future<List<int>> getLocallyVerifiedChildren() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> stringList = prefs.getStringList(_verifiedChildrenKey) ?? [];
    return stringList.map((e) => int.tryParse(e) ?? -1).where((e) => e != -1).toList();
  }

  static Future<void> addLocallyVerifiedChild(int childId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> stringList = prefs.getStringList(_verifiedChildrenKey) ?? [];
    if (!stringList.contains(childId.toString())) {
      stringList.add(childId.toString());
      await prefs.setStringList(_verifiedChildrenKey, stringList);
    }
  }

  static Future<bool> verifyChildAccess(int parentId, int eleveId, String code) async {
    try {
      final response = await ApiClient.instance.post(
        '/parents/$parentId/children/$eleveId/verify',
        data: {'code': code},
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        // Sauvegarder localement après succès côté serveur
        await addLocallyVerifiedChild(eleveId);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
