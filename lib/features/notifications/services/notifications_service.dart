import 'package:flutter/foundation.dart';
import 'firebase_service.dart';
import 'local_notification_service.dart';

class NotificationsService {
  late final FirebaseService _firebaseService;
  late final LocalNotificationService _localNotificationService;
  VoidCallback? _onNotificationReceived;

  static final NotificationsService _instance = NotificationsService._internal();

  factory NotificationsService({VoidCallback? onNotificationReceived}) {
    if (onNotificationReceived != null) {
      _instance._onNotificationReceived = onNotificationReceived;
    }
    return _instance;
  }

  NotificationsService._internal() {
    _localNotificationService = LocalNotificationService();
    _firebaseService = FirebaseService(
      _localNotificationService,
      onNotificationReceived: () {
        _onNotificationReceived?.call();
      },
    );
  }

  Future<void> init() async {
    print('🚀 [NotificationsService] Initialisation des services de notifications...');
    await _localNotificationService.init();
    await _firebaseService.init();
    print('✅ [NotificationsService] Initialisation terminée.');
  }

  Future<String?> getToken() async {
    return await _firebaseService.getFCMToken();
  }

  void setOnNotificationReceived(VoidCallback callback) {
    _onNotificationReceived = callback;
  }
}
