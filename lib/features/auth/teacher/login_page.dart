import 'package:flutter/material.dart';
import 'package:app_mobile/features/auth/services/auth_service.dart';
import 'package:app_mobile/shared/utils/user_role.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/shared/widgets/background_wrapper.dart';

class LoginPage extends StatefulWidget {
  final UserRole role;

  const LoginPage({super.key, required this.role});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  final AuthService _authService = AuthService();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

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

      final response = await _authService.login(
        role: widget.role,
        username: _usernameController.text,
        password: _passwordController.text,
        rememberMe: _rememberMe,
      );

      setState(() => _isLoading = false);

      if (mounted) {
        _handleAuthResult(response, isScanFlow: false);
      }
    }
  }

  void _handleAuthResult(
    AuthResponse response, {
    bool isScanFlow = false,
    String? qrCode,
  }) {
    switch (response.result) {
      case AuthResult.success:
        if (widget.role == UserRole.teacher && response.teachersData != null) {
          Navigator.pushReplacementNamed(
            context,
            '/teacher/schools',
            arguments: response.teachersData,
          );
        } else {
          _navigateHome();
        }
        break;
      case AuthResult.invalidCredentials:
        _showErrorModal(
          title: 'Erreur de connexion',
          message: 'Identifiants incorrects. Veuillez réessayer.',
          icon: Icons.lock_outline,
        );
        break;
      case AuthResult.networkError:
        _showErrorModal(
          title: 'Problème réseau',
          message: 'Impossible de joindre le serveur. Vérifiez votre connexion internet.',
          icon: Icons.wifi_off_rounded,
        );
        break;
      case AuthResult.userNotFound:
        _showAccountCreationDialog(
          email: _usernameController.text,
          isScanFlow: isScanFlow,
          qrCode: qrCode,
        );
        break;
    }
  }

  void _showErrorModal({required String title, required String message, required IconData icon}) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.redAccent, size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textGrey,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.seaBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Réessayer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAccountCreationDialog({
    required String email,
    required bool isScanFlow,
    String? qrCode,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Compte introuvable'),
        content: Text(
          isScanFlow
              ? 'Aucun compte parent n\'est lié à cet identifiant pour cet enfant. Voulez-vous créer un compte ?'
              : 'Cet identifiant ne correspond à aucun compte. Voulez-vous le créer ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Non'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // Account creation for parents removed in School version
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'La création de compte parent n\'est pas disponible dans cette version.',
                  ),
                ),
              );
            },
            child: const Text('Créer un compte'),
          ),
        ],
      ),
    );
  }

  void _navigateHome() {
    Navigator.pushReplacementNamed(context, '/teacher/home');
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
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
                          const BoxShadow(
                            color: Colors.white,
                            offset: Offset(-5, -5),
                            blurRadius: 10,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(5, 5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(widget.role.icon, size: 50, color: darkText),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      widget.role.label,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 8),
                    child: Text(
                      'Identifiant',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: inputFill,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        const BoxShadow(
                          color: Colors.white,
                          offset: Offset(-2, -2),
                          blurRadius: 5,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(2, 2),
                          blurRadius: 5,
                          blurStyle: BlurStyle.inner,
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _usernameController,
                      style: TextStyle(color: darkText),
                      decoration: InputDecoration(
                        hintText: 'Email ou numéro de téléphone',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        prefixIcon: Icon(Icons.person, color: Colors.grey[500]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 8),
                    child: Text(
                      'Mot de passe',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: inputFill,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        const BoxShadow(
                          color: Colors.white,
                          offset: Offset(-2, -2),
                          blurRadius: 5,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(2, 2),
                          blurRadius: 5,
                          blurStyle: BlurStyle.inner,
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: TextStyle(color: darkText),
                      decoration: InputDecoration(
                        hintText: '••••••••',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        prefixIcon: Icon(Icons.lock, color: Colors.grey[500]),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey[500],
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                          activeColor: AppTheme.seaBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Se souvenir de moi (pendant 15 minutes)',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_rememberMe) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Si vous quittez l\'application, vous n\'aurez pas besoin de vous reconnecter si vous revenez dans les 15 minutes.',
                      style: TextStyle(color: Colors.grey[500], fontSize: 11, fontStyle: FontStyle.italic),
                    ),
                  ],
                  const SizedBox(height: 30),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: buttonColor.withOpacity(0.4),
                          offset: const Offset(0, 10),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Se connecter',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}
