import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'student_details_pages.dart';

class StudentHomeworkPage extends StatefulWidget {
  const StudentHomeworkPage({super.key});

  @override
  State<StudentHomeworkPage> createState() => _StudentHomeworkPageState();
}

class _StudentHomeworkPageState extends State<StudentHomeworkPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Agenda & Devoirs', style: TextStyle(color: AppTheme.seaBlue, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppTheme.seaBlue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.seaBlue,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Infos Générales'),
            Tab(text: 'Emploi du temps'),
            Tab(text: 'Devoirs de classe'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGeneralInfosTab(),
          _buildScheduleTab(),
          _buildHomeworkTab(),
        ],
      ),
    );
  }

  Widget _buildGeneralInfosTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildInfoCard(
          title: 'Réunion d\'orientation',
          desc: 'La réunion pour les choix post-bac aura lieu en salle de conférence.',
          date: 'Lundi 02 Mars, 14h00',
          color: AppTheme.seaBlue,
        ),
        _buildInfoCard(
          title: 'Note Administration',
          desc: 'Le devoir de math de ce matin se fera sans calculatrice.',
          date: 'Aujourd\'hui',
          color: Colors.red,
        ),
        _buildInfoCard(
          title: 'Activités Sportives',
          desc: 'Le tournoi inter-classes est reporté au vendredi 15 Mars.',
          date: 'Hier',
          color: AppTheme.forestGreen,
        ),
      ],
    );
  }

  Widget _buildHomeworkTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('DEVOIRS À RENDRE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1)),
        const SizedBox(height: 15),
        _buildHomeworkCard(
          context,
          subject: 'Physique',
          chapter: 'Cinématique',
          date: 'Aujourd\'hui',
          hours: '08:00 - 12:00',
          status: 'À faire',
          teacher: 'M. Mve',
          type: 'Devoir sur table',
          color: Colors.orange,
        ),
        _buildHomeworkCard(
          context,
          subject: 'Mathématiques',
          chapter: 'Étude de fonction',
          date: 'Demain',
          hours: '12:30 - 14:00',
          status: 'À faire',
          teacher: 'Mme Eyi',
          type: 'Devoir maison',
          color: Colors.blue,
        ),
        _buildHomeworkCard(
          context,
          subject: 'Français',
          chapter: 'Texte argumentatif',
          date: 'Aujourd\'hui',
          hours: '15:00 - 17:00',
          status: 'À faire',
          teacher: 'M. Iboga',
          type: 'Devoir en classe',
          color: Colors.pink,
        ),
        const SizedBox(height: 25),
        const Text('DEVOIRS CORRIGÉS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1)),
        const SizedBox(height: 15),
        _buildHomeworkCard(
          context,
          subject: 'Histoire-Géo',
          chapter: 'La décolonisation',
          date: '25 Fév',
          hours: 'Corrigé en classe',
          status: 'Terminé',
          teacher: 'M. Ondo',
          type: 'Individuel',
          color: AppTheme.forestGreen,
        ),
      ],
    );
  }

  Widget _buildScheduleTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Official PDF Button
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: ElevatedButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                      const SizedBox(height: 20),
                      const Text('Emploi du Temps de la Semaine', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 20),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: InteractiveViewer(
                            child: Image.asset('assets/emploie/emploie.png', fit: BoxFit.contain),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            label: const Text('VOIR L\'EMPLOI DU TEMPS OFFICIEL (PDF)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
          ),
        ),
        
        const Text('PROCHAINS COURS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1)),
        const SizedBox(height: 15),
        
        _buildScheduleCard(
          subject: 'Philosophie',
          time: '08:00 - 10:00',
          room: 'Salle B12',
          prof: 'M. Iboga',
          summary: 'Introduction : La conscience et l\'inconscient. Rappel de la méthodologie de la dissertation.',
        ),
        _buildScheduleCard(
          subject: 'Mathématiques',
          time: '10:00 - 12:00',
          room: 'Salle B12',
          prof: 'Mme Eyi',
          summary: 'Nombres Complexes : Forme trigonométrique et exponentielle. Exercices d\'application.',
        ),
        _buildScheduleCard(
          subject: 'Littérature',
          time: '14:00 - 16:00',
          room: 'Amphithéâtre A',
          prof: 'M. Ondo',
          summary: 'Étude d\'œuvre : "Le Crépuscule des Idoles". Analyse du chapitre 1.',
        ),
      ],
    );
  }

  Widget _buildInfoCard({required String title, required String desc, required String date, required Color color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(fontSize: 13, color: AppTheme.textDark)),
          const SizedBox(height: 10),
          Text(date, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildScheduleCard({required String subject, required String time, required String room, required String prof, required String summary}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(color: AppTheme.seaBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Text(time.split(' - ')[0], style: const TextStyle(color: AppTheme.seaBlue, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark)),
                    Text('$prof • $room', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('RÉSUMÉ / CAHIER DE TEXTE :', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                const SizedBox(height: 4),
                Text(summary, style: TextStyle(color: Colors.grey[700], fontSize: 11, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeworkCard(
    BuildContext context, {
    required String subject,
    required String chapter,
    required String date,
    required String hours,
    required String status,
    required String teacher,
    required String type,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(subject, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(5)),
                child: Text(hours, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(chapter, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Text(teacher, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              const Spacer(),
              const Icon(Icons.info_outline, size: 16, color: AppTheme.seaBlue),
              const SizedBox(width: 4),
              Text(status, style: const TextStyle(color: AppTheme.seaBlue, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (_) => HomeworkDetailPage(
                    title: chapter,
                    subject: subject,
                    teacher: teacher,
                    type: type,
                    dueDate: date,
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.seaBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('VOIR LES DÉTAILS', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
