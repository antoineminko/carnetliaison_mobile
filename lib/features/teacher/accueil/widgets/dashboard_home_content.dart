import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/features/teacher/accueil/viewmodels/accueil_viewmodel.dart';
import 'package:app_mobile/features/teacher/accueil/widgets/teacher_classes_list.dart';
import 'package:app_mobile/features/teacher/accueil/widgets/priority_card.dart';
import 'package:app_mobile/features/teacher/accueil/widgets/promo_banner.dart';
import 'package:app_mobile/features/teacher/accueil/devoirs/create_homework_page.dart';
import 'package:app_mobile/features/teacher/espace_classe/textbook/textbook_view.dart';

class DashboardHomeContent extends StatelessWidget {
  final VoidCallback onShowNotifications;

  const DashboardHomeContent({
    super.key,
    required this.onShowNotifications,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AccueilViewModel>();

    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final teacher = viewModel.dashboardData?['teacher'] ?? {};
    final classes = (viewModel.dashboardData?['classes'] as List?) ?? [];

    final nom = teacher['nom'] ?? '';
    final matiere = teacher['matiere'] ?? 'Professeur';
    final premierClasse = classes.isNotEmpty ? classes[0] : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '👋 Bonjour M. $nom',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      matiere,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.seaBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.seaBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        premierClasse != null ? (premierClasse['ecole_nom'] ?? 'Établissement') : 'Vos classes',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.seaBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: AppTheme.seaBlue, size: 28),
                    onPressed: onShowNotifications,
                  ),
                  if (viewModel.appointments.where((a) => a['statut'] == 'en_attente').isNotEmpty)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Text('!', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.forestGreen.withOpacity(0.2),
                    width: 2,
                  ),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/teacher.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          if (classes.isEmpty)
            const Center(child: Text('Aucune classe assignée'))
          else
            TeacherClassesList(
              classes: classes,
              matiere: matiere,
              teacherId: viewModel.teacherId ?? 1,
            ),
          const SizedBox(height: 30),
          const Text(
            'Priorités du jour',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 15),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.1,
            children: [
              PriorityCard(
                title: 'Publier devoir',
                subtitle: 'Gérer les devoirs',
                icon: Icons.upload_file,
                color: AppTheme.seaBlue,
                isUrgent: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateHomeworkPage(),
                    ),
                  );
                },
              ),
              PriorityCard(
                title: 'Messages',
                subtitle: '${viewModel.conversations.length} récents',
                icon: Icons.mark_email_unread,
                color: AppTheme.sunYellow,
                isUrgent: false,
                onTap: () {
                  viewModel.setIndex(1);
                },
              ),
              PriorityCard(
                title: 'Agenda',
                subtitle: '${viewModel.appointments.length} événements',
                icon: Icons.event,
                color: AppTheme.forestGreen,
                isUrgent: false,
                onTap: () {
                  viewModel.setIndex(2);
                },
              ),
              PriorityCard(
                title: 'Cahier de texte',
                subtitle: 'Gérer les leçons',
                icon: Icons.menu_book_rounded,
                color: Colors.deepOrange,
                isUrgent: false,
                onTap: () {
                  if (premierClasse != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TextbookView(
                          classId: premierClasse['id'] ?? 1,
                          className: premierClasse['classe_nom'] ?? 'Classe',
                          subject: matiere,
                          teacherId: viewModel.teacherId ?? 1,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Aucune classe assignée.')),
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          const PromoBanner(
            bannerImages: [
              'https://i.pinimg.com/736x/46/c9/7f/46c97fda08fb8c284e70704de113fa1a.jpg',
              'https://i.pinimg.com/736x/70/84/85/7084854f0a3841d6cfda063c0ad64ccc.jpg',
              'https://www.aciafrica.org/images/gabon_1642722311.jpg',
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
