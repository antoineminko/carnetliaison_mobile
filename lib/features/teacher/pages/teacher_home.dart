import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_mobile/features/teacher/pages/class_dashboard.dart';
import 'package:app_mobile/features/teacher/pages/teacher_classes_page.dart';
import 'package:app_mobile/features/teacher/pages/teacher_profile_page.dart';
import 'package:app_mobile/features/teacher/pages/teacher_messages_page.dart';
import 'package:app_mobile/features/teacher/pages/attendance_view.dart';
import 'package:app_mobile/features/teacher/pages/create_homework_page.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/shared/config/school_config.dart';
import 'package:app_mobile/shared/widgets/background_wrapper.dart';

class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({super.key});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  int _currentIndex = 0;
  String _activeSchool = SchoolConfigs.sainteTherese;

  // Carousel State
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _bannerTimer;

  final List<String> _bannerImages = [
    'assets/publicit/pub1.jpg',
    'assets/publicit/pub2.jpg',
    'assets/publicit/pub3.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startBannerTimer();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < _bannerImages.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, 
      body: BackgroundWrapper(
        child: SafeArea(
          child: _buildBody(),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const TeacherClassesPage();
      case 2:
        return _buildPlanningTab();
      case 3:
        return const TeacherMessagesPage();
      case 4:
        return const TeacherProfilePage();
      default:
        return const Center(child: Text('Erreur'));
    }
  }



  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER WITH SCHOOL CONTEXT SWITCHER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '👋 Bonjour M. Obiang',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildSchoolChip(SchoolConfigs.sainteTherese, true),
                          const SizedBox(width: 8),
                          _buildSchoolChip(SchoolConfigs.notreDame, false),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
               Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.forestGreen.withOpacity(0.2), width: 2),
                  image: const DecorationImage(
                     image: AssetImage('assets/images/teacher.png'),
                     fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          // 2. NEXT CLASS CARD (Linked to a school)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ClassDashboardPage(
                    className: '3ème B',
                    subject: 'Mathématiques',
                    studentCount: 32,
                    session: 'Matin',
                  ),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.forestGreen, AppTheme.forestGreen.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.forestGreen.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.access_time_filled, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'PROCHAINE CLASSE',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _activeSchool == SchoolConfigs.sainteTherese ? 'STE THÉRÈSE' : 'NOTRE-DAME',
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    '3ème B',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.white, size: 16),
                          SizedBox(width: 5),
                          Text(
                            'Salle 102  •  08:00 - 10:00',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Text(
                          'Suivie par: 2nde A @ ${_activeSchool == SchoolConfigs.sainteTherese ? 'NOTRE-DAME' : 'STE THÉRÈSE'}',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 9,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // 3. PRIORITY BLOCKS TITLE
          const Text(
            'Priorités du jour',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 15),

          // 4. ACTION GRID
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.1,
            children: [
              _buildPriorityCard(
                title: 'Faire l\'appel',
                subtitle: '3ème B (${_activeSchool == SchoolConfigs.sainteTherese ? 'STE THÉRÈSE' : 'NOTRE-DAME'})',
                icon: Icons.how_to_reg,
                color: AppTheme.forestGreen, // Forest Green
                isUrgent: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Scaffold(
                        appBar: AppBar(
                          backgroundColor: Colors.white,
                          elevation: 0,
                          title: const Text('Appel - 3ème B', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
                          leading: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        body: const AttendanceView(
                          studentCount: 32,
                          className: '3ème B',
                        ),
                      ),
                    ),
                  );
                },
              ),
              _buildPriorityCard(
                title: 'Publier devoir',
                subtitle: 'Gérer les devoirs',
                icon: Icons.upload_file,
                color: AppTheme.seaBlue, // Sea Blue
                isUrgent: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateHomeworkPage()),
                  );
                },
              ),
              _buildPriorityCard(
                title: 'Messages',
                subtitle: '3 non lus',
                icon: Icons.mark_email_unread,
                color: AppTheme.sunYellow, // Sun Yellow
                isUrgent: false,
                onTap: () {
                  setState(() {
                    _currentIndex = 3; // Switch to Messages tab
                  });
                },
              ),
              _buildPriorityCard(
                title: 'Agenda',
                subtitle: '2 événements',
                icon: Icons.event,
                color: AppTheme.seaBlue.withOpacity(0.7), // Subtle Sea Blue
                isUrgent: false,
                onTap: () {
                  setState(() {
                    _currentIndex = 1; // Navigue vers l'espace cours (TeacherClassesPage)
                  });
                },
              ),
            ],
          ),
          // 5. BANNER PUBLICITAIRE (Comme chez le parent)
          const SizedBox(height: 10),
          _buildPromoBanner(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _bannerImages.length,
              itemBuilder: (context, index) {
                return Image.asset(
                  _bannerImages[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                );
              },
            ),
            // Indicators
            Positioned(
              bottom: 15,
              right: 20,
              child: Row(
                children: List.generate(
                  _bannerImages.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? Colors.white : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
            // Overlay Tag
            Positioned(
              top: 15,
              left: 15,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Sponsoring',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchoolChip(String name, bool isSelected) {
    bool isSainteTherese = name == SchoolConfigs.sainteTherese;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? (isSainteTherese ? AppTheme.forestGreen : AppTheme.seaBlue) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? Colors.transparent : Colors.grey[300]!,
        ),
      ),
      child: Text(
        isSainteTherese ? 'STE THÉRÈSE' : 'NOTRE-DAME',
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[600],
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPriorityCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isUrgent,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                if (isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.sunYellow.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'URGENT',
                      style: TextStyle(
                      color: AppTheme.sunYellow,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPlanningTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Agenda & Réunions',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
          const SizedBox(height: 20),
          
          // Availability Toggle
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.seaBlue.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.event_available, color: AppTheme.seaBlue),
                const SizedBox(width: 15),
                const Expanded(
                  child: Text('Ma disponibilité pour RDV', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Switch(value: true, onChanged: (v) {}, activeColor: AppTheme.seaBlue),
              ],
            ),
          ),
          
          const SizedBox(height: 25),
          const Text('RENDEZ-VOUS PARENTS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 1.2)),
          const SizedBox(height: 15),

          _buildMeetingCard(
            title: 'RDV Vidéo : Parent de Yannick',
            time: 'Aujourd\'hui • 15:30 - 15:50',
            location: 'Visioconférence sécurisée',
            participants: 'M. Ewosso D-Gall',
            color: Colors.deepPurple,
            icon: Icons.videocam,
            showVisioButton: true,
          ),
          
          const SizedBox(height: 25),
          const Text('RÉUNIONS OFFICIELLES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 1.2)),
          const SizedBox(height: 15),

          _buildMeetingCard(
            title: 'Réunion Parents-Profs (3ème B)',
            time: '16:00 - 18:00',
            location: 'Salle Polyvalente',
            participants: '24 parents attendus',
            color: AppTheme.sunYellow,
            icon: Icons.people_rounded,
          ),
          const SizedBox(height: 15),
          _buildMeetingCard(
            title: 'Conseil de classe (Terminale S)',
            time: '18:15 - 19:30',
            location: 'Salle 204',
            participants: 'Administration & Profs',
            color: AppTheme.seaBlue,
            icon: Icons.gavel_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingCard({
    required String title,
    required String time,
    required String location,
    required String participants,
    required Color color,
    required IconData icon,
    bool showVisioButton = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      SchoolConfigs.sainteTherese,
                      style: TextStyle(color: Colors.grey[400], fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(time, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.textGrey),
              const SizedBox(width: 8),
              Text(location, style: const TextStyle(color: AppTheme.textGrey, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.group_outlined, size: 16, color: AppTheme.textGrey),
              const SizedBox(width: 8),
              Text(participants, style: const TextStyle(color: AppTheme.textGrey, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (showVisioButton) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Lancement de la visioconférence...'), backgroundColor: Colors.deepPurple)
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Affichage de la liste des participants...')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: (color == AppTheme.sunYellow) ? AppTheme.textDark : Colors.white,
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (showVisioButton) ...[
                  const Icon(Icons.videocam, size: 18),
                  const SizedBox(width: 10),
                ],
                Text(
                  showVisioButton ? 'Lancer la visio' : 'Voir la liste des participants',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.seaBlue, // Sea Blue for active nav
        unselectedItemColor: Colors.grey[400],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_rounded),
            label: 'Classes',
          ),
          BottomNavigationBarItem(
             icon: Icon(Icons.calendar_today_rounded),
             label: 'Cours',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
