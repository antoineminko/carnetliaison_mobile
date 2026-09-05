import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/features/auth/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_mobile/features/notifications/services/notifications_service.dart';

class TeacherSchoolsPage extends StatefulWidget {
  final List<dynamic> teachersData;

  const TeacherSchoolsPage({
    super.key,
    required this.teachersData,
  });

  @override
  State<TeacherSchoolsPage> createState() => _TeacherSchoolsPageState();
}

class _TeacherSchoolsPageState extends State<TeacherSchoolsPage> {
  final Map<String, String> _pendingNotifications = {};

  @override
  void initState() {
    super.initState();
    _loadPendingNotifications();
    NotificationsService().setOnNotificationReceived(() {
      _loadPendingNotifications();
    });
  }

  @override
  void dispose() {
    NotificationsService().setOnNotificationReceived(() {});
    super.dispose();
  }

  Future<void> _loadPendingNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, String> loaded = {};
    
    for (final data in widget.teachersData) {
      final ecole = data['ecole'] ?? {};
      final ecoleId = ecole['id']?.toString();
      if (ecoleId != null) {
        final notifInfo = prefs.getString('pending_notif_ecole_$ecoleId');
        if (notifInfo != null) {
          loaded[ecoleId] = notifInfo;
        }
      }
    }
    
    if (mounted) {
      setState(() {
        _pendingNotifications.clear();
        _pendingNotifications.addAll(loaded);
      });
    }
  }

  void _selectSchool(BuildContext context, Map<String, dynamic> teacherData) async {
    // Afficher un indicateur de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppTheme.seaBlue),
      ),
    );

    // Enregistrer le profil et le contexte de l'école
    await AuthService.setTeacherProfile(teacherData);

    // Effacer la notification pour cette école si elle existe
    final ecole = teacherData['ecole'] ?? {};
    final ecoleId = ecole['id']?.toString();
    if (ecoleId != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('pending_notif_ecole_$ecoleId');
    }

    // Fermer le dialog et naviguer vers l'accueil
    if (context.mounted) {
      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, '/teacher/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Mes Établissements',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Bienvenue,',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textGrey,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                widget.teachersData.isNotEmpty ? '${widget.teachersData[0]['prenom']} ${widget.teachersData[0]['nom']}' : 'Enseignant',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Sélectionnez un établissement pour commencer :',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.teachersData.length,
                  itemBuilder: (context, index) {
                    final data = widget.teachersData[index] as Map<String, dynamic>;
                    final ecole = data['ecole'] ?? {};
                    final ecoleNom = ecole['nom'] ?? 'Établissement inconnu';
                    // S'il n'y a pas de logo de l'API, on utilise le style de base
                    final code = ecole['code'] ?? 'inconnu';
                    
                    return GestureDetector(
                      onTap: () => _selectSchool(context, data),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppTheme.seaBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.account_balance,
                                  color: AppTheme.seaBlue,
                                  size: 30,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ecoleNom,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    _pendingNotifications.containsKey(ecole['id']?.toString()) 
                                        ? 'Nouveau message : ${_pendingNotifications[ecole['id']?.toString()]}'
                                        : 'Accéder à votre espace',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: _pendingNotifications.containsKey(ecole['id']?.toString()) 
                                          ? Colors.redAccent 
                                          : Colors.grey[600],
                                      fontWeight: _pendingNotifications.containsKey(ecole['id']?.toString())
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_pendingNotifications.containsKey(ecole['id']?.toString()))
                              Container(
                                width: 12,
                                height: 12,
                                margin: const EdgeInsets.only(right: 15),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: AppTheme.seaBlue,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
