import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/shared/config/school_config.dart';
import 'package:app_mobile/features/auth/services/auth_service.dart';

class TeacherProfilePage extends StatefulWidget {
  const TeacherProfilePage({super.key});

  @override
  State<TeacherProfilePage> createState() => _TeacherProfilePageState();
}

class _TeacherProfilePageState extends State<TeacherProfilePage> {
  bool _notifPush = true;
  bool _notifSms = false;
  bool _notifEmail = true;

  String? _teacherFirstName;
  String? _teacherLastName;
  String? _teacherEmail;
  String? _teacherPhone;
  String? _teacherMatiere;

  @override
  void initState() {
    super.initState();
    _loadTeacherProfile();
  }

  Future<void> _loadTeacherProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _teacherFirstName = prefs.getString('teacher_prenom') ?? prefs.getString('enseignant_prenom');
      _teacherLastName = prefs.getString('teacher_nom') ?? prefs.getString('enseignant_nom');
      _teacherEmail = prefs.getString('teacher_email') ?? prefs.getString('enseignant_email');
      _teacherPhone = prefs.getString('teacher_telephone') ?? prefs.getString('enseignant_telephone');
      _teacherMatiere = prefs.getString('teacher_matiere') ?? prefs.getString('enseignant_matiere');
    });
  }

  String get _initials {
    final f = (_teacherFirstName ?? '').isNotEmpty ? _teacherFirstName![0].toUpperCase() : '';
    final l = (_teacherLastName ?? '').isNotEmpty ? _teacherLastName![0].toUpperCase() : '';
    final result = '$f$l';
    return result.isNotEmpty ? result : 'E';
  }

  String get _fullName {
    final full = '${_teacherFirstName ?? ''} ${_teacherLastName ?? ''}'.trim();
    return full.isNotEmpty ? full : 'Votre profil';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Centré
          Center(
            child: Column(
              children: [
                // Avatar avec initiales (pas de photo)
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppTheme.forestGreen, AppTheme.forestGreen.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.forestGreen.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  _fullName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
                ),
                const SizedBox(height: 5),
                Text(
                  (_teacherMatiere != null && _teacherMatiere!.isNotEmpty)
                      ? 'Enseignant - $_teacherMatiere'
                      : 'Enseignant',
                  style: const TextStyle(fontSize: 14, color: AppTheme.textGrey, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // SECTION MES INFORMATIONS
          _buildSectionTitle('MES INFORMATIONS'),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
            ),
            child: Column(
              children: [
                _buildInfoTile(
                  Icons.email_outlined,
                  'EMAIL',
                  (_teacherEmail != null && _teacherEmail!.isNotEmpty) ? _teacherEmail! : 'Non renseigné',
                ),
                const Divider(height: 1, indent: 50),
                _buildInfoTile(
                  Icons.phone_outlined,
                  'TÉLÉPHONE',
                  (_teacherPhone != null && _teacherPhone!.isNotEmpty) ? _teacherPhone! : 'Non renseigné',
                ),
                const Divider(height: 1, indent: 50),
                _buildInfoTile(
                  Icons.school_outlined,
                  'MATIÈRE',
                  (_teacherMatiere != null && _teacherMatiere!.isNotEmpty) ? _teacherMatiere! : 'Non renseigné',
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // SECTION PREFERENCES
          _buildSectionTitle('PRÉFÉRENCES'),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
            ),
            child: Column(
              children: [
                _buildSwitchTile('Notifications Push', Icons.notifications_none, _notifPush, (v) => setState(() => _notifPush = v)),
                const Divider(height: 1, indent: 50),
                _buildSwitchTile('Alertes par SMS', Icons.sms_outlined, _notifSms, (v) => setState(() => _notifSms = v)),
                const Divider(height: 1, indent: 50),
                _buildSwitchTile('Email', Icons.alternate_email, _notifEmail, (v) => setState(() => _notifEmail = v)),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // BOUTONS BAS DE PAGE
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
            ),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.lock_outline, color: AppTheme.seaBlue),
                ),
                title: const Text('Changer le mot de passe', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppTheme.textGrey),
                onTap: () {},
              ),
            ),
          ),
          
          const SizedBox(height: 15),
          
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.withOpacity(0.1)),
              boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.02), blurRadius: 10)],
            ),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.logout_rounded, color: Colors.red),
                ),
                title: const Text('Se déconnecter', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.red)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.redAccent),
                onTap: () async {
                  await AuthService.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 5),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.seaBlue, 
          fontWeight: FontWeight.bold, 
          fontSize: 13, 
          letterSpacing: 1.0
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.seaBlue.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: AppTheme.seaBlue, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppTheme.textGrey, fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppTheme.textDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, IconData icon, bool value, Function(bool) onChanged) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(icon, color: AppTheme.seaBlue),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.forestGreen,
      ),
    );
  }
}
