import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/shared/config/school_config.dart';

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildProfileHeader(),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppTheme.seaBlue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.seaBlue,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'Informations'),
              Tab(text: 'Résultats'),
              Tab(text: 'Statistiques'),
              Tab(text: 'Paramètres'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInfoTab(),
                _buildResultsTab(),
                _buildStatsTab(),
                _buildSettingsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppTheme.seaBlue,
                  shape: BoxShape.circle,
                ),
                child: const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage(
                    'assets/images/profil/eleve1.jpg',
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppTheme.sunYellow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text(
            'Yannick MPIGA',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'ID Student: #STU-2007-A1',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.forestGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Statut : Actif',
              style: TextStyle(
                color: AppTheme.forestGreen,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildInfoTile(Icons.school_outlined, 'Classe', 'Terminale A1'),
        _buildInfoTile(
          Icons.location_on_outlined,
          'Établissement',
          SchoolConfigs.notreDame,
        ),
        _buildInfoTile(
          Icons.cake_outlined,
          'Date de naissance',
          '05 Mars 2007',
        ),
        _buildInfoTile(
          Icons.person_outline,
          'Parent principal',
          'M. MPIGA (Père)',
        ),
        _buildInfoTile(
          Icons.phone_outlined,
          'Contact urgence',
          '+241 07 24 55 99',
        ),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.seaBlue, size: 22),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppTheme.textDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader('DERNIÈRES NOTES (SESSION PROF)', Icons.edit_note),
        const SizedBox(height: 10),
        _buildGradeItem(
          subject: 'Philosophie',
          note: '14/20',
          average: '12.5',
          type: 'Interrogation',
          date: '25 Fév',
          color: AppTheme.seaBlue,
        ),
        _buildGradeItem(
          subject: 'Mathématiques',
          note: '16.5/20',
          average: '11.0',
          type: 'Devoir Maison',
          date: '21 Fév',
          color: Colors.orange,
        ),
        _buildGradeItem(
          subject: 'Littérature',
          note: '12/20',
          average: '13.2',
          type: 'Devoir de classe',
          date: '18 Fév',
          color: AppTheme.forestGreen,
        ),

        const SizedBox(height: 30),

        _buildSectionHeader(
          'BULLETINS OFFICIELS (PDF)',
          Icons.verified_user_outlined,
        ),
        const SizedBox(height: 10),
        _buildBulletinItem(
          label: 'Bulletin du 1er Trimestre',
          academicYear: '2025-2026',
          status: 'Disponible',
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildGradeItem({
    required String subject,
    required String note,
    required String average,
    required String type,
    required String date,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.description_outlined, color: color, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  '$type • $date',
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
                const SizedBox(height: 4),
                Text(
                  'Moyenne classe : $average',
                  style: TextStyle(
                    color: AppTheme.seaBlue.withOpacity(0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            note,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletinItem({
    required String label,
    required String academicYear,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.seaBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppTheme.seaBlue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf, color: Colors.red, size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  'Année : $academicYear • $status',
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.seaBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              minimumSize: const Size(60, 30),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'VOIR',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader(
          'BILAN TERMINALE C (TRIMESTRE 1 vs 2)',
          Icons.auto_graph,
        ),
        const SizedBox(height: 15),

        _buildStatSubject(
          subject: 'Mathématiques',
          t1: '12.5',
          t2: '14.5',
          progress: 0.85,
          status: 'Hausse niveau (+2.0)',
          statusColor: AppTheme.forestGreen,
          hint: 'Excellent travail. Maintiens les efforts sur les matrices.',
        ),
        _buildStatSubject(
          subject: 'Physique-Chimie',
          t1: '11.0',
          t2: '13.0',
          progress: 0.75,
          status: 'Hausse niveau (+2.0)',
          statusColor: AppTheme.forestGreen,
          hint: 'Hausse notable en Physique. Continue ainsi.',
        ),
        _buildStatSubject(
          subject: 'Français',
          t1: '10.5',
          t2: '09.5',
          progress: 0.48,
          status: 'Baisse niveau (-1.0)',
          statusColor: Colors.red,
          hint:
              'Attention ! Défaut identifié en dissertation. À travailler d\'urgence.',
        ),
        _buildStatSubject(
          subject: 'Anglais',
          t1: '12.0',
          t2: '12.5',
          progress: 0.65,
          status: 'Stable',
          statusColor: AppTheme.seaBlue,
          hint: 'Bon niveau général. Participe plus à l\'oral.',
        ),
        _buildStatSubject(
          subject: 'Philosophie',
          t1: '09.0',
          t2: '11.5',
          progress: 0.58,
          status: 'Hausse niveau (+2.5)',
          statusColor: AppTheme.forestGreen,
          hint: 'Très belle progression. Seuil dépassé.',
        ),
        _buildStatSubject(
          subject: 'Hist-Géo',
          t1: '14.0',
          t2: '13.5',
          progress: 0.70,
          status: 'Baisse légère (-0.5)',
          statusColor: Colors.orange,
          hint: 'Reste vigilant sur la cartographie.',
        ),
        _buildStatSubject(
          subject: 'SVT',
          t1: '13.0',
          t2: '13.0',
          progress: 0.68,
          status: 'Stable',
          statusColor: AppTheme.seaBlue,
          hint: 'Rigueur scientifique présente. Travaille l\'analyse doc.',
        ),
      ],
    );
  }

  Widget _buildStatSubject({
    required String subject,
    required String t1,
    required String t2,
    required double progress,
    required String status,
    required Color statusColor,
    required String hint,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subject,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppTheme.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _buildNoteCircle('T1', t1, Colors.grey),
              const SizedBox(width: 15),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 15),
              _buildNoteCircle('T2', t2, statusColor),
              const Expanded(child: SizedBox()),
            ],
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: statusColor.withOpacity(0.1),
              color: statusColor,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, size: 14, color: statusColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hint,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCircle(String label, String note, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3)),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              note,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSectionHeader('COMPTE ÉLÈVE', Icons.person_outline),
        const SizedBox(height: 15),
        _buildSettingTile(Icons.lock_outline, 'Changer de mot de passe'),
        _buildSettingTile(
          Icons.notifications_outlined,
          'Gérer les notifications',
        ),
        _buildSettingTile(Icons.language, 'Langue (Français)'),

        const SizedBox(height: 30),

        _buildSectionHeader('SYSTÈME', Icons.settings_outlined),
        const SizedBox(height: 15),
        _buildSettingTile(Icons.help_outline, 'Assistance & Support'),
        _buildSettingTile(Icons.info_outline, 'À propos de Schooly'),

        const SizedBox(height: 50),

        SizedBox(
          width: double.infinity,
          height: 55,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/', (route) => false),
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text(
              'SE DÉCONNECTER',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 15),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
        ],
      ),
    );
  }
}
