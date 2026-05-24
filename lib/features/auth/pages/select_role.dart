import 'package:flutter/material.dart';
import 'package:app_mobile/shared/utils/user_role.dart';
import 'package:app_mobile/features/auth/pages/login.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/shared/widgets/background_wrapper.dart';

class SelectRolePage extends StatelessWidget {
  const SelectRolePage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color darkTealOverlay = AppTheme.forestGreen;
    final Color activeGreen = AppTheme.forestGreen;
    final Color inactiveIconColor =
        AppTheme.forestGreen; // Changé en Vert Forêt comme demandé
    final Color inactiveTextColor = AppTheme.textGrey;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BackgroundWrapper(
        isSubtle: false, // On affiche clairement le fond d'écran ici
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.45,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/parent.png'),
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            darkTealOverlay.withOpacity(0.60),
                            darkTealOverlay.withOpacity(0.85),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 24.0,
                              top: 10.0,
                            ),
                            child: Image.asset(
                              'assets/icons/schooly_logo.png',
                              height: 50,
                              fit: BoxFit.contain,
                            ),
                          ),
                          Text(
                            _getFormattedDate(),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Carnet Liaison',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              height: 1.1,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 4),
                                  blurRadius: 10,
                                  color: Colors.black26,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Transform.translate(
                offset: const Offset(0, -40),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _buildCard(
                              context,
                              title: 'Parents',
                              icon: Icons.family_restroom,
                              isActive: false,
                              activeColor: activeGreen,
                              inactiveIconColor: AppTheme.forestGreen,
                              inactiveTextColor: AppTheme.textGrey,
                              onTap: () =>
                                  _showLoginModal(context, UserRole.parent),
                              height: 180, // Hauteur réduite
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          children: [
                            _buildCard(
                              context,
                              title: 'Enseignants',
                              icon: Icons.school_outlined,
                              isActive: true,
                              activeColor: AppTheme.forestGreen,
                              inactiveIconColor: inactiveIconColor,
                              inactiveTextColor: inactiveTextColor,
                              onTap: () =>
                                  _showLoginModal(context, UserRole.teacher),
                              height: 180, // Hauteur réduite
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _showLoginModal(BuildContext context, UserRole role) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.90,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: LoginPage(role: role),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    required Color inactiveIconColor,
    required Color inactiveTextColor,
    required VoidCallback onTap,
    double height = 160, // Fixed height for scroll safety
  }) {
    return Material(
      color: isActive ? activeColor : Colors.white.withOpacity(0.85),
      borderRadius: BorderRadius.circular(28),
      shadowColor: const Color(0xFF2596be).withOpacity(0.2),
      elevation: isActive ? 8 : 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        splashColor: const Color(0xFF1a6f8f).withOpacity(0.3),
        highlightColor: const Color(0xFF1a6f8f).withOpacity(0.15),
        child: SizedBox(
          height: height,
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Center(
                  child: Icon(
                    icon,
                    size: 38,
                    color: isActive ? Colors.white : inactiveIconColor,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isActive ? Colors.white : inactiveTextColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isActive)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        width: 24,
                        height: 2,
                        color: Colors.white.withOpacity(0.6),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    final year = now.year;
    return '$day/$month/$year';
  }
}
