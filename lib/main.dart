import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'features/notifications/services/notifications_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize date formatting for French locale
  await initializeDateFormatting('fr_FR', null);
  
  // Initialize notifications
  await NotificationsService().init();

  runApp(const App());
}
