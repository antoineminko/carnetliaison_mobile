import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:app_mobile/shared/config/api_client.dart';
import 'package:app_mobile/shared/config/api_endpoints.dart';
import 'package:app_mobile/features/auth/parent/services/parent_auth_service.dart';
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
    'https://i.pinimg.com/736x/46/c9/7f/46c97fda08fb8c284e70704de113fa1a.jpg',
    'https://i.pinimg.com/736x/70/84/85/7084854f0a3841d6cfda063c0ad64ccc.jpg',
    'https://www.aciafrica.org/images/gabon_1642722311.jpg',
  ];

  bool _isLoading = true;
  Map<String, dynamic>? _dashboardData;
  int? _teacherId;
  List<dynamic> _appointments = [];
  List<dynamic> _conversations = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startBannerTimer();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final tid = await AuthService.getTeacherId();
      if (tid == null) {
        setState(() => _isLoading = false);
        return;
      }
      _teacherId = tid;

      final response = await ApiClient.instance.get(ApiEndpoints.teacherDashboard(tid));
      
      if (response.data['success'] == true) {
        setState(() {
          _dashboardData = response.data;
        });
      }
      
      try {
        final eventsResponse = await ApiClient.instance.get('/enseignants/$tid/events');
        setState(() {
          _appointments = eventsResponse.data['appointments'] ?? [];
          _conversations = eventsResponse.data['conversations'] ?? [];
        });
      } catch (e) {
        print('Erreur lors du chargement des événements : $e');
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final teacher = _dashboardData?['teacher'] ?? {};
    final classes = (_dashboardData?['classes'] as List?) ?? [];
    final prenom = teacher['prenom'] ?? '';
    final nom = teacher['nom'] ?? '';
    final matiere = teacher['matiere'] ?? 'Professeur';
    final premierClasse = classes.isNotEmpty ? classes[0] : null;

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
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.seaBlue,
                        fontWeight: FontWeight.w600,
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

          const SizedBox(height: 25),          // 2. NEXT CLASS CARD (Linked to a school)
          const SizedBox(height: 25),          // 2. NEXT CLASS CARD (Linked to a school)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClassDashboardPage(
                    classId: premierClasse?['id'] ?? 1,
                    className: premierClasse?['classe_nom'] ?? '3ème B',
                    subject: teacher['matiere'] ?? 'Mathématiques',
                    session: 'Matin',
                    teacherId: _teacherId ?? 1,
                    studentCount: premierClasse?['students_count'] ?? 30,
                    schoolName: premierClasse?['ecole_nom'] ?? 'Aucune école',
                  ),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.seaBlue, AppTheme.seaBlue.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.seaBlue.withOpacity(0.3),
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
                            'VOTRE CLASSE',
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
                            premierClasse?['ecole_nom'] ?? 'ÉCOLE',
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      premierClasse?['classe_nom'] ?? 'Aucune classe',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.white, size: 16),
                            SizedBox(width: 5),
                            Text(
                              'Sur place',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                '08:00 - 12:00',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
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
                subtitle: premierClasse?['classe_nom'] ?? 'Aucune classe',
                icon: Icons.how_to_reg,
                color: AppTheme.forestGreen, // Forest Green
                isUrgent: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ClassDashboardPage(
                        classId: premierClasse?['id'] ?? 1,
                        className: premierClasse?['classe_nom'] ?? 'Aucune classe',
                        subject: teacher['matiere'] ?? 'Mathématiques',
                        session: 'Matin',
                        teacherId: _teacherId ?? 1,
                        studentCount: premierClasse?['students_count'] ?? 30,
                        schoolName: premierClasse?['ecole_nom'] ?? 'Aucune école',
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
                subtitle: '${_appointments.length} événements',
                icon: Icons.event,
                color: AppTheme.seaBlue.withOpacity(0.7), // Subtle Sea Blue
                isUrgent: false,
                onTap: () {
                  setState(() {
                    _currentIndex = 2; // Navigue vers l'espace événements
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
                return Image.network(
                  _bannerImages[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
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

          if (_appointments.isEmpty)
            const Text('Aucun rendez-vous prévu.', style: TextStyle(color: Colors.grey)),
            
          ..._appointments.map((appt) {
            final parentName = '${appt['parent_prenom']} ${appt['parent_nom']}';
            final eleveName = appt['eleve_prenom'] != null ? '${appt['eleve_prenom']} ${appt['eleve_nom']}' : 'Élève';
            final date = appt['date_heure'] != null ? appt['date_heure'].toString().substring(0, 16).replaceFirst('T', ' ') : '';
            final isPending = appt['statut'] == 'en_attente';
            final requester = appt['requester'] ?? 'parent';
            final motif = appt['motif'] ?? 'Aucun motif';
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: _buildMeetingCard(
                title: 'RDV ${appt['type'] == 'video' ? 'Vidéo' : 'Présentiel'} : $parentName',
                time: '$date\nMotif : $motif',
                location: appt['type'] == 'video' ? 'Visioconférence' : 'À l\'école',
                participants: '$parentName (pour $eleveName)',
                color: isPending ? Colors.orange : Colors.deepPurple,
                icon: appt['type'] == 'video' ? Icons.videocam : Icons.location_on,
                showVisioButton: appt['type'] == 'video' && !isPending,
                isPending: isPending,
                requester: requester,
                id: appt['id'],
                type: 'appointment',
              ),
            );
          }).toList(),
          
          const SizedBox(height: 25),
          const Text('DEMANDES DE MESSAGERIE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 1.2)),
          const SizedBox(height: 15),

          if (_conversations.isEmpty)
            const Text('Aucune demande en attente.', style: TextStyle(color: Colors.grey)),

          ..._conversations.map((conv) {
            final parentName = '${conv['parent_prenom']} ${conv['parent_nom']}';
            final status = conv['status'] ?? 'pending';
            final isPending = status == 'pending';
            
            String title = 'Nouvelle conversation: $parentName';
            Color color = Colors.blue;
            if (status == 'accepted') {
              title = 'Discussion acceptée: $parentName';
              color = Colors.green;
            } else if (status == 'rejected') {
              title = 'Discussion refusée: $parentName';
              color = Colors.red;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: _buildMeetingCard(
                title: title,
                time: 'Objet: ${conv['subject'] ?? 'Non spécifié'}',
                location: 'Messagerie',
                participants: parentName,
                color: color,
                icon: Icons.message,
                showVisioButton: false,
                isPending: isPending,
                status: status,
                id: conv['id'],
                type: 'conversation',
              ),
            );
          }).toList(),
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
    bool isPending = false,
    String requester = 'parent',
    int? id,
    String? type,
    String? status,
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
            if (showVisioButton) ...[
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.video_call),
                  label: const Text('Rejoindre la visio', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              )
            ],
            
            if (isPending) ...[
              const SizedBox(height: 15),
              if (requester == 'parent')
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _updateRequestStatus(id, type, 'rejected'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Refuser'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _updateRequestStatus(id, type, 'accepted'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Accepter'),
                      ),
                    ),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.hourglass_empty, color: Colors.orange, size: 16),
                      SizedBox(width: 8),
                      Text('En attente d\'acceptation', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
            ] else if (status == 'accepted' || status == 'rejected') ...[
              const SizedBox(height: 15),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    status == 'accepted' ? 'Vous avez accepté cette demande' : 'Vous avez refusé cette demande',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ]
        ],
      ),
    );
  }

  Future<void> _updateRequestStatus(int? id, String? type, String status) async {
    if (id == null || type == null) return;
    try {
      if (type == 'appointment') {
        await ApiClient.instance.put('/appointments/$id/status', data: {'statut': status == 'rejected' ? 'refuse' : 'accepte'});
      } else if (type == 'conversation') {
        await ApiClient.instance.put('/messages/conversation/$id/status', data: {'status': status});
      }
      _loadDashboardData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
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
             label: 'Événements',
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
