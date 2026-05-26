import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'local_notification_service.dart';
import 'package:app_mobile/shared/config/api_client.dart';
import 'package:app_mobile/features/auth/services/auth_service.dart';

// Clé de navigation globale pour naviguer depuis les notifications
import 'package:flutter/material.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Top-level function for background messages handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('🔔 [FirebaseService] Notification background reçue : ${message.messageId}');
}

class FirebaseService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final LocalNotificationService _localNotificationService;

  FirebaseService(this._localNotificationService);

  Future<void> init() async {
    // 1. Request permissions
    await requestPermission();

    // 2. Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🔔 [FirebaseService] Notification foreground : ${message.notification?.title}');
      _localNotificationService.showNotification(message);
    });

    // 4. Clic sur notification quand l'app est en arrière-plan
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🔔 [FirebaseService] Clic sur notification background : ${message.notification?.title}');
      _handleNotificationTap(message.data);
    });

    // 5. App ouverte depuis une notification (état terminé)
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print('🔔 [FirebaseService] App ouverte via notification (Terminated)');
      // Petit délai pour laisser le temps au widget tree de se construire
      Future.delayed(const Duration(milliseconds: 500), () {
        _handleNotificationTap(initialMessage.data);
      });
    }

    // 6. Token FCM (sera ré-enregistré après le login de toute façon)
    await getFCMToken();
  }

  /// Redirige l'utilisateur vers la bonne page selon le type de notification
  void _handleNotificationTap(Map<String, dynamic> data) {
    final String? type = data['type'];
    final context = navigatorKey.currentContext;
    if (context == null) return;

    switch (type) {
      case 'admin_message':
        // Naviguer vers l'accueil parent (onglet Messages, index 1)
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/parent/home',
          (route) => false,
          arguments: {'initialTab': 1}, // tab "Messages"
        );
        break;
      case 'absence':
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/parent/home',
          (route) => false,
        );
        break;
      default:
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/parent/home',
          (route) => false,
        );
    }
  }

  Future<void> requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print('🔔 [FirebaseService] Statut permission : ${settings.authorizationStatus}');
  }

  Future<String?> getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      print('🔑 [FirebaseService] FCM Token : $token');

      if (token != null) {
        final parentId = await AuthService.getParentId();
        if (parentId != null) {
          await ApiClient.instance.post('/notifications/register-token', data: {
            'parent_id': parentId,
            'token': token,
            'platform': 'android',
          });
          print('✅ [FirebaseService] Token enregistré pour parent #$parentId');
        }
      }

      return token;
    } catch (e) {
      print('❌ [FirebaseService] Erreur récupération Token : $e');
      return null;
    }
  }
}
