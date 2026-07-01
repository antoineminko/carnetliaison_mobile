import 'package:flutter/material.dart';
import 'package:app_mobile/features/splash/pages/splash_screen_page.dart';
import 'package:app_mobile/features/auth/parent/pages/login_page.dart';
import 'package:app_mobile/features/auth/welcome/pages/welcome_page.dart';
import 'package:app_mobile/shared/utils/user_role.dart';
import 'package:app_mobile/features/parent/accueil/dashboard/parent_home_page.dart';
import 'package:app_mobile/features/teacher/pages/teacher_home.dart';
import 'package:app_mobile/features/student/pages/student_main_page.dart';
import 'package:app_mobile/features/parent/accueil/liaison/qr_scan_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreenPage());
      case '/select_role':
        return MaterialPageRoute(builder: (_) => const SelectRolePage());
      case '/login':
        final role = settings.arguments as UserRole;
        return MaterialPageRoute(
          builder: (_) => LoginPage(role: role),
        );
      case '/parent/home':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(builder: (_) => ParentHomePage(arguments: args));
      case '/parent/scan':
        return MaterialPageRoute(builder: (_) => const QrScanPage(isFromLogin: true));
      case '/teacher/home':
        return MaterialPageRoute(builder: (_) => const TeacherHomePage());
      case '/student/home':
        return MaterialPageRoute(builder: (_) => const StudentMainPage());
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child: Text('No route defined for ${settings.name}')),
                ));
    }
  }
}
