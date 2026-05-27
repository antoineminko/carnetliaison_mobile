import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/notifications/services/notifications_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize notifications
  await NotificationsService().init();

  runApp(const App());
}
