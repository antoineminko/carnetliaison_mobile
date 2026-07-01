import 'package:flutter/material.dart';
import 'package:app_mobile/features/auth/parent/services/parent_auth_service.dart';
import 'package:app_mobile/shared/utils/user_role.dart';
import 'package:app_mobile/features/auth/parent/pages/create_account_page.dart';
import 'package:app_mobile/features/parent/accueil/liaison/qr_scan_page.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/shared/widgets/background_wrapper.dart';

class LoginPage extends StatefulWidget {
  final UserRole role;

  const LoginPage({super.key, required this.role});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final AuthService _authService = AuthService();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _animationController, curve: Curves.easeOutQuint));
    _fadeAnimation = CurvedAnimation(
        parent: _animationController, curve: Curves.easeIn);
    
    // Start animation after a slight delay to let Hero finish
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _animationController.forward();
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // DEMO: Bypass login for Student role
    if (widget.role == UserRole.student) {
      _navigateHome();
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final result = await _authService.login(
        role: widget.role,
        username: _usernameController.text,
        password: _passwordController.text,
      );

      setState(() => _isLoading = false);

      if (mounted) {
        _handleAuthResult(result, isScanFlow: false);
      }
    }
  }

  void _handleAuthResult(AuthResult result, {bool isScanFlow = false, String? qrCode}) {
    switch (result) {
      case AuthResult.success:
        _navigateHome();
        break;
      case AuthResult.invalidCredentials:
         ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Identifiants incorrects')),
          );
        break;
      case AuthResult.userNotFound:
        _showAccountCreationDialog(
          email: _usernameController.text, 
          isScanFlow: isScanFlow,
          qrCode: qrCode
        );
        break;
    }
  }

  void _showAccountCreationDialog({required String email, required bool isScanFlow, String? qrCode}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Compte introuvable'),
        content: Text(
          isScanFlow 
          ? 'Aucun compte parent n\'est lié à cet identifiant pour cet enfant. Voulez-vous créer un compte ?'
          : 'Cet identifiant ne correspond à aucun compte. Voulez-vous le créer ?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Non'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => 
                  CreateAccountPage(email: email, childQrCode: qrCode))
              );
            },
            child: const Text('Créer un compte'),
          ),
        ],
      ),
    );
  }


  void _navigateHome() {
    switch (widget.role) {
      case UserRole.parent:
        Navigator.pushReplacementNamed(
          context,
          '/parent/home',
          arguments: {'forceAddChild': true},
        );
        break;
      case UserRole.teacher:
        Navigator.pushReplacementNamed(context, '/teacher/home');
        break;
      case UserRole.student:
        Navigator.pushReplacementNamed(context, '/student/home');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = AppTheme.loginBackground;
    final Color inputFill = const Color(0xFFE6E9EF);
    final Color darkText = AppTheme.textDark;
    final Color buttonColor = AppTheme.forestGreen;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackgroundWrapper(
        isSubtle: false,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: bgColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          const BoxShadow(color: Colors.white, offset: Offset(-5, -5), blurRadius: 10),
                          BoxShadow(color: Colors.black.withOpacity(0.1), offset: const Offset(5, 5), blurRadius: 10),
                        ],
                      ),
                      child: Icon(widget.role.icon, size: 50, color: darkText),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      widget.role.label,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkText, letterSpacing: 0.5),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 8),
                    child: Text('Identifiant', style: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: inputFill,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        const BoxShadow(color: Colors.white, offset: Offset(-2, -2), blurRadius: 5),
                        BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(2, 2), blurRadius: 5, blurStyle: BlurStyle.inner),
                      ],
                    ),
                    child: TextFormField(
                      controller: _usernameController,
                      style: TextStyle(color: darkText),
                      decoration: InputDecoration(
                        hintText: 'Email ou numéro de téléphone',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        prefixIcon: Icon(Icons.person, color: Colors.grey[500]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 8),
                    child: Text('Mot de passe', style: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: inputFill,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        const BoxShadow(color: Colors.white, offset: Offset(-2, -2), blurRadius: 5),
                        BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(2, 2), blurRadius: 5, blurStyle: BlurStyle.inner),
                      ],
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: TextStyle(color: darkText),
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        prefixIcon: Icon(Icons.lock, color: Colors.grey[500]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(color: buttonColor.withOpacity(0.4), offset: const Offset(0, 10), blurRadius: 20),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: _isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Se connecter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
