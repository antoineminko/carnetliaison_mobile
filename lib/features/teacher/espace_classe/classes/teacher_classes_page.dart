import 'package:flutter/material.dart';
import 'package:app_mobile/features/teacher/espace_classe/espace_classe.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/shared/config/school_config.dart';

class TeacherClassesPage extends StatefulWidget {
  const TeacherClassesPage({super.key});

  @override
  State<TeacherClassesPage> createState() => _TeacherClassesPageState();
}

class _TeacherClassesPageState extends State<TeacherClassesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> todayMorningClasses = [
    {
      'name': 'Terminale A', 
      'subject': 'Philosophie', 
      'students': 35, 
      'time': '08:00 - 10:00', 
      'color': AppTheme.forestGreen,
      'school': SchoolConfigs.sainteTherese,
    },
    {
      'name': 'Terminale C', 
      'subject': 'Physique-Chimie', 
      'students': 28, 
      'time': '10:30 - 12:30', 
      'color': AppTheme.seaBlue,
      'school': SchoolConfigs.notreDame,
    },
  ];

  final List<Map<String, dynamic>> todayAfternoonClasses = [
    {
      'name': '3ème B', 
      'subject': 'Mathématiques', 
      'students': 32, 
      'time': '14:00 - 16:00', 
      'color': AppTheme.sunYellow,
      'school': SchoolConfigs.sainteTherese,
    },
    {
      'name': '3ème A', 
      'subject': 'Français', 
      'students': 30, 
      'time': '16:15 - 18:15', 
      'color': AppTheme.forestGreen,
      'school': SchoolConfigs.notreDame,
    },
  ];

  final List<Map<String, dynamic>> tomorrowClasses = [
    {
      'name': '2nde S', 
      'subject': 'Mathématiques', 
      'students': 40, 
      'time': '08:00 - 10:00', 
      'color': AppTheme.seaBlue,
      'school': SchoolConfigs.sainteTherese,
    },
    {
      'name': 'Terminale A', 
      'subject': 'Philosophie', 
      'students': 35, 
      'time': '10:30 - 12:30', 
      'color': AppTheme.forestGreen,
      'school': SchoolConfigs.sainteTherese,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TOP NAVBAR / TABS
            _buildCustomHeader(),
            
            // 2. ADMIN NOTIFICATION BANNER
            _buildAdminNotification(),

            // 3. TAB VIEWS
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAgendaTab(),
                  _buildCalendarTab(),
                  _buildNotificationsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Espace Cours',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_active_outlined, color: AppTheme.sunYellow),
                onPressed: () {},
              )
            ],
          ),
          const SizedBox(height: 10),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppTheme.seaBlue,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: AppTheme.seaBlue,
            unselectedLabelColor: AppTheme.textGrey,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            tabs: const [
              Tab(text: 'Cours'),
              Tab(text: 'Calendrier'),
              Tab(text: 'Notifications'),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildAdminNotification() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.seaBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppTheme.seaBlue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: AppTheme.seaBlue, shape: BoxShape.circle),
            child: const Icon(Icons.campaign_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NOTIF ADMINISTRATION',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.seaBlue),
                ),
                Text(
                  'Changement de salle pour Terminale C ce vendredi.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textDark, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgendaTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _buildDateSection('AUJOURD\'HUI', 'Mardi 24 Février 2026'),
        
        // Matin
        _buildSessionSubtitle('AM - MATIN'),
        ...todayMorningClasses.map((cls) => _buildClassCard(context, cls)),
        
        // Récréation
        _buildBreakCard('Pause Récréation', '10:00 - 10:30'),
        
        // Après-midi
        _buildSessionSubtitle('PM - APRÈS-MIDI'),
        ...todayAfternoonClasses.map((cls) => _buildClassCard(context, cls)),

        const SizedBox(height: 30),
        _buildDateSection('DEMAIN', 'Mercredi 25 Février 2026'),
        ...tomorrowClasses.map((cls) => _buildClassCard(context, cls, isTomorrow: true)),
        
        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildDateSection(String title, String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppTheme.textDark, borderRadius: BorderRadius.circular(8)),
            child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Text(date, style: const TextStyle(color: AppTheme.textGrey, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSessionSubtitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 5),
      child: Text(text, style: TextStyle(color: AppTheme.textGrey.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
    );
  }

  Widget _buildBreakCard(String title, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.coffee_rounded, color: AppTheme.textGrey),
          const SizedBox(width: 15),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textGrey)),
          const Spacer(),
          Text(time, style: const TextStyle(color: AppTheme.textGrey, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, Map<String, dynamic> cls, {bool isTomorrow = false}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EspaceClassePage(
              classId: 1, // Dummy ID pour l'instant
              teacherId: 1, // Dummy ID pour l'instant
              className: cls['name'],
              session: isTomorrow ? 'Demain' : 'Aujourd\'hui',
              subject: cls['subject'],
              studentCount: cls['students'],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 50,
              decoration: BoxDecoration(color: cls['color'], borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cls['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                  const SizedBox(height: 4),
                  Text(
                    cls['school'] ?? SchoolConfigs.sainteTherese,
                    style: TextStyle(color: cls['color'], fontWeight: FontWeight.bold, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(cls['subject'], style: const TextStyle(color: AppTheme.textGrey, fontSize: 14)),
                      Text(cls['time'], style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w500, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarTab() {
    // Simplified Monthly Calendar View
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Février 2026', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Row(
                      children: [
                        Icon(Icons.chevron_left),
                        const SizedBox(width: 20),
                        Icon(Icons.chevron_right),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 20),
                // Dummy Calendar Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1),
                  itemCount: 35, // 5 weeks
                  itemBuilder: (context, index) {
                    final day = index - 2; // Offset for February starting day
                    final isToday = day == 24;
                    final hasClass = day == 24 || day == 25 || day == 26;
  
                    if (day < 1 || day > 28) return const SizedBox();
  
                    return Container(
                      decoration: BoxDecoration(
                        color: isToday ? AppTheme.seaBlue : (hasClass ? AppTheme.seaBlue.withOpacity(0.1) : null),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        day.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isToday ? Colors.white : (hasClass ? AppTheme.seaBlue : AppTheme.textDark),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'LÉGENDE',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.textGrey, letterSpacing: 1.2),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildLegend(AppTheme.seaBlue, 'Cours prévus'),
                const SizedBox(width: 20),
                _buildLegend(AppTheme.sunYellow, 'Examens'),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildNotificationTile(
          title: 'Changement de salle',
          subtitle: 'La classe de Terminale C se passera en Salle 105 au lieu de 204.',
          school: SchoolConfigs.sainteTherese,
          time: 'Il y a 10 min',
          icon: Icons.room_rounded,
          color: AppTheme.seaBlue,
          isNew: true,
        ),
        _buildNotificationTile(
          title: 'Conseil de classe',
          subtitle: 'Rappel : Le conseil de classe pour la 3ème B commence à 18h15.',
          school: SchoolConfigs.notreDame,
          time: 'Il y a 1h',
          icon: Icons.gavel_rounded,
          color: AppTheme.sunYellow,
          isNew: true,
        ),
        _buildNotificationTile(
          title: 'Notes publiées',
          subtitle: 'Les notes de Philosophie (Terminale A) sont désormais visibles par les parents.',
          school: SchoolConfigs.sainteTherese,
          time: 'Ce matin',
          icon: Icons.check_circle_rounded,
          color: AppTheme.forestGreen,
        ),
        _buildNotificationTile(
          title: 'Maintenance Système',
          subtitle: 'La plateforme sera indisponible de 23h à 00h pour maintenance.',
          school: 'Administration',
          time: 'Hier',
          icon: Icons.settings_rounded,
          color: AppTheme.textGrey,
        ),
      ],
    );
  }

  Widget _buildNotificationTile({
    required String title,
    required String subtitle,
    required String school,
    required String time,
    required IconData icon,
    required Color color,
    bool isNew = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isNew ? color.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: isNew ? Border.all(color: color.withOpacity(0.2)) : null,
        boxShadow: [
          if (!isNew) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark)),
                    ),
                    if (isNew)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
                        child: const Text('NOUVEAU', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(subtitle, style: const TextStyle(color: AppTheme.textGrey, fontSize: 13, height: 1.4)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(school, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    Text(time, style: TextStyle(color: AppTheme.textGrey.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
      ],
    );
  }
}
