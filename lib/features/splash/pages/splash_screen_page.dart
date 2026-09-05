import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/utils/user_role.dart';

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
    final teacherId = prefs.getInt('teacher_id');
    final schoolCode = prefs.getString('school_code');
    final lastActivityTime = prefs.getInt('last_activity_time') ?? prefs.getInt('last_login_time');
    final rememberMe = prefs.getBool('remember_me') ?? false;

    // Vérification de la session : 24 heures maximum d'inactivité
    bool sessionValid = false;
    if (teacherId != null && schoolCode != null && schoolCode.isNotEmpty) {
      if (lastActivityTime != null) {
        final sessionAge = DateTime.now().millisecondsSinceEpoch - lastActivityTime;
        const sessionMaxMs = 24 * 60 * 60 * 1000; // 24 heures
        sessionValid = rememberMe && (sessionAge < sessionMaxMs);
      } else {
        // First launch or no activity time yet
        sessionValid = true;
      }

      if (!sessionValid) {
        // Session expirée → nettoyage
        await prefs.remove('teacher_id');
        await prefs.remove('school_code');
      }
    }

    if (sessionValid) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/teacher/home');
      }
    } else {
      // Non connecté ou session expirée → page de connexion
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login', arguments: UserRole.teacher);
      }
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
    ); // Version sombre du bleu pour un dÃ©gradÃ© de haute qualitÃ©

    return Scaffold(
      backgroundColor: darkBlueBottom,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/parent.png'),
            fit: BoxFit.cover,
            opacity: 0.2, // LÃ©gÃ¨rement rÃ©duit pour plus de lisibilitÃ©
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
                  // Spinner discret blanc pour plus d'Ã©lÃ©gance
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
