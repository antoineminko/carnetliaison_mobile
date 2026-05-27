import 'package:flutter/material.dart';
import 'dart:async'; // Added for Timer
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/features/parent/pages/calendar_page.dart';
import 'package:app_mobile/features/parent/pages/child_details_page.dart';
import 'package:app_mobile/features/parent/pages/textbook_page.dart';
import 'package:app_mobile/features/parent/widgets/child_details_view.dart';
import 'package:app_mobile/shared/config/school_config.dart';
import 'package:app_mobile/shared/widgets/background_wrapper.dart';
import 'package:app_mobile/features/auth/pages/qr_scan_page.dart';
import 'package:app_mobile/features/auth/pages/link_child_page.dart';
import 'package:app_mobile/features/auth/services/auth_service.dart';
import 'package:app_mobile/features/parent/services/parent_service.dart';

class ParentHomePage extends StatefulWidget {
  const ParentHomePage({super.key});

  @override
  State<ParentHomePage> createState() => _ParentHomePageState();
}

class _ParentHomePageState extends State<ParentHomePage> {
  static const String _apiBaseUrl = 'https://sirh.alwaysdata.net/api_carnet_liaison';
  int? _selectedChildIndex;
  Map<String, dynamic>? _selectedChild;
  bool _isDemoEmptyState = true; // Toggle pour la démo
  int _currentIndex = 0; // Index de la BottomNavigationBar
  final PageController _pubPageController = PageController();
  int _currentPubIndex = 0;
  Timer? _timer;

  // État des préférences
  bool _notifPush = true;
  bool _notifSms = false;
  bool _notifEmail = true;

