import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_mobile/shared/config/api_client.dart';

class PingService {
  static final PingService _instance = PingService._internal();
  factory PingService() => _instance;
  PingService._internal();

  Timer? _timer;
  bool _isActive = false;

  void start() {
    if (_isActive) return;
    _isActive = true;
    _ping(); // Immediate ping
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _ping();
    });
  }

  void stop() {
    _isActive = false;
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _ping() async {
    if (!_isActive) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final parentId = prefs.getInt('parent_id');
      final teacherId = prefs.getInt('teacher_id');

      if (parentId != null) {
        await ApiClient.instance.post('/ping', data: {
          'role': 'parent',
          'user_id': parentId,
        });
      } else if (teacherId != null) {
        await ApiClient.instance.post('/ping', data: {
          'role': 'enseignant',
          'user_id': teacherId,
        });
      }
    } catch (e) {
      debugPrint('Error pinging server: $e');
    }
  }
}
