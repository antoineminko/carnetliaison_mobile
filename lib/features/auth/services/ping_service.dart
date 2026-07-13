import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:app_mobile/shared/config/api_client.dart';
import 'package:app_mobile/features/auth/services/auth_service.dart';

class PingService {
  static Timer? _timer;

  static void startPinging() {
    _timer?.cancel();
    _ping(); // Exécuter immédiatement
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _ping());
  }

  static void stopPinging() {
    _timer?.cancel();
    _timer = null;
  }

  static Future<void> _ping() async {
    try {
      final teacherId = await AuthService.getTeacherId();
      if (teacherId != null) {
        await ApiClient.instance.post('/ping', data: {
          'role': 'enseignant',
          'user_id': teacherId,
        });
      }
    } catch (e) {
      debugPrint('Ping failed: $e');
    }
  }
}
