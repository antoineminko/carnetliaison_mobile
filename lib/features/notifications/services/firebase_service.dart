import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'local_notification_service.dart';
import 'notification_storage.dart';
import 'package:app_mobile/shared/config/api_client.dart';
import 'package:app_mobile/features/auth/services/auth_service.dart';
import 'package:app_mobile/features/calls/pages/incoming_call_screen.dart';

// Clé de navigation globale pour naviguer depuis les notifications
import 'package:flutter/material.dart';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('?? [FirebaseService] Notification background reçue : ${message.messageId}');
  

  final type = message.data['type'];
  const _noStoreTypes = [
    'new_conversation_request',
    'incoming_call',
    'call_missed',
    'call_rejected',
    'parent_message',
    'admin_message',
  ];
  if (!_noStoreTypes.contains(type)) {
    await NotificationStorage.saveNotification({
      'title': message.notification?.title ?? 'Nouvelle notification',
      'body': message.notification?.body ?? '',
      'data': message.data,
    });
  }
}

class FirebaseService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final LocalNotificationService _localNotificationService;
  VoidCallback? onNotificationReceived;

  FirebaseService(this._localNotificationService, {this.onNotificationReceived});

  Future<void> init() async {
   
    await requestPermission();


    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('📩 [FirebaseService] Notification foreground : ${message.notification?.title}');
      final type = message.data['type'];

      // Appel entrant en foreground : vérifier la règle des 60 minutes
      if (type == 'incoming_call') {
        final lastLoginStr = await AuthService.getLastLoginTime();
        if (lastLoginStr != null) {
          final lastLogin = DateTime.parse(lastLoginStr);
          if (DateTime.now().difference(lastLogin).inMinutes < 60) {
            _handleNotificationTap(message.data);
            return;
          } else {
            print('⚠️ [FirebaseService] Appel ignoré : session > 60 minutes');
            // Mettre à jour le badge sans ouvrir l'appel
            onNotificationReceived?.call();
            return;
          }
        } else {
            // Aucun contexte actif, ignorer
            onNotificationReceived?.call();
            return;
        }
      }

      _localNotificationService.showNotification(message);

      // Ne pas stocker localement les messages (push only + badge navbar)
      const noStoreTypes = [
        'new_conversation_request',
        'incoming_call',
        'call_missed',
        'call_rejected',
        'parent_message',
        'admin_message',
      ];
      if (!noStoreTypes.contains(type)) {
        await NotificationStorage.saveNotification({
          'title': message.notification?.title ?? 'Nouvelle notification',
          'body': message.notification?.body ?? '',
          'data': message.data,
        });
      }

      // Notifier l'app du nouveau message (refresh badge)
      onNotificationReceived?.call();
    });

    // 4. Clic sur notification quand l'app est en arrière-plan
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('?? [FirebaseService] Clic sur notification background : ${message.notification?.title}');
      print('?? [FirebaseService] Data reçue: ${message.data}');
      print('?? [FirebaseService] Type: ${message.data['type']}');
      _handleNotificationTap(message.data);
    });

    // 5. App ouverte depuis une notification (état terminé)
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print('? [FirebaseService] App ouverte via notification (Terminated)');
      // Délai pour laisser le splash screen (2500ms) se terminer avant de naviguer
      Future.delayed(const Duration(milliseconds: 3000), () {
        _handleNotificationTap(initialMessage.data);
      });
    }

    // 6. Token FCM (sera ré-enregistré après le login de toute façon)
    await getFCMToken();
  }

  /// Redirige l'utilisateur (enseignant) vers la bonne page selon le type de notification
  void _handleNotificationTap(Map<String, dynamic> data) {
    final String? type = data['type'];
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final sentAtStr = data['sent_at'];
    bool isExpired = false;
    if (sentAtStr != null) {
      final sentAt = int.tryParse(sentAtStr.toString());
      if (sentAt != null) {
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        if (now - sentAt > 3600) {
          isExpired = true;
        }
      }
    }

    switch (type) {
      case 'general':
      case 'info':
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/teacher/home',
          (route) => false,
        );
        break;

      case 'appointment_request':
      case 'appointment_accepted':
      case 'appointment_refused':
      case 'appointment_postponed':
      case 'appointment_cancelled':
        _checkAppointmentContextAndNavigate(data, isExpired);
        break;

      case 'new_conversation_request':
      case 'parent_message':
      case 'admin_message':
        // Message d'un parent ou d'un admin → onglet Messages de l'enseignant
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/teacher/home',
          (route) => false,
          arguments: isExpired ? null : {
            'initialTab': 1,
            'openChat': true,
            'openConversationId': data['conversation_id'],
            'conversationStatus': data['status'],
          },
        );
        break;

      case 'chat_accepted':
        // Le parent a accepté la discussion → onglet Messages
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/teacher/home',
          (route) => false,
          arguments: isExpired ? null : {
            'initialTab': 1,
            'openConversationId': data['conversation_id'],
            'conversationStatus': 'accepted',
          },
        );
        break;

      case 'chat_rejected':
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/teacher/home',
          (route) => false,
          arguments: isExpired ? null : {
            'initialTab': 1,
            'showRejectionNotification': true,
            'conversationId': data['conversation_id'],
          },
        );
        break;

      case 'incoming_call':
        // Vérifier si la session a expiré (règle des 60 minutes)
        bool sessionExpired = false;
        AuthService.getLastLoginTime().then((lastLoginStr) {
          if (lastLoginStr != null) {
            final lastLogin = DateTime.parse(lastLoginStr);
            if (DateTime.now().difference(lastLogin).inMinutes >= 60) {
              sessionExpired = true;
            }
          } else {
             sessionExpired = true;
          }

          if (sessionExpired || isExpired) {
            print('⚠️ [FirebaseService] Appel tapé ignoré : session > 60 minutes ou notif expirée');
            navigatorKey.currentState?.pushNamedAndRemoveUntil(
              '/teacher/home',
              (route) => false,
              arguments: {
                'initialTab': 1, // Onglet Messagerie
                'openCallsTab': true, // On demandera d'ouvrir l'onglet Appels
              },
            );
            return;
          }

          // Appel entrant — afficher l'écran plein écran IncomingCallScreen
          final String? callId = data['call_id'];
          final String? callType = data['call_type'] ?? 'audio';
          final String? conversationId = data['conversation_id'];
          final String callerName = data['caller_name'] ?? 'Appel entrant';
          print('📞 [FirebaseService] Appel entrant - callId: $callId, type: $callType');
          if (callId != null && navigatorKey.currentContext != null) {
            Navigator.push(
              navigatorKey.currentContext!,
              MaterialPageRoute(
                builder: (context) => IncomingCallScreen(
                  callId: int.parse(callId),
                  callType: callType!,
                  callerName: callerName,
                  conversationId: int.parse(conversationId ?? '0'),
                  callData: data,
                ),
              ),
            );
          }
        });
        break;

      case 'call_rejected':
        if (navigatorKey.currentContext != null) {
          ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
            const SnackBar(
              content: Text('❌ Appel rejeté'),
              backgroundColor: Colors.red,
            ),
          );
        }
        break;

      case 'call_missed':
        if (navigatorKey.currentContext != null) {
          ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
            const SnackBar(
              content: Text('📵 Appel manqué'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        break;

      default:
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/teacher/home',
          (route) => false,
        );
    }
  }

  void _checkAppointmentContextAndNavigate(Map<String, dynamic> data, bool isExpired) async {
    final String? appointmentId = data['appointment_id'];
    final String? statut = data['statut'];
    final String? notifEcoleId = data['ecole_id']?.toString();

    // Vérifier la session (60 minutes)
    bool sessionExpired = false;
    final lastLoginStr = await AuthService.getLastLoginTime();
    if (lastLoginStr != null) {
      final lastLogin = DateTime.parse(lastLoginStr);
      if (DateTime.now().difference(lastLogin).inMinutes >= 60) {
        sessionExpired = true;
      }
    } else {
      sessionExpired = true;
    }

    // Vérifier le contexte école
    bool contextMatch = true;
    if (notifEcoleId != null) {
      final prefs = await SharedPreferences.getInstance();
      final activeEcoleId = prefs.getString('active_ecole_id') ?? prefs.getInt('active_ecole_id')?.toString();
      if (activeEcoleId != notifEcoleId) {
        contextMatch = false;
      }
    }

    if (sessionExpired || isExpired || !contextMatch) {
      print('⚠️ [FirebaseService] Rendez-vous tapé ignoré : session expirée, notif expirée ou mauvais contexte école');
      // On se contente d'actualiser la pastille (si l'utilisateur se connecte dans la bonne école plus tard, la pastille apparaîtra)
      onNotificationReceived?.call();
      return;
    }

    // Tout est valide : navigation vers l'onglet événements
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/teacher/home',
      (route) => false,
      arguments: {
        'initialTab': 2, // Événements
        'openAppointments': true,
        'highlightAppointmentId': appointmentId != null ? int.tryParse(appointmentId) : null,
        'appointmentStatus': statut,
      },
    );
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
    print('?? [FirebaseService] Statut permission : ${settings.authorizationStatus}');
  }

  Future<String?> getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      print('🔑 [FirebaseService] FCM Token enseignant : $token');

      if (token != null) {
        // ✅ Enregistrer avec l'ID enseignant (et non parent — bug corrigé)
        final teacherId = await AuthService.getTeacherId();
        if (teacherId != null) {
          await ApiClient.instance.post('/notifications/register-token', data: {
            'teacher_id': teacherId,
            'token': token,
            'platform': 'android',
          });
          print('✅ [FirebaseService] Token FCM enregistré pour enseignant #$teacherId');
        }
      }

      return token;
    } catch (e) {
      print('❌ [FirebaseService] Erreur récupération Token : $e');
      return null;
    }
  }
}

