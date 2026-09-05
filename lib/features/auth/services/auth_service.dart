import 'package:app_mobile/shared/utils/user_role.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:app_mobile/shared/config/api_client.dart';
import 'package:app_mobile/shared/config/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_mobile/features/notifications/services/notifications_service.dart';
import 'package:app_mobile/shared/utils/secure_storage_service.dart';

enum AuthResult { success, invalidCredentials, userNotFound, networkError }

class AuthResponse {
  final AuthResult result;
  final List<dynamic>? teachersData;

  AuthResponse({required this.result, this.teachersData});
}

class AuthService {
  Future<AuthResponse> login({
    required UserRole role,
    required String username,
    required String password,
    bool rememberMe = false,
  }) async {
    if (role != UserRole.parent && role != UserRole.teacher) {
      return AuthResponse(result: AuthResult.success);
    }

    try {
      final endpoint = role == UserRole.parent
          ? ApiEndpoints.login
          : ApiEndpoints.loginTeacher;
      final response = await ApiClient.instance.post(
        endpoint,
        data: {'identifier': username, 'password': password},
      );

      if (response.statusCode == 200 && response.data['success']) {
        final prefs = await SharedPreferences.getInstance();

        if (role == UserRole.parent) {
          final parent = response.data['parent'];
          if (parent == null || parent['id'] == null) {
            return AuthResponse(result: AuthResult.invalidCredentials);
          }
          final parentId = parent['id'];
          await prefs.setInt('parent_id', parentId);
          final prenom = parent['prenom']?.toString();
          final nom = parent['nom']?.toString();
          final avatarUrl =
              parent['avatar_url']?.toString() ??
              parent['photo_url']?.toString();
          final email = parent['email']?.toString();
          final telephone = parent['telephone']?.toString();
          if (prenom != null) await prefs.setString('parent_prenom', prenom);
          if (nom != null) await prefs.setString('parent_nom', nom);
          if (avatarUrl != null)
            await prefs.setString('parent_avatar_url', avatarUrl);
          if (email != null) await prefs.setString('parent_email', email);
          if (telephone != null)
            await prefs.setString('parent_telephone', telephone);

          // Sauvegarde secrète du mot de passe pour la connexion multi-serveurs
          await SecureStorageService.save('parent_password', password);

          // ✅ Enregistrer le token FCM maintenant que parent_id est disponible
          await _registerFcmToken(parentId);
          // Pour le parent, on termine l'authentification ici
          return AuthResponse(result: AuthResult.success);
        } else if (role == UserRole.teacher) {
          final teachers = response.data['teachers'] as List<dynamic>?;
          if (teachers == null || teachers.isEmpty) {
            return AuthResponse(result: AuthResult.invalidCredentials);
          }

          // Sauvegarder les identifiants pour un usage futur si besoin
          await prefs.setString('teacher_email_cache', username);
          await SecureStorageService.save('teacher_password_cache', password);
          await prefs.setString('teacher_schools_cache', jsonEncode(teachers));
          await prefs.setBool('remember_me', rememberMe);
          final nowMs = DateTime.now().millisecondsSinceEpoch;
          await prefs.setInt('last_login_time', nowMs);
          await prefs.setInt('last_activity_time', nowMs);

          // On retourne la liste des écoles pour l'écran TeacherSchoolsPage
          return AuthResponse(
            result: AuthResult.success,
            teachersData: teachers,
          );
        }

        return AuthResponse(result: AuthResult.success);
      } else {
        return AuthResponse(result: AuthResult.invalidCredentials);
      }
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError) {
          return AuthResponse(result: AuthResult.networkError);
        }
      }
      return AuthResponse(result: AuthResult.invalidCredentials);
    }
  }

  /// Finalise la connexion de l'enseignant après qu'il ait choisi une école
  static Future<void> setTeacherProfile(
    Map<String, dynamic> teacherData,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final teacherId = teacherData['id'];
    final ecole = teacherData['ecole'];

    if (teacherId == null || ecole == null || ecole['code'] == null) return;

    await prefs.setInt('teacher_id', teacherId);
    await prefs.setString('school_code', ecole['code']);

    final tPrenom = teacherData['prenom']?.toString();
    final tNom = teacherData['nom']?.toString();
    final tEmail = teacherData['email']?.toString();
    final tTelephone = teacherData['telephone']?.toString();
    final tMatiere = teacherData['matiere']?.toString();

    if (tPrenom != null) await prefs.setString('teacher_prenom', tPrenom);
    if (tNom != null) await prefs.setString('teacher_nom', tNom);
    if (tEmail != null) await prefs.setString('teacher_email', tEmail);
    if (tTelephone != null)
      await prefs.setString('teacher_telephone', tTelephone);
    if (tMatiere != null) await prefs.setString('teacher_matiere', tMatiere);

    // Save last login time for session management
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt('last_login_time', nowMs);
    await prefs.setInt('last_activity_time', nowMs);

    // ✅ Enregistrer le token FCM pour les notifications push enseignant
    await _registerTeacherFcmToken(teacherId is int ? teacherId : int.tryParse(teacherId.toString()) ?? 0);
  }

  /// Enregistre le token FCM pour un enseignant
  static Future<void> _registerTeacherFcmToken(int teacherId) async {
    try {
      final token = await NotificationsService().getToken();
      if (token != null && token.isNotEmpty) {
        await ApiClient.instance.post(
          ApiEndpoints.registerFcmToken,
          data: {'enseignant_id': teacherId, 'token': token, 'platform': 'android'},
        );
        debugPrint('✅ [AuthService] FCM Token enregistré pour enseignant #$teacherId');
      }
    } catch (e) {
      // Non bloquant
      debugPrint('⚠️ [AuthService] Impossible d\'enregistrer le FCM token enseignant : $e');
    }
  }

  /// Récupère et envoie le token FCM au serveur après le login
  Future<void> _registerFcmToken(int parentId) async {
    try {
      final token = await NotificationsService().getToken();
      if (token != null && token.isNotEmpty) {
        await ApiClient.instance.post(
          ApiEndpoints.registerFcmToken,
          data: {'parent_id': parentId, 'token': token, 'platform': 'android'},
        );
        debugPrint(
          '✅ [AuthService] FCM Token enregistré pour parent #$parentId',
        );
      }
    } catch (e) {
      // Non bloquant : le login réussit même si l'enregistrement du token échoue
      debugPrint(
        '⚠️ [AuthService] Impossible d\'enregistrer le FCM token : $e',
      );
    }
  }

  Future<AuthResponse> verifyParentLink({
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

  static Future<String?> getLastLoginTime() async {
    final prefs = await SharedPreferences.getInstance();
    final time = prefs.getInt('last_login_time');
    if (time != null) {
      return DateTime.fromMillisecondsSinceEpoch(time).toIso8601String();
    }
    return null;
  }

  static Future<int?> getParentIdForSchool(String? schoolPrefix) async {
    final prefs = await SharedPreferences.getInstance();
    int? defaultParentId = prefs.getInt('parent_id');

    if (schoolPrefix == null) {
      return defaultParentId;
    }
    int? cachedId = prefs.getInt('parent_id_$schoolPrefix');
    if (cachedId != null) return cachedId;
    final email = prefs.getString('parent_email');
    final password = await SecureStorageService.read('parent_password');
    if (email != null && password != null) {
      try {
        // Multi-tenant is now handled via headers in ApiClient.instance
        // We temporarily set the school_code for this request if needed,
        // but here we might need to be careful not to overwrite the global one permanently
        // if this is just a check.
        // For now, let's just use the main instance.
        final loginResp = await ApiClient.instance.post(
          ApiEndpoints.login,
          data: {'identifier': email, 'password': password},
        );
        if (loginResp.statusCode == 200 && loginResp.data['success']) {
          final targetId = loginResp.data['parent']['id'];
          await prefs.setInt('parent_id_$schoolPrefix', targetId);
          return targetId;
        }
      } catch (e) {
        debugPrint(
          '⚠️ [AuthService] Silent login failed for $schoolPrefix: $e',
        );
      }
    }

    // Fallback if silent login fails
    return null;
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
    await prefs.remove('school_code');
    await prefs.remove('teacher_prenom');
    await prefs.remove('teacher_nom');
    await prefs.remove('teacher_email');
    await prefs.remove('teacher_telephone');
    await prefs.remove('teacher_matiere');
    await prefs.remove('teacher_email_cache');
    await SecureStorageService.delete('teacher_password_cache');
    await SecureStorageService.delete('parent_password');
    await prefs.remove('teacher_schools_cache');
    await prefs.remove('last_login_time');
    await prefs.remove('last_activity_time');
    await prefs.remove('parent_scan_done');
  }
}
