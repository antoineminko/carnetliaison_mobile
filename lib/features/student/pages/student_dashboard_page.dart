import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'student_details_pages.dart';
import 'package:app_mobile/shared/config/school_config.dart';

class StudentDashboardPage extends StatelessWidget {
  const StudentDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 25),
              _buildSectionTitle('Ma Journée'),
              const SizedBox(height: 15),
              _buildMyDaySection(),
              const SizedBox(height: 25),
              _buildSectionTitle('Annonces importantes'),
              const SizedBox(height: 15),
              _buildAnnouncementsSection(context),
              const SizedBox(height: 25),
              _buildSectionTitle('Actualités récentes'),
              const SizedBox(height: 15),
              _buildNewsSection(context),
              const SizedBox(height: 25),
              _buildSectionTitle('Résultats récents'),
              const SizedBox(height: 15),
              _buildRecentResults(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                SchoolConfigs.notreDame,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.seaBlue,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Bonjour Yannick 👋',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
              const SizedBox(height: 4),
              Text(
                'Classe : Terminale C • Samedi 28 Février',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 15),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
          ),
          child: const CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage('assets/images/profil/eleve1.jpg'),
            backgroundColor: AppTheme.seaBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildMyDaySection() {
    return Column(
      children: [
        _buildDayCardFull(
          title: 'Prochain cours',
          subtitle: 'Physique',
          time: '08:00 - 10:00',
          location: 'Amphi 102',
          note: 'Annonce: Devoir sur table en cours de Physique (Chapitre 2)',
          icon: Icons.schedule,
          color: AppTheme.seaBlue,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.green[100]!),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.green[50], shape: BoxShape.circle),
                child: const Icon(Icons.check_circle, color: Colors.green, size: 20),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Statut de présence', style: TextStyle(color: Colors.grey, fontSize: 11)),
                    Row(
                      children: [
                        const Text('PRÉSENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green)),
                        const SizedBox(width: 8),
                        Text('• Arrivée: 07:45', style: TextStyle(color: Colors.grey[700], fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.seaBlue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.seaBlue.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.menu_book_rounded, color: AppTheme.seaBlue, size: 20),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Vous avez 3 devoirs signalés pour aujourd\'hui.',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDayCardFull({required String title, required String subtitle, required String time, required String location, required String note, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                  Text(subtitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 5),
              Text(time, style: TextStyle(color: Colors.grey[800], fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(width: 20),
              Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 5),
              Text(location, style: TextStyle(color: Colors.grey[800], fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.campaign_outlined, size: 16, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    note,
                    style: const TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementsSection(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentAnnouncementDetailPage(title: 'Réunion d\'orientation post-bac'))),
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue[900]!, AppTheme.seaBlue]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.school, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('ORIENTATION TERMINALE', style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 11)),
                    SizedBox(width: 8),
                    CircleAvatar(radius: 4, backgroundColor: Colors.red),
                  ],
                ),
                const SizedBox(height: 5),
                const Text(
                  'Suivi Dossier Campus France & Orientation',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  'Consultation des étapes d\'avancement',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildNewsSection(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildNewsCard(context, 'Orientation Scolaire', 'Session 2026 : Campus France / Parcoursup.', AppTheme.forestGreen, 'assets/images/profil/actualité/actu1.png'),
        ],
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context, String title, String desc, Color color, String imgPath) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StudentNewsDetailPage(title: title))),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                image: DecorationImage(
                  image: AssetImage(imgPath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(desc, style: TextStyle(color: Colors.grey[600], fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentResults() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.seaBlue.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppTheme.seaBlue.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.auto_graph, color: AppTheme.seaBlue),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dernière note publiée', style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 2),
                Text('Mathématiques - Quiz Hebdo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
          const Text(
            '15/20',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.seaBlue),
          ),
        ],
      ),
    );
  }
}
