import 'package:app_mobile/shared/utils/user_role.dart';
import 'package:app_mobile/shared/config/api_client.dart';
import 'package:app_mobile/shared/config/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_mobile/features/notifications/services/notifications_service.dart';

enum AuthResult { success, invalidCredentials, userNotFound }

class AuthService {
  Future<AuthResult> login({
    required UserRole role,
    required String username,
    required String password,
  }) async {
    if (role != UserRole.parent) {
      // Pour les autres rôles, simulation pour la démo
      return AuthResult.success;
    }

    try {
      final response = await ApiClient.instance.post(
        ApiEndpoints.login,
        data: {
          'identifier': username,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data['success']) {
        final parentId = response.data['parent']['id'];

        // Sauvegarder l'ID du parent localement
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('parent_id', parentId);

        // ✅ Enregistrer le token FCM maintenant que parent_id est disponible
        await _registerFcmToken(parentId);

        return AuthResult.success;
      } else {
        return AuthResult.invalidCredentials;
      }
    } catch (e) {
      return AuthResult.invalidCredentials;
    }
  }

  /// Récupère et envoie le token FCM au serveur après le login
  Future<void> _registerFcmToken(int parentId) async {
    try {
      final token = await NotificationsService().getToken();
      if (token != null && token.isNotEmpty) {
        await ApiClient.instance.post(
          ApiEndpoints.registerFcmToken,
          data: {
            'parent_id': parentId,
            'token': token,
            'platform': 'android',
          },
        );
        print('✅ [AuthService] FCM Token enregistré pour parent #$parentId');
      }
    } catch (e) {
      // Non bloquant : le login réussit même si l'enregistrement du token échoue
      print('⚠️ [AuthService] Impossible d\'enregistrer le FCM token : $e');
    }
  }

  Future<AuthResult> verifyParentLink({
    required String email,
    required String password,
    required String childQrCode,
  }) async {
    return login(role: UserRole.parent, username: email, password: password);
  }

  static Future<int?> getParentId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('parent_id');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('parent_id');
  }
}
