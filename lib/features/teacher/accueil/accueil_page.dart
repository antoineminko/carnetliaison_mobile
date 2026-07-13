import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_mobile/shared/config/api_client.dart';
import 'package:app_mobile/shared/config/api_endpoints.dart';
import 'package:app_mobile/features/auth/services/auth_service.dart';
import 'package:app_mobile/features/teacher/espace_classe/espace_classe.dart';
import 'package:app_mobile/features/teacher/espace_classe/classes/teacher_classes_page.dart';
import 'package:app_mobile/features/teacher/profil/teacher_profile_page.dart';
import 'package:app_mobile/features/teacher/messages/teacher_messages_page.dart';
import 'package:app_mobile/features/teacher/accueil/devoirs/create_homework_page.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/shared/config/school_config.dart';
import 'package:app_mobile/shared/widgets/background_wrapper.dart';
import 'package:app_mobile/features/teacher/services/teacher_dashboard_service.dart';
import 'package:app_mobile/features/teacher/services/teacher_event_service.dart';
import 'package:app_mobile/features/teacher/services/teacher_message_service.dart';
import 'package:app_mobile/features/notifications/services/notifications_service.dart';
import 'package:app_mobile/features/auth/services/ping_service.dart';

part '../agenda/evenement/evenements_view.dart';

class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({super.key});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  int _currentIndex = 0;

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
  String _selectedEventFilter = 'Tous';
  bool _argsProcessed = false;
  final Set<int> _viewedAppointmentIds = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_argsProcessed) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        if (args['openChat'] == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _currentIndex = 1;
            });
          });
        }
        if (args['openAppointments'] == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _currentIndex = 2; // Planning tab
            });
          });
        }
      }
      _argsProcessed = true;
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startBannerTimer();
    _loadDashboardData();
    NotificationsService().setOnNotificationReceived(() {
      _loadDashboardData();
    });
    PingService.startPinging();
  }

  Future<void> _loadDashboardData() async {
    try {
      final tid = await AuthService.getTeacherId();
      if (tid == null) {
        setState(() => _isLoading = false);
        return;
      }
      _teacherId = tid;

      final response = await TeacherDashboardService.instance.getDashboard(tid);

      if (response.data['success'] == true) {
        setState(() {
          _dashboardData = response.data;
        });
      }

      try {
        final eventsResponse = await TeacherEventService.instance.getEvents(tid);
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
    PingService.stopPinging();
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
      body: BackgroundWrapper(child: SafeArea(child: _buildBody())),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const TeacherMessagesPage();
      case 2:
        return _buildPlanningTab();
      case 3:
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
          // 2. CLASSES SLIDER
          if (classes.isEmpty)
            const Center(child: Text('Aucune classe assignée'))
          else
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: classes.length,
                itemBuilder: (context, index) {
                  final classe = classes[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EspaceClassePage(
                            classId: classe['id'] ?? 1,
                            className: classe['classe_nom'] ?? 'Classe',
                            subject: matiere,
                            session: 'Matin',
                            teacherId: _teacherId ?? 1,
                            studentCount: classe['students_count'] ?? 0,
                            schoolName: classe['ecole_nom'] ?? '',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 280,
                      margin: const EdgeInsets.only(right: 15),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.seaBlue,
                            AppTheme.seaBlue.withOpacity(0.8)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.seaBlue.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.class_,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${classe['students_count'] ?? 0} élèves',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            classe['classe_nom'] ?? 'Classe',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
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
                title: 'Publier devoir',
                subtitle: 'Gérer les devoirs',
                icon: Icons.upload_file,
                color: AppTheme.seaBlue, // Sea Blue
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
              _buildPriorityCard(
                title: 'Messages',
                subtitle: '${_conversations.length} récents',
                icon: Icons.mark_email_unread,
                color: AppTheme.sunYellow, // Sun Yellow
                isUrgent: false,
                onTap: () {
                  setState(() {
                    _currentIndex = 1; // Switch to Messages tab (Index 1)
                  });
                },
              ),
              _buildPriorityCard(
                title: 'Agenda',
                subtitle: '${_appointments.length} événements',
                icon: Icons.event,
                color: AppTheme.forestGreen, 
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
                      color: _currentPage == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Sponsoring',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
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
        color: isSelected
            ? (isSainteTherese ? AppTheme.forestGreen : AppTheme.seaBlue)
            : Colors.white,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
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
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateRequestStatus(
    int? id,
    String? type,
    String status,
  ) async {
    if (id == null || type == null) return;
    try {
      if (type == 'appointment') {
        await TeacherEventService.instance.updateAppointmentStatus(
          id,
          status == 'rejected' ? 'refuse' : 'accepte',
        );
      } else if (type == 'conversation') {
        await TeacherMessageService.instance.updateConversationStatus(id, status);
      }
      _loadDashboardData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  int get _totalUnreadMessages {
    int total = 0;
    for (var c in _conversations) {
      final val = c['unread_count'];
      total += (val is int) ? val : (int.tryParse(val?.toString() ?? '0') ?? 0);
    }
    return total;
  }

  int get _totalPendingAppointments {
    int total = 0;
    for (var appt in _appointments) {
      if (appt is Map && appt['statut'] == 'en_attente') {
        final id = int.tryParse(appt['id']?.toString() ?? '');
        if (id != null && !_viewedAppointmentIds.contains(id)) {
          total++;
        }
      }
    }
    return total;
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
            if (index == 1) {
              // Clear badge immediately when navigating to messages tab
              for (var c in _conversations) {
                if (c is Map) {
                  c['unread_count'] = 0;
                }
              }
            }
            if (index == 2) {
              // Clear badge for events tab
              for (var appt in _appointments) {
                if (appt is Map && appt['statut'] == 'en_attente') {
                  final id = int.tryParse(appt['id']?.toString() ?? '');
                  if (id != null) {
                    _viewedAppointmentIds.add(id);
                  }
                }
              }
            }
          });
        },
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.seaBlue, // Sea Blue for active nav
        unselectedItemColor: Colors.grey[400],
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        elevation: 0,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: _totalUnreadMessages > 0
                ? Badge(
                    label: Text(
                      _totalUnreadMessages > 99
                          ? '99+'
                          : _totalUnreadMessages.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.chat_bubble_outline_rounded),
                  )
                : const Icon(Icons.chat_bubble_outline_rounded),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: _totalPendingAppointments > 0
                ? Badge(
                    label: Text(
                      _totalPendingAppointments > 99
                          ? '99+'
                          : _totalPendingAppointments.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.calendar_today_rounded),
                  )
                : const Icon(Icons.calendar_today_rounded),
            label: 'Événements',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}


