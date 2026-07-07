import 'package:app_mobile/shared/config/api_client.dart';
import 'package:app_mobile/shared/config/api_endpoints.dart';
import 'package:app_mobile/features/auth/parent/services/parent_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParentService {
  static Future<List<Map<String, dynamic>>> getChildren(int defaultParentId) async {
    List<Map<String, dynamic>> allChildren = [];
    final prefs = await SharedPreferences.getInstance();

    for (final prefix in ApiClient.schoolServers.keys) {
      final dio = ApiClient.getInstanceForUrl(ApiClient.schoolServers[prefix]!);
      int targetParentId = defaultParentId;

      if (dio.options.baseUrl != ApiClient.defaultServerUrl) {
        targetParentId = await AuthService.getParentIdForSchool(prefix) ?? -1;
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

  static Future<List<Map<String, dynamic>>> getConversations(int defaultParentId) async {
    List<Map<String, dynamic>> allConversations = [];
    
    for (final prefix in ApiClient.schoolServers.keys) {
      final dio = ApiClient.getInstanceForUrl(ApiClient.schoolServers[prefix]!);
      int targetParentId = defaultParentId;

      if (dio.options.baseUrl != ApiClient.defaultServerUrl) {
        targetParentId = await AuthService.getParentIdForSchool(prefix) ?? -1;
      }

      if (targetParentId != -1) {
        try {
          final response = await dio.get(ApiEndpoints.parentConversations(targetParentId));
          final data = response.data;
          if (data != null && data['conversations'] is List) {
            for (var item in data['conversations']) {
              final convMap = Map<String, dynamic>.from(item);
              convMap['_school_prefix'] = prefix;
              allConversations.add(convMap);
            }
          }
        } catch (_) {}
      }
    }
    return allConversations;
  }

  static Future<List<Map<String, dynamic>>> getEvents(int defaultParentId) async {
    List<Map<String, dynamic>> allEvents = [];
    
    for (final prefix in ApiClient.schoolServers.keys) {
      final dio = ApiClient.getInstanceForUrl(ApiClient.schoolServers[prefix]!);
      int targetParentId = defaultParentId;

      if (dio.options.baseUrl != ApiClient.defaultServerUrl) {
        targetParentId = await AuthService.getParentIdForSchool(prefix) ?? -1;
      }

      if (targetParentId != -1) {
        try {
          final response = await dio.get('/parents/$targetParentId/events');
          final data = response.data;
          if (data != null && data['appointments'] is List) {
            for (var item in data['appointments']) {
              final evtMap = Map<String, dynamic>.from(item);
              evtMap['_school_prefix'] = prefix;
              allEvents.add(evtMap);
            }
          }
        } catch (_) {}
      }
    }
    return allEvents;
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

  static Future<bool> verifyChildAccess(int parentId, int eleveId, String code, {String? schoolPrefix}) async {
    try {
      final dio = schoolPrefix != null && ApiClient.schoolServers.containsKey(schoolPrefix)
          ? ApiClient.getInstanceForUrl(ApiClient.schoolServers[schoolPrefix]!)
          : ApiClient.instance;

      int targetParentId = parentId;
      if (dio.options.baseUrl != ApiClient.defaultServerUrl && schoolPrefix != null) {
        targetParentId = await AuthService.getParentIdForSchool(schoolPrefix) ?? parentId;
      }

      final response = await dio.post(
        '/parents/$targetParentId/children/$eleveId/verify',
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
