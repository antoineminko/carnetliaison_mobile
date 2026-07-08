import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
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
  

  await NotificationStorage.saveNotification({
    'title': message.notification?.title ?? 'Nouvelle notification',
    'body': message.notification?.body ?? '',
    'data': message.data,
  });
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
      print('?? [FirebaseService] Notification foreground : ${message.notification?.title}');
      _localNotificationService.showNotification(message);
      
      // Sauvegarder la notification
      await NotificationStorage.saveNotification({
        'title': message.notification?.title ?? 'Nouvelle notification',
        'body': message.notification?.body ?? '',
        'data': message.data,
      });
      
      // Notifier l'app du nouveau message
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

  /// Redirige l'utilisateur vers la bonne page selon le type de notification
  void _handleNotificationTap(Map<String, dynamic> data) {
    final String? type = data['type'];
    final context = navigatorKey.currentContext;
    if (context == null) return;

    switch (type) {
      case 'general':
      case 'info':
        // Ouvrir directement la modale des notifications
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/parent/home',
          (route) => false,
          arguments: {'openNotifications': true},
        );
        break;
      case 'attendance_alert': // Appel présence/absence enseignant
      case 'absence': // alias legacy
      case 'retard':
        final String? childName = data['child_name'];
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/parent/home',
          (route) => false,
          arguments: {
            'initialTab': 0, // Accueil / Mes enfants
            'selectChildName': childName,
            'childInitialTab': 0, // Onglet Aperçu dans ChildDetailsView
          },
        );
        break;
      case 'appointment_request':
      case 'appointment_accepted':
      case 'appointment_refused':
      case 'appointment_postponed':
      case 'appointment_cancelled':
        // Rediriger vers la page des événements avec l'ID du rendez-vous
        final String? appointmentId = data['appointment_id'];
        final String? statut = data['statut'];
        final bool isPostponed = data['type'] == 'appointment_postponed' || statut == 'reporte';

        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/parent/home',
          (route) => false,
          arguments: {
            'initialTab': 0, // Accueil
            'openAppointments': true, // Ouvrir la page des rendez-vous
            'highlightAppointmentId': appointmentId != null ? int.tryParse(appointmentId) : null,
            'appointmentStatus': statut,
            'isPostponed': isPostponed,
          },
        );
        break;
      case 'new_homework':
      case 'new_grade':
        final String? childName = data['eleve_nom'];
        final String? eleveId = data['eleve_id'];
        final String? devoirId = data['devoir_id'];
        final String? enseignantNom = data['enseignant_nom'];
        final String? matiere = data['matiere'];
        final String? typeDevoir = data['type_devoir'] ?? data['type'];

        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/parent/home',
          (route) => false,
          arguments: {
            'initialTab': 0, // Accueil / Mes enfants
            'openNotifications': true, // Ouvrir la modal notifications
            'notificationPayload': {
              'type': 'new_homework',
              'title': 'Nouvelle évaluation',
              'body': 'Une nouvelle note ou un nouveau devoir a été publié.',
              'child_name': childName,
              'eleve_id': eleveId,
              'devoir_id': devoirId,
              'enseignant_nom': enseignantNom,
              'matiere': matiere,
              'type_devoir': typeDevoir,
            },
          },
        );
        break;
      case 'admin_message':
      case 'teacher_message':
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/parent/home',
          (route) => false,
          arguments: {
            'initialTab': 1, // 1 is Messages tab!
            'openConversationId': data['conversation_id'],
          },
        );
        break;
      case 'parent_message':
        // Message d'un parent - rediriger l'enseignant vers le chat
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/teacher/home',
          (route) => false,
          arguments: {
            'openChat': true,
            'conversationId': data['conversation_id'],
          },
        );
        break;
      case 'new_conversation_request':
        // Nouvelle demande de conversation (premier message)
        // Rediriger vers la messagerie avec une indication pour valider la liaison
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/parent/home',
          (route) => false,
          arguments: {
            'initialTab': 1, // Messages tab
            'openConversationId': data['conversation_id'],
            'showConversationValidation': true, // Afficher la modal de validation
            'conversationStatus': data['status'], // 'pending', 'accepted', etc.
            'enseignant_nom': data['enseignant_nom'],
            'subject': data['subject'],
          },
        );
        break;
      case 'chat_accepted':
        // Conversation acceptée - rediriger vers le chat
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/parent/home',
          (route) => false,
          arguments: {
            'initialTab': 1, // Messages tab
            'openConversationId': data['conversation_id'],
            'conversationStatus': 'accepted',
          },
        );
        break;
      case 'chat_rejected':
        // Conversation refusée - afficher une notification/bannière
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/parent/home',
          (route) => false,
          arguments: {
            'initialTab': 1, // Messages tab
            'showRejectionNotification': true,
            'conversationId': data['conversation_id'],
          },
        );
        break;
      case 'incoming_call':
        // Appel entrant - afficher l'écran d'appel entrant
        final String? callId = data['call_id'];
        final String? callType = data['call_type'] ?? 'audio';
        final String? conversationId = data['conversation_id'];
        final String callerName = data['caller_name'] ?? 'Appel entrant';

        print('?? [FirebaseService] Appel entrant - callId: $callId, type: $callType');

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
        break;
      case 'call_rejected':
        // Appel rejeté - afficher notification
        if (navigatorKey.currentContext != null) {
          ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
            const SnackBar(
              content: Text('? Appel rejeté'),
              backgroundColor: Colors.red,
            ),
          );
        }
        break;
      case 'call_missed':
        // Appel manqué - afficher notification
        if (navigatorKey.currentContext != null) {
          ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
            const SnackBar(
              content: Text('?? Appel manqué'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        break;
      case 'incident':
        // Incident signalé par un enseignant
        // 1. Ouvrir l'accueil avec la modal des notifications
        // 2. Le parent verra une bannière dans les notifications
        // 3. En cliquant sur la bannière, il ira dans Infos de l'enfant
        final String? childName = data['child_name'];
        final String? incidentType = data['incident_type'];
        final String? incidentId = data['incident_id'];
        final String? enseignantNom = data['enseignant_nom'];
        final String? matiere = data['matiere'];
        
        // Construire le body pour la bannière
        final String bodyText = childName != null && incidentType != null
            ? '$childName - ${incidentType.toUpperCase()}'
            : 'Nouvel incident signalé';
        
        print('?? [FirebaseService] Navigation incident - childName: $childName, incidentType: $incidentType');
        print('?? [FirebaseService] Body text: $bodyText');
        
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/parent/home',
          (route) => false,
          arguments: {
            'initialTab': 0, // Accueil / Mes enfants
            'openNotifications': true, // Ouvrir la modal notifications
            'notificationPayload': {
              'type': 'incident',
              'title': 'Incident signalé',
              'body': bodyText,
              'child_name': childName,
              'incident_id': incidentId,
              'incident_type': incidentType,
              'enseignant_nom': enseignantNom,
              'matiere': matiere,
            },
          },
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
    print('?? [FirebaseService] Statut permission : ${settings.authorizationStatus}');
  }

  Future<String?> getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      print('?? [FirebaseService] FCM Token : $token');

      if (token != null) {
        final parentId = await AuthService.getParentId();
        if (parentId != null) {
          await ApiClient.instance.post('/notifications/register-token', data: {
            'parent_id': parentId,
            'token': token,
            'platform': 'android',
          });
          print('? [FirebaseService] Token enregistré pour parent #$parentId');
        }
      }

      return token;
    } catch (e) {
      print('? [FirebaseService] Erreur récupération Token : $e');
      return null;
    }
  }
}

