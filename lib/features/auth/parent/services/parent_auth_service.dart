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
    if (role != UserRole.parent && role != UserRole.teacher) {
      // Pour les autres rôles, simulation pour la démo
      return AuthResult.success;
    }

    try {
      final endpoint = role == UserRole.parent ? ApiEndpoints.login : ApiEndpoints.loginTeacher;
      final response = await ApiClient.instance.post(
        endpoint,
        data: {
          'identifier': username,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data['success']) {
        final prefs = await SharedPreferences.getInstance();

        if (role == UserRole.parent) {
          final parent = response.data['parent'];
          if (parent == null || parent['id'] == null) {
            return AuthResult.invalidCredentials;
          }
          final parentId = parent['id'];
          await prefs.setInt('parent_id', parentId);
          final prenom = parent['prenom']?.toString();
          final nom = parent['nom']?.toString();
          final avatarUrl = parent['avatar_url']?.toString() ?? parent['photo_url']?.toString();
          final email = parent['email']?.toString();
          final telephone = parent['telephone']?.toString();
          if (prenom != null) await prefs.setString('parent_prenom', prenom);
          if (nom != null) await prefs.setString('parent_nom', nom);
          if (avatarUrl != null) await prefs.setString('parent_avatar_url', avatarUrl);
          if (email != null) await prefs.setString('parent_email', email);
          if (telephone != null) await prefs.setString('parent_telephone', telephone);
          // ✅ Enregistrer le token FCM maintenant que parent_id est disponible
          await _registerFcmToken(parentId);
        } else if (role == UserRole.teacher) {
          final teacher = response.data['teacher'];
          if (teacher == null || teacher['id'] == null) {
            return AuthResult.invalidCredentials;
          }
          final teacherId = teacher['id'];
          await prefs.setInt('teacher_id', teacherId);
          // Sauvegarder les données du profil enseignant
          final tPrenom = teacher['prenom']?.toString();
          final tNom = teacher['nom']?.toString();
          final tEmail = teacher['email']?.toString();
          final tTelephone = teacher['telephone']?.toString();
          final tMatiere = teacher['matiere']?.toString();
          if (tPrenom != null) await prefs.setString('teacher_prenom', tPrenom);
          if (tNom != null) await prefs.setString('teacher_nom', tNom);
          if (tEmail != null) await prefs.setString('teacher_email', tEmail);
          if (tTelephone != null) await prefs.setString('teacher_telephone', tTelephone);
          if (tMatiere != null) await prefs.setString('teacher_matiere', tMatiere);
        }

        // Save last login time for 15-minute session
        await prefs.setInt('last_login_time', DateTime.now().millisecondsSinceEpoch);

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

  static Future<int?> getTeacherId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('teacher_id');
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('parent_id');
    await prefs.remove('parent_prenom');
    await prefs.remove('parent_nom');
    await prefs.remove('parent_avatar_url');
    await prefs.remove('parent_email');
    await prefs.remove('parent_telephone');
    await prefs.remove('teacher_id');
    await prefs.remove('teacher_prenom');
    await prefs.remove('teacher_nom');
    await prefs.remove('teacher_email');
    await prefs.remove('teacher_telephone');
    await prefs.remove('teacher_matiere');
    await prefs.remove('last_login_time');
    await prefs.remove('parent_scan_done');
  }
}
