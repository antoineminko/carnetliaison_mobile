import 'package:app_mobile/shared/utils/user_role.dart';
import 'package:app_mobile/shared/config/api_client.dart';
import 'package:app_mobile/shared/config/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

        return AuthResult.success;
      } else {
        return AuthResult.invalidCredentials;
      }
    } catch (e) {
      
      return AuthResult.invalidCredentials;
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
}
