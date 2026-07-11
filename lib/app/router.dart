import 'package:flutter/material.dart';
import 'package:app_mobile/features/splash/pages/splash_screen_page.dart';
import 'package:app_mobile/features/auth/teacher/login_page.dart';
import 'package:app_mobile/shared/utils/user_role.dart';
import 'package:app_mobile/features/teacher/accueil/accueil_page.dart';
import 'package:app_mobile/features/auth/teacher/teacher_schools_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreenPage());
      case '/teacher/schools':
        final teachersData = settings.arguments as List<dynamic>?;
        return MaterialPageRoute(
          builder: (_) => TeacherSchoolsPage(teachersData: teachersData ?? []),
        );
      case '/login':
        final role = settings.arguments as UserRole? ?? UserRole.teacher;
        return MaterialPageRoute(
          builder: (_) => LoginPage(role: role),
        );
      case '/teacher/home':
        return MaterialPageRoute(builder: (_) => const TeacherHomePage());
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                      child: Text('No route defined for ${settings.name}')),
                ));
    }
  }
}
