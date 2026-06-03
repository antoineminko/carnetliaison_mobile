import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_mobile/shared/config/api_client.dart';
import 'package:app_mobile/shared/utils/user_role.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();

    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    // Wait for the splash animation
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final parentId = prefs.getInt('parent_id');
    final teacherId = prefs.getInt('teacher_id');
    // Ce flag est positionné à true uniquement après un scan QR réussi
    // Il est effacé lors de la déconnexion explicite
    final parentScanDone = prefs.getBool('parent_scan_done') ?? false;

    String targetRoute = '/select_role';
    Object? arguments;

    if (parentId != null) {
      if (parentScanDone) {
        // Session active + scan déjà effectué → accès direct à l'accueil
        targetRoute = '/parent/home';
      } else {
        // Connecté mais scan non encore effectué → accueil avec empty state forcé
        targetRoute = '/parent/home';
        arguments = {'forceAddChild': true};
      }
    } else if (teacherId != null) {
      targetRoute = '/teacher/home';
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, targetRoute, arguments: arguments);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color brandBlueOverlay = Color(0xFF2596be);
    const Color darkBlueBottom = Color(
      0xFF114c61,
    ); // Version sombre du bleu pour un dégradé de haute qualité

    return Scaffold(
      backgroundColor: darkBlueBottom,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/parent.png'),
            fit: BoxFit.cover,
            opacity: 0.2, // Légèrement réduit pour plus de lisibilité
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [brandBlueOverlay.withOpacity(0.85), darkBlueBottom],
            ),
          ),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Central
                  Image.asset(
                    'assets/icons/schooly_logo.png',
                    width: 150,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 40),
                  // Spinner discret blanc pour plus d'élégance
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  ),
                  const SizedBox(height: 60),
                  // Welcome text
                  const Text(
                    'Carnet Liaison',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Serif',
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    'Academic Edition',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      fontStyle: FontStyle.italic,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
