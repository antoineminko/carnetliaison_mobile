import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/features/auth/services/auth_service.dart';

class TeacherSchoolsPage extends StatelessWidget {
  final List<dynamic> teachersData;

  const TeacherSchoolsPage({
    super.key,
    required this.teachersData,
  });

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
                teachersData.isNotEmpty ? '${teachersData[0]['prenom']} ${teachersData[0]['nom']}' : 'Enseignant',
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
                  itemCount: teachersData.length,
                  itemBuilder: (context, index) {
                    final data = teachersData[index] as Map<String, dynamic>;
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
                                    'Accéder à votre espace',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
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