  final List<Map<String, dynamic>> _childrenData = [];
  final List<Map<String, dynamic>> _fakeChildrenData = [
    {
      'name': 'Emmanuella Nguema',
      'grade': '3ème A',
      'school': SchoolConfigs.sainteTherese,
      'color': const Color(0xFF2596be),
      'image': 'assets/images/profil/eleve2.jpg',
      'notif': 2,
    },
    {
      'name': 'Junior Nguema',
      'grade': '5e Année',
      'school': SchoolConfigs.ecoleCatholique,
      'color': const Color(0xFF2596be),
      'image': 'assets/images/profil/eleve3.jpg',
      'notif': 2,
      'isLowGrade': true,
      'scienceGrade': '08/20',
      'showAlert': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startPubTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pubPageController.dispose();
    super.dispose();
  }

  void _startPubTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pubPageController.hasClients) {
        _currentPubIndex = (_currentPubIndex + 1) % 3;
        _pubPageController.animateToPage(
          _currentPubIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _loadLinkedChildren() async {
    final parentId = await AuthService.getParentId();
    if (parentId == null) return;

    try {
      final children = await ParentService.getChildren(parentId);
      if (!mounted) return;

      setState(() {
        _childrenData
          ..clear()
          ..addAll(_fakeChildrenData)
          ..addAll(children.map(_mapApiChild));
        _isDemoEmptyState = _childrenData.isEmpty;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de charger vos enfants.')),
      );
    }
  }

  Map<String, dynamic> _mapApiChild(Map<String, dynamic> child) {
    final photo = child['photo']?.toString();
    final imageUrl = photo != null && photo.isNotEmpty ? '$_apiBaseUrl/storage/$photo' : null;

    return {
      'fromApi': true,
      'id': child['id'],
      'name': '${child['prenom'] ?? ''} ${child['nom'] ?? ''}'.trim(),
      'grade': child['classe_nom'] ?? 'Classe non définie',
      'school': child['ecole_nom'] ?? 'École non définie',
      'color': const Color(0xFF2596be),
      'image': imageUrl ?? 'assets/images/profil/eleve1.jpg',
      'isNetworkImage': imageUrl != null,
      'notif': 0,
      'raw': child,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: BackgroundWrapper(child: SafeArea(child: _buildBody())),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.seaBlue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _selectedChild == null
                  ? Icons.chat_bubble_outline
                  : Icons.menu_book,
            ),
            label: _selectedChild == null ? 'Messages' : 'Cahier',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _selectedChild == null
                  ? Icons.calendar_today
                  : Icons.notifications_active,
            ),
            label: _selectedChild == null ? 'Événements' : 'Alertes',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        if (_selectedChild != null) {
          return ChildDetailsView(
            child: _selectedChild!,
            onBack: () => setState(() => _selectedChild = null),
            onGoToCalendar: () => setState(() => _currentIndex = 2),
            onShowNotifications: () => _showNotificationsModal(
              filterChildName: _selectedChild!['name'],
            ),
          );
        }
        return _buildGlobalDashboard();
      case 1:
        if (_selectedChild != null) {
          return TextbookPage(
            initialChildName: _selectedChild!['name'],
            schoolIcon: _selectedChild!['schoolIcon'],
          );
        }
        return _buildMessagesTab();
      case 2:
        if (_selectedChild != null) {
          return CalendarPage(
            childName: _selectedChild!['name'],
            childImage: _selectedChild!['image'],
            childGrade: _selectedChild!['grade'],
            childId: _selectedChild!['id'],
            initialDate: _selectedChild!['calendarDate'],
            incidents: _selectedChild!['incidents'] != null
                ? List<Map<String, dynamic>>.from(_selectedChild!['incidents'])
                : null,
          );
        }
        return _buildEventsTab();
      case 3:
        return _buildProfileView();
      default:
        return Container();
    }
  }

  /*
  Widget _buildBodyOld() {
    switch (_currentIndex) {
      case 0:
        return Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mes Enfants',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.seaBlue,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Suivi scolaire & activités',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.seaBlue.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _isDemoEmptyState ? AppTheme.seaBlue.withOpacity(0.1) : Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.swap_horiz_rounded, size: 20, color: _isDemoEmptyState ? AppTheme.seaBlue : Colors.grey[600]),
                      ),
                      const SizedBox(width: 10),
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                              ],
                            ),
                            child: const Icon(Icons.notifications_outlined, size: 28),
                          ),
                           if (!_isDemoEmptyState)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                                  child: Center(
                                    child: Text(
                                      '${_childrenData.fold<int>(0, (sum, child) => sum + (child['notif'] as int))}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 10),

            // LISTE HORIZONTALE AVATARS
            // LISTE HORIZONTALE AVATARS
            if (!_isDemoEmptyState)
              _buildAvatarSection(),
              
            const SizedBox(height: 25),

            // DASHBOARD CONTENU
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _isDemoEmptyState 
                    ? _buildEmptyState()
                    : _buildChildrenList(), // Liste verticale des cartes complètes
              ),
            ),
          ],
        );
      case 1:
        return const TextbookPage();
      case 2:
        return const Center(child: Text('Événements (À venir)'));
      case 3:
        return _buildProfileView();
      default:
        return Container();
    }
  }
  */

  Widget _buildGlobalDashboard() {
    return Column(
      children: [
        // HEADER
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mes Enfants',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.seaBlue,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Suivi scolaire & activités',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.seaBlue.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // TOGGLE BUTTON (Demo)
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isDemoEmptyState = !_isDemoEmptyState;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _isDemoEmptyState
                                ? 'Mode Démo: Aucun enfant (Interface 3)'
                                : 'Mode Démo: Enfants chargés',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _isDemoEmptyState
                            ? AppTheme.seaBlue.withOpacity(0.1)
                            : Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.swap_horiz_rounded,
                        size: 20,
                        color: _isDemoEmptyState
                            ? AppTheme.seaBlue
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () => _showNotificationsModal(),
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            size: 28,
                          ),
                        ),
                        if (!_isDemoEmptyState)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Center(
                                child: Text(
                                  '${_childrenData.fold<int>(0, (sum, child) => sum + (child['notif'] as int))}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // LISTE HORIZONTALE AVATARS
        if (!_isDemoEmptyState) _buildAvatarSection(),

        const SizedBox(height: 25),

        // DASHBOARD CONTENU
        Expanded(
          child: SingleChildScrollView(
            // On enlève le padding du SingleChildScrollView pour que les box puissent être plus larges
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                _buildPromoBanner(),
                const SizedBox(height: 20),
                _isDemoEmptyState
                    ? _buildEmptyState()
                    : _buildChildrenList(), // Liste verticale des cartes complètes
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Centré
          Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.seaBlue.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/profil/parent.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.forestGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const Text(
                  'Ewosso D-Gall',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Parent d\'élève',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // SECTION MES INFORMATIONS
          _buildSectionTitle('MES INFORMATIONS'),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                _buildInfoTile(
                  Icons.email_outlined,
                  'EMAIL',
                  'dgall.ewosso@email.com',
                ),
                const Divider(height: 1, indent: 50),
                _buildInfoTile(
                  Icons.phone_outlined,
                  'TÉLÉPHONE',
                  '+241 07 45 89 12',
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // SECTION MES ENFANTS
          _buildSectionTitle('MES ENFANTS'),
          SizedBox(
            height: 125, // Augmenté de 110 à 125 pour éviter l'overflow
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _childrenData.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 15),
              itemBuilder: (context, index) {
                if (index == _childrenData.length) {
                  return _buildAddChildCard();
                }
                return _buildChildProfileCard(_childrenData[index]);
              },
            ),
          ),

          const SizedBox(height: 25),

          // SECTION PREFERENCES
          _buildSectionTitle('PRÉFÉRENCES'),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSwitchTile(
                  'Notifications Push',
                  Icons.notifications_none,
                  _notifPush,
                  (v) => setState(() => _notifPush = v),
                ),
                const Divider(height: 1, indent: 50),
                _buildSwitchTile(
                  'Alertes par SMS',
                  Icons.sms_outlined,
                  _notifSms,
                  (v) => setState(() => _notifSms = v),
                ),
                const Divider(height: 1, indent: 50),
                _buildSwitchTile(
                  'Email',
                  Icons.alternate_email,
                  _notifEmail,
                  (v) => setState(() => _notifEmail = v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // BOUTONS BAS DE PAGE
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                ),
              ],
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.lock_outline, color: AppTheme.seaBlue),
              ),
              title: const Text(
                'Changer le mot de passe',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppTheme.textGrey,
              ),
              onTap: () {},
            ),
          ),

          const SizedBox(height: 15),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(color: Colors.red.withOpacity(0.02), blurRadius: 10),
              ],
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.logout_rounded, color: Colors.red),
              ),
              title: const Text(
                'Se déconnecter',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.red,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.redAccent,
              ),
              onTap: () {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (route) => false);
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 5),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.seaBlue,
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.seaBlue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.seaBlue, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textGrey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildProfileCard(Map<String, dynamic> child) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: child['color'],
              image: DecorationImage(
                image: (child['isNetworkImage'] == true)
                    ? NetworkImage(child['image'] as String)
                    : AssetImage(child['image'] as String) as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            child['name'],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            child['grade'],
            style: const TextStyle(
              color: AppTheme.seaBlue,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddChildCard() {
    return GestureDetector(
      onTap: _showAddChildModal,
      child: Container(
        width: 100, // Carré avec bordure pointillée
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.seaBlue.withOpacity(0.3),
            style: BorderStyle.solid,
          ), // Pointillé simulé par dash non dispo simplement
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add, color: AppTheme.seaBlue, size: 30),
            const SizedBox(height: 5),
            Text(
              'Ajouter',
              style: TextStyle(
                color: AppTheme.seaBlue,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(icon, color: AppTheme.seaBlue),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.forestGreen,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: AppTheme.seaBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.school_rounded,
                size: 80,
                color: AppTheme.seaBlue.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Bonjour Ewosso D-Gall 👋',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Aucun enfant associé à votre compte.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pour accéder aux informations scolaires,\najoutez un enfant à votre espace parent.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _showAddChildModal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.forestGreen,
                  elevation: 5,
                  shadowColor: AppTheme.forestGreen.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Ajouter un enfant',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isDemoEmptyState ? 'Bienvenue' : 'Mes Enfants',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isDemoEmptyState ? 'Espace Parent' : 'Portail Multi-Écoles',
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppTheme.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              // BOUTON DEMO SWITCH
              InkWell(
                onTap: () {
                  setState(() {
                    _isDemoEmptyState = !_isDemoEmptyState;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _isDemoEmptyState
                            ? 'Mode Démo: Aucun enfant'
                            : 'Mode Démo: Enfants chargés',
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isDemoEmptyState
                        ? AppTheme.seaBlue.withOpacity(0.1)
                        : Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.swap_horiz_rounded,
                    size: 20,
                    color: _isDemoEmptyState
                        ? AppTheme.seaBlue
                        : Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () => _showNotificationsModal(),
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.notifications_outlined, size: 28),
                    ),
                    if (!_isDemoEmptyState)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Center(
                            child: Text(
                              '${_childrenData.fold<int>(0, (sum, child) => sum + (child['notif'] as int))}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _childrenData.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 20),
        itemBuilder: (context, index) {
          if (index == _childrenData.length) {
            return _buildAddAvatar(); // Bouton Ajouter
          }
          final child = _childrenData[index];
          return GestureDetector(
            onTap: () => _onChildSelected(index),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: child['color'] as Color,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: (child['isNetworkImage'] == true)
                            ? Image.network(
                                child['image'] as String,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 35,
                                ),
                              )
                            : Image.asset(
                                child['image'] as String,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 35,
                                ),
                              ),
                      ),
                    ),
                    if ((child['notif'] as int) > 0)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Text(
                            '${child['notif']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  child['name'] as String,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontWeight: index == 0 ? FontWeight.bold : FontWeight.w500,
                    color: index == 0 ? Colors.blue[800] : Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddAvatar() {
    return GestureDetector(
      onTap: _showAddChildModal,
      child: Column(
        children: [
          Container(
            width: 60, // Réduit (était 70)
            height: 60,
            margin: const EdgeInsets.only(top: 5), // Alignement visuel
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: Colors.blueAccent,
                width: 2,
              ), // Bleu rayonnant
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.add, color: Colors.blueAccent, size: 28),
          ),
          const SizedBox(height: 15), // Ajusté
          Text(
            'Ajouter',
            style: TextStyle(
              color: Colors.blue[300],
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _onChildSelected(int index) {
    setState(() {
      _selectedChildIndex = index;
      if (index < _childrenData.length) {
        _childrenData[index]['notif'] = 0;
      }

      final currentChild = index < _childrenData.length ? _childrenData[index] : null;
      if (currentChild != null && currentChild['fromApi'] == true) {
        _selectedChild = {
          'name': currentChild['name'],
          'grade': currentChild['grade'],
          'id': '#${currentChild['id']}',
          'image': currentChild['image'],
          'newsImage': 'assets/images/profil/actualité/actu1.png',
          'school': currentChild['school'],
          'schoolIcon': 'assets/images/iconEcole/icon1.jpg',
          'newsTitle': 'Espace parent connecté',
          'newsContent': 'Votre enfant est maintenant lié à votre compte.',
          'status': 'Présent',
          'statusColor': Colors.green,
          'arrivalTime': '08:00',
          'feesOwed': '0 FCFA',
          'homeworks': [],
          'notifications': [],
          'calendarDate': 'Mars 2026',
          'incidents': [],
        };
        return;
      }

      switch (index) {
        case 0: // YANNICK — Notre Dame de Quaben, Terminale C
          _selectedChild = {
            'name': 'Yannick Nguema',
            'grade': 'Tle C',
            'id': '#8829',
            'image': 'assets/images/profil/eleve1.jpg',
            'newsImage': 'assets/images/profil/actualité/actu1.png',
            'school': 'Notre Dame de Quaben',
            'schoolIcon': 'assets/images/iconEcole/icon1.jpg',
            'newsTitle': 'Conférence Orientation Terminale — Campus France',
            'newsContent':
                'Une réunion d\'information sur les procédures Campus France et les études supérieures à l\'étranger sera organisée le 20 Mars.',
            'status': 'Présent',
            'statusColor': Colors.green,
            'arrivalTime': '07:45',
            'feesOwed': '125 000 FCFA',
            'homeworks': [
              {
                'subject': 'Physique',
                'topic': 'Cinématique',
                'time': '08:00 - 12:00',
                'color': Colors.orange,
                'type': 'Devoir sur table',
                'description':
                    'Chapitre 2: Trajectoires et vecteurs vitesse. Calculs obligatoires. (M. Mvondo)',
              },
              {
                'subject': 'Mathématiques',
                'topic': 'Étude de fonction',
                'time': '12:30 - 14:00',
                'color': Colors.blue,
                'type': 'Devoir maison',
                'description':
                    'Exercices 42 à 45 page 128. À rendre au propre. (M. Obiang)',
              },
              {
                'subject': 'SVT',
                'topic': 'Génétique — Hérédité',
                'time': '15:00 - 17:00',
                'color': Colors.redAccent,
                'type': 'Devoir maison',
                'description':
                    'Analyse de l\'arbre généalogique p.88. (M. Okoro)',
              },
            ],
            'notifications': [
              {
                'title': 'Frais scolarité impayés important : 125 000 FCFA !',
                'icon': Icons.account_balance_wallet_outlined,
                'color': const Color(0xFF2596be),
                'type': 'FINANCE',
                'tabIndex': 5,
              },
              {
                'title': 'SVT : Chute de note 15 a 08/20 !',
                'icon': Icons.trending_down_rounded,
                'color': Colors.red,
                'type': 'NOTE',
                'tabIndex': 4,
              },
            ],
            'calendarDate': 'Mars 2026',
            'incidents': [
              {
                'icon': Icons.calendar_today_outlined,
                'color': Colors.redAccent,
                'title': 'Absence non justifiée',
                'subtitle': '24 Fév • Cours de SVT • 09:00',
                'btnText': 'Justifier',
              },
              {
                'icon': Icons.access_time,
                'color': Colors.orange,
                'title': 'Retard (15 min)',
                'subtitle': '03 Fév • Physique • 08:15',
                'btnText': 'Ignorer',
              },
            ],
          };
          break;
        case 1: // EMMANUELLA — École Catholique Saint-Joseph, 3ème
          _selectedChild = {
            'name': 'Emmanuella Nguema',
            'grade': '3ème',
            'id': '#9021',
            'image': 'assets/images/profil/eleve2.jpg',
            'newsImage': 'assets/images/profil/actualité/actu2.jpg',
            'school': SchoolConfigs.sainteTherese,
            'schoolIcon': 'assets/images/iconEcole/icon2.jpg',
            'newsTitle': 'Dédicace œuvre d\'art Jonas de Pierre',
            'newsContent':
                'Une rencontre exceptionnelle avec l\'artiste Jonas de Pierre pour la dédicace de sa dernière œuvre. Vendredi à 14h.',
            'status': 'Absente',
            'statusColor': Colors.grey,
            'arrivalTime': '--:--',
            'showScienceQuiz': true,
            'scienceGrade': '14/20',
            'quizDetails': 'Note interrogation en Physique-Chimie',
            'homeworks': [
              {
                'subject': 'Physique-Chimie',
                'topic': 'Les ions',
                'time': 'Demain 10:00',
                'color': Colors.green,
                'type': 'Devoir maison',
                'description':
                    'Réaliser le compte-rendu du TP n°3. (M. Abessolo)',
              },
              {
                'subject': 'Anglais',
                'topic': 'Vocabulary Test',
                'time': 'Vendredi 09:00',
                'color': Colors.indigo,
                'type': 'Interrogation',
                'description': 'Chapitre 5 : Travel & Culture. (Miss Sarah)',
              },
            ],
            'notifications': [
              {
                'title': 'Bulletin T3 disponible — À consulter !',
                'icon': Icons.assignment_turned_in,
                'color': Colors.blue,
                'type': 'BULLETIN',
                'tabIndex': 5,
                'bulletinImage': 'assets/bulletin/1.png',
              },
              {
                'title': 'Dédicace Jonas de Pierre — Vendredi 14h',
                'icon': Icons.palette_outlined,
                'color': Colors.purple,
                'type': 'ACTU',
                'tabIndex': 1,
              },
            ],
            'calendarDate': 'Février 2026',
            'incidents': [],
          };
          break;
        case 1: // JUNIOR — Collège Saint-Dominique, 5e Année
          _selectedChild = {
            'name': 'Junior Nguema',
            'grade': '5e Année',
            'id': '#7743',
            'image': 'assets/images/profil/eleve3.jpg',
            'newsImage': 'assets/images/profil/actualité/actu3.jpg',
            'school': SchoolConfigs.ecoleCatholique,
            'schoolIcon': 'assets/images/iconEcole/icon3.jpg',
            'newsTitle':
                'Visite de l\'asso. du collectif des sportifs handicapés',
            'newsContent':
                'Une journée de sensibilisation et d\'échange avec les membres de l\'association. Samedi 08 Mars.',
            'status': 'En retard',
            'statusColor': Colors.red,
            'arrivalTime': '09:30',
            'homeworks': [
              {
                'subject': 'Français',
                'topic': 'Dictée préparée',
                'time': '08:00 - 10:00',
                'color': Colors.redAccent,
                'status': 'Raté (Arrivé 09:30)',
                'type': 'Devoir en classe',
                'description':
                    'Dictée préparée sur les accords du participe passé. (Mme Eyi)',
              },
            ],
            'notifications': [
              {
                'title': 'Convocation Mme Marie Eyi (Français) — RDV Visio',
                'icon': Icons.videocam_outlined,
                'color': Colors.red,
                'type': 'PROF',
                'tabIndex': 5,
              },
              {
                'title': 'Convocation Administration — Suite désordres Junior',
                'icon': Icons.gavel_rounded,
                'color': const Color(0xFF2596be),
                'type': 'ADMIN',
                'tabIndex': 5,
              },
              {
                'title': 'Visite asso. sportifs handicapés — Samedi',
                'icon': Icons.sports_handball_outlined,
                'color': AppTheme.forestGreen,
                'type': 'ACTU',
                'tabIndex': 1,
              },
            ],
            'incidents': [
              {
                'icon': Icons.access_time,
                'color': Colors.redAccent,
                'title': 'Retard enregistré',
                'subtitle': 'Aujourd\'hui • 09:30 • Français',
                'btnText': 'Justifier',
              },
            ],
          };
          break;
        default:
          final child = _childrenData[index];
          _selectedChild = {
            'name': child['name'],
            'grade': child['grade'],
            'id': child['id'] != null ? '#${child['id']}' : '#0000',
            'image': child['image'] ?? 'assets/images/profil/eleve1.jpg',
            'newsImage': 'assets/images/profil/actualité/actu1.png',
            'school': child['school'],
            'schoolIcon': 'assets/images/iconEcole/icon1.jpg',
            'newsTitle': 'Nouvel enfant ajouté',
            'newsContent': 'Aucune actualité récente pour le moment.',
            'status': 'Présent',
            'statusColor': Colors.green,
            'arrivalTime': '08:00',
            'feesOwed': '0 FCFA',
            'homeworks': [],
            'notifications': [],
            'incidents': []
          };
      }
    });
  }

  Widget _buildConvocationBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.sunYellow, AppTheme.sunYellow.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppTheme.sunYellow.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.white,
            size: 30,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CONVOCATION URGENTE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Mme Eyi (Français) souhaite vous rencontrer pour le suivi de Junior.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.sunYellow,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'VOIR',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    final List<String> pubImages = [
      'assets/publicit/pub1.jpg',
      'assets/publicit/pub2.jpg',
      'assets/publicit/pub3.jpg',
    ];

    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: PageView.builder(
          controller: _pubPageController,
          itemCount: pubImages.length,
          onPageChanged: (index) => _currentPubIndex = index,
          itemBuilder: (context, index) {
            return Image.asset(
              pubImages[index],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[200],
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.grey,
                  size: 40,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildChildrenList() {
    return Column(
      children: _childrenData.asMap().entries.map((entry) {
        final int index = entry.key;
        final Map<String, dynamic> child = entry.value;
        return _ChildCard(
          index: index,
          name: child['name'],
          grade: child['grade'],
          school: child['school'],
          image: child['image'] ?? 'assets/images/profil/eleve1.jpg',
          isNetworkImage: child['isNetworkImage'] == true,
          avatarColor: child['color'] ?? const Color(0xFF2596be),
          notifCount: child['notif'] ?? 0,
          isSelected: _selectedChildIndex == index,
          onTap: () => _onChildSelected(index),
        );
      }).toList(),
    );
  }

  Widget _buildAddChildButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: GestureDetector(
        onTap: _showAddChildModal,
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFFEDF7FF),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.blue.withOpacity(0.3),
              width: 1.5,
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.person_add_alt_1_rounded, color: Colors.blue),
              SizedBox(width: 10),
              Text(
                'Ajouter un enfant',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationsModal({String? filterChildName}) {
    // Liste brute des notifications
    final List<Map<String, dynamic>> allNotifications = [];

    // Filtrer si nécessaire (on compare avec le prénom pour la démo)
    final filteredNotifications = filterChildName == null
        ? allNotifications
        : allNotifications
              .where(
                (n) => (n['child'] as String).contains(
                  filterChildName.split(' ')[0],
                ),
              )
              .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'NOTIFICATIONS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.seaBlue,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: filteredNotifications.isEmpty
                  ? Center(
                      child: Text(
                        'Aucune notification pour $filterChildName',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: filteredNotifications.length,
                      itemBuilder: (context, index) {
                        final n = filteredNotifications[index];
                        return _buildNotificationItem(
                          title: n['title'],
                          type: n['type'] ?? 'INFO',
                          child: n['child'],
                          school: n['school'],
                          sender: n['sender'],
                          time: n['time'],
                          color: n['isAlert'] == true ? Colors.red : n['color'],
                          icon: n['icon'],
                          showJustify: n['showJustify'] ?? false,
                          isAppointmentRequest:
                              n['isAppointmentRequest'] ?? false,
                          message: n['message'],
                          isAlert: n['isAlert'] ?? false,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String type,
    required String child,
    required String school,
    required String sender,
    required String time,
    required Color color,
    required IconData icon,
    bool showJustify = false,
    bool isAppointmentRequest = false,
    String? message,
    bool isAlert = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAlert ? Colors.red.withOpacity(0.02) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isAlert ? Border.all(color: Colors.red.withOpacity(0.1)) : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isAlert
                                ? Colors.red
                                : color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            type,
                            style: TextStyle(
                              color: isAlert ? Colors.white : color,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        Text(
                          time,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    if (message != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                        child: Text(
                          message,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            color: isAlert
                                ? Colors.red[900]
                                : AppTheme.textDark,
                          ),
                        ),
                      ),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 12,
                        ),
                        children: [
                          const TextSpan(text: 'Détails: '),
                          TextSpan(
                            text: child,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.seaBlue,
                            ),
                          ),
                          TextSpan(
                            text: ' • $school',
                            style: const TextStyle(color: AppTheme.textGrey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Émetteur: $sender',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isAppointmentRequest) ...[
            const SizedBox(height: 15),
            Row(
              children: [
                const SizedBox(width: 49),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: const [
                              Icon(Icons.check_circle, color: Colors.white),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'RDV accepté ! Il a été ajouté à vos événements.',
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.seaBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'ACCEPTER',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.seaBlue,
                      side: const BorderSide(color: AppTheme.seaBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'REPORTER',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (showJustify) ...[
            const SizedBox(height: 15),
            Row(
              children: [
                const SizedBox(width: 49),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // On simule l'ouverture du modal d'absence déjà existant dans ChildDetailsView
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Ouverture du formulaire de justification...',
                          ),
                          backgroundColor: AppTheme.seaBlue,
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: color.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Justifier l\'absence',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showAddChildModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.60,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      'Ajouter un enfant',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Choisissez une méthode pour ajouter votre enfant',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 30),

                    // Carte 1: Scanner
                    _buildMethodCard(
                      icon: Icons.qr_code_scanner,
                      title: 'Scanner un QR Code',
                      subtitle: 'Scannez le code fourni par l\'école',
                      color: Colors.blue,
                      onTap: () async {
                        Navigator.pop(context);
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const QrScanPage()),
                        );
                        if (result != null && result is Map) {
                          await _loadLinkedChildren();
                        }
                      },
                    ),

                    const SizedBox(height: 20),

                    // Carte 2: Manuellement
                    _buildMethodCard(
                      icon: Icons.edit_note_rounded,
                      title: 'Entrer les informations manuellement',
                      subtitle: 'Saisissez le code élève et l\'établissement',
                      color: Colors.orange,
                      onTap: () async {
                        Navigator.pop(context);
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LinkChildPage()),
                        );
                        if (result != null && result is Map) {
                          await _loadLinkedChildren();
                        }
                      },
                    ),
                    const SizedBox(height: 20), // Bottom padding for scroll
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showManualEntryModal() {
    String? selectedSchool;
    final schools = [
      'Lycée Léon Mba',
      'Collège Colbert',
      'Lycée Sainte Marie',
      'Lycée d\'Etat',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text(
                        'Saisie manuelle',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Champs Manuels
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Code Élève',
                          prefixIcon: const Icon(Icons.pin),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        value: selectedSchool,
                        decoration: InputDecoration(
                          labelText: 'Nom de l\'établissement',
                          prefixIcon: const Icon(Icons.school),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: schools.map((school) {
                          return DropdownMenuItem(
                            value: school,
                            child: Text(school),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedSchool = value;
                          });
                        },
                      ),
                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Enfant ajouté avec succès ! (Démo)',
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[800],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Valider',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).viewInsets.bottom + 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesTab() {
    return DefaultTabController(
      length: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text(
              'Messagerie',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
          ),
          const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppTheme.seaBlue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.seaBlue,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: [
              Tab(text: 'Tous'),
              Tab(text: 'Enseignants'),
              Tab(text: 'Administration'),
              Tab(text: 'Favoris'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildMessageList('Tous'),
                _buildMessageList('Enseignants'),
                _buildMessageList('Administration'),
                _buildMessageList('Favoris'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(String filter) {
    List<Widget> tiles = [];

    if (tiles.isEmpty) {
      return const Center(
        child: Text(
          'Aucun message rÃ©cent',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // M. Obiang (Enseignant)
    if (filter == 'Tous' || filter == 'Enseignants') {
      tiles.add(
        _buildMessageTile(
          name: 'M. Obiang',
          role: 'Enseignant — Maths',
          initials: 'OB',
          color: AppTheme.seaBlue,
          school: SchoolConfigs.notreDame,
          childName: 'Yannick',
          lastMsg: 'Je vais lui en parler ce soir, merci Professeur.',
          time: '11:05',
          unreadCount: 1,
          chatMessages: [
            {
              'sender': 'prof',
              'text':
                  'Bonjour. Je me permets de vous contacter concernant Yannick.',
              'time': '10:42',
            },
            {
              'sender': 'prof',
              'text':
                  'Prof. Okoro (SVT) vient de publier sa note pour le devoir de maison : 08/20.',
              'time': '10:43',
            },
            {
              'sender': 'prof',
              'text':
                  'C\'est une grosse chute car Yannick avait eu 15/20 au devoir précédent sur ce même chapitre de Génétique.',
              'time': '10:44',
            },
            {
              'sender': 'parent',
              'text':
                  'Bonjour M. Obiang. Merci pour l\'information. Je suis vraiment surpris !',
              'time': '11:00',
            },
            {
              'sender': 'parent',
              'text':
                  'Il avait pourtant révisé... Il a tendance à se déconcentrer en classe.',
              'time': '11:01',
            },
            {
              'sender': 'prof',
              'text':
                  'Effectivement, Prof. Okoro m\'a signalé qu\'il a passé son temps à causer avec ses camarades.',
              'time': '11:03',
            },
            {
              'sender': 'parent',
              'text': 'Je vais lui en parler ce soir, merci Professeur.',
              'time': '11:05',
            },
          ],
        ),
      );
    }

    // Administration (AD)
    if (filter == 'Tous' || filter == 'Administration') {
      tiles.add(
        _buildMessageTile(
          name: 'Administration',
          role: 'Service Financier',
          initials: 'AD',
          color: AppTheme.forestGreen,
          school: SchoolConfigs.notreDame,
          childName: 'Yannick',
          lastMsg: 'Merci. Nous attendons votre passage au secrétariat.',
          time: '09:15',
          unreadCount: 2,
          chatMessages: [
            {
              'sender': 'prof',
              'text':
                  'Bonjour M./Mme Nguema. Nous vous contactons concernant la situation financière de Yannick.',
              'time': '08:50',
            },
            {
              'sender': 'prof',
              'text':
                  'La tranche n°3 des frais de scolarité s\'élève à 125 000 FCFA et est toujours impayée.',
              'time': '08:51',
            },
            {
              'sender': 'prof',
              'text':
                  'L\'échéance était fixée au 05 Mars. Merci de régulariser rapidement.',
              'time': '08:52',
            },
            {
              'sender': 'parent',
              'text':
                  'Bonjour, je suis désolé pour ce retard. Je vais passer au secrétariat cette semaine.',
              'time': '09:10',
            },
            {
              'sender': 'prof',
              'text': 'Merci. Nous attendons votre passage au secrétariat.',
              'time': '09:15',
            },
          ],
        ),
      );
    }

    return ListView(padding: const EdgeInsets.all(20), children: tiles);
  }

  void _openChat(BuildContext context, Map<String, dynamic> data) {
    final rawChat = data['chatMessages'];
    final chatMessages = rawChat is List 
        ? rawChat.map((e) => e as Map<String, dynamic>).toList()
        : <Map<String, dynamic>>[];
    final Color color = data['color'] as Color;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: const Color(0xFFECF2FD),
          appBar: AppBar(
            backgroundColor: AppTheme.seaBlue,
            foregroundColor: Colors.white,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${data['childName']} • ${data['school']}',
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Column(
            children: [
              // Chip contexte
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                color: Colors.white,
                child: Text(
                  data['role'],
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: chatMessages.length,
                  itemBuilder: (context, index) {
                    final msg = chatMessages[index];
                    final isProf = msg['sender'] == 'prof';
                    return Align(
                      alignment: isProf
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.72,
                        ),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isProf ? Colors.white : color,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(18),
                            topRight: const Radius.circular(18),
                            bottomLeft: isProf
                                ? Radius.zero
                                : const Radius.circular(18),
                            bottomRight: isProf
                                ? const Radius.circular(18)
                                : Radius.zero,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: isProf
                              ? CrossAxisAlignment.start
                              : CrossAxisAlignment.end,
                          children: [
                            Text(
                              msg['text'],
                              style: TextStyle(
                                color: isProf ? Colors.black87 : Colors.white,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              msg['time'],
                              style: TextStyle(
                                color: isProf
                                    ? Colors.grey[400]
                                    : Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: const BoxDecoration(color: Colors.white),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Text(
                          'Écrire un message...',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageTile({
    required String name,
    required String role,
    required String initials,
    required Color color,
    required String school,
    required String childName,
    required String lastMsg,
    required String time,
    required int unreadCount,
    required List<Map<String, dynamic>> chatMessages,
  }) {
    return GestureDetector(
      onTap: () => _openChat(context, {
        'name': name,
        'role': role,
        'initials': initials,
        'color': color,
        'school': school,
        'childName': childName,
        'chatMessages': chatMessages,
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: color.withOpacity(0.15),
                  child: Text(
                    initials,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(color: Colors.grey[400], fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$childName • $school',
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMsg,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: unreadCount > 0
                          ? AppTheme.textDark
                          : Colors.grey[500],
                      fontSize: 13,
                      fontWeight: unreadCount > 0
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Événements et Rendez-vous',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'DEMANDES DE RENDEZ-VOUS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 15),

          // RDV 1 — Yannick & M. Obiang (Maths)
          _buildRdvCard(
            teacherName: 'M. Obiang',
            subject: 'Mathématiques',
            meetingType: 'Présentiel',
            childName: 'Yannick Nguema',
            school: 'Notre Dame de Quaben',
            motif:
                'Yannick a eu une chute de note importante en SVT (15/20 → 08/20). Une rencontre est nécessaire pour comprendre les difficultés et mettre en place un plan de soutien.',
            date: 'Proposé pour le 19 Mars à 14h00',
            color: AppTheme.seaBlue,
            initials: 'OB',
          ),
          const SizedBox(height: 15),

          // RDV 2 — Junior & Mme Eyi (Français)
          _buildRdvCard(
            teacherName: 'Mme Eyi',
            subject: 'Français',
            meetingType: 'Visioconférence',
            childName: 'Junior Nguema',
            school: 'Scolaire Bambino Village',
            motif:
                'Junior Nguema est arrivé en retard (09:30) et a raté le devoir en classe de Français (Dictée préparée). La note enregistrée est 00/20. Une réunion s\'impose pour traiter l\'absentéisme.',
            date: 'Proposé pour le 18 Mars à 16h00',
            color: Colors.orange,
            initials: 'EY',
          ),

          const SizedBox(height: 30),
          const Text(
            'ÉVÉNEMENTS DES ÉTABLISSEMENTS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 15),

          _buildEventSmallCard(
            title: 'Visite Asso. Sportifs Handicapés',
            date: 'Samedi 08 Mars',
            location: 'Scolaire Bambino Village',
            color: AppTheme.forestGreen,
          ),
          const SizedBox(height: 12),
          _buildEventSmallCard(
            title: 'Dédicace Jonas de Pierre',
            date: 'Vendredi 14 Mars, 14h00',
            location: SchoolConfigs.sainteTherese,
            color: Colors.purple,
          ),
          const SizedBox(height: 12),
          _buildEventSmallCard(
            title: 'Réunion Orientation Campus France',
            date: 'Jeudi 20 Mars, 15h00',
            location: 'Notre Dame de Quaben',
            color: AppTheme.seaBlue,
          ),
          const SizedBox(height: 12),
          _buildEventSmallCard(
            title: 'Assemblée Générale Trimestrielle',
            date: 'Vendredi 28 Mars, 17h00',
            location: 'Tous les établissements',
            color: AppTheme.sunYellow,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildRdvCard({
    required String teacherName,
    required String subject,
    required String meetingType,
    required String childName,
    required String school,
    required String motif,
    required String date,
    required Color color,
    required String initials,
  }) {
    return StatefulBuilder(
      builder: (context, setCardState) {
        bool showMotif = false;
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: color.withOpacity(0.12),
                    radius: 22,
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          teacherName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '$subject — $meetingType',
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Icône œil pour afficher motif
                  GestureDetector(
                    onTap: () => setCardState(() => showMotif = !showMotif),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        showMotif
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: color,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 13,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    childName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.school_outlined,
                    size: 13,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      school,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 13,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              // Motif visible si œil cliqué
              if (showMotif) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MOTIF',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        motif,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'RDV accepté avec $teacherName pour $childName',
                              ),
                              backgroundColor: AppTheme.forestGreen,
                            ),
                          ),
                      icon: const Icon(Icons.check_circle_outline, size: 16),
                      label: const Text(
                        'ACCEPTER',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.forestGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('RDV avec $teacherName reporté'),
                              backgroundColor: Colors.orange,
                            ),
                          ),
                      icon: const Icon(Icons.schedule_outlined, size: 16),
                      label: const Text(
                        'REPORTER',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventSmallCard({
    required String title,
    required String date,
    required String location,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 5),
                    Text(
                      date,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  final int index;
  final String name;
  final String grade;
  final String school;
  final String image;
  final bool isNetworkImage;
  final Color avatarColor;
  final int notifCount;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChildCard({
    required this.index,
    required this.name,
    required this.grade,
    required this.school,
    required this.image,
    this.isNetworkImage = false,
    required this.avatarColor,
    this.notifCount = 0,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryThemeColor = const Color(0xFF2596be);
    final Color gradeColor = primaryThemeColor.withOpacity(0.1);
    final Color gradeTextColor = primaryThemeColor;
    final Color badgeColor = primaryThemeColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? Border.all(color: primaryThemeColor, width: 2)
              : Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? primaryThemeColor.withOpacity(0.15)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: avatarColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: isNetworkImage
                              ? Image.network(
                                  image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const SizedBox(),
                                )
                              : Image.asset(
                                  image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const SizedBox(),
                                ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected
                                          ? primaryThemeColor
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: gradeColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                grade,
                                style: TextStyle(
                                  color: gradeTextColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(
                                  Icons.school,
                                  size: 16,
                                  color: primaryThemeColor,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    school,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? primaryThemeColor.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? primaryThemeColor
                            : Colors.white,
                        foregroundColor: isSelected
                            ? Colors.white
                            : Colors.black87,
                        elevation: 0,
                        side: isSelected
                            ? BorderSide.none
                            : BorderSide(color: Colors.grey[300]!, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isSelected ? 'Sélectionné' : 'Sélectionner',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (notifCount > 0)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(24),
                      bottomLeft: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: badgeColor.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    '$notifCount message${notifCount > 1 ? 's' : ''}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
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
}

