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
import 'package:app_mobile/features/parent/pages/chat_page.dart';
import 'package:app_mobile/shared/config/api_client.dart';
import 'package:app_mobile/shared/config/api_endpoints.dart';
import 'package:app_mobile/features/notifications/services/notification_storage.dart';
import 'package:app_mobile/features/notifications/services/notifications_service.dart';
import 'package:app_mobile/features/appointments/pages/appointments_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParentHomePage extends StatefulWidget {
  final Map<String, dynamic>? arguments;
  const ParentHomePage({super.key, this.arguments});

  @override
  State<ParentHomePage> createState() => _ParentHomePageState();
}

class _ParentHomePageState extends State<ParentHomePage> {
  static const String _apiBaseUrl =
      'https://sirh.alwaysdata.net/api_carnet_liaison';
  int? _selectedChildIndex;
  Map<String, dynamic>? _selectedChild;
  bool _isDemoEmptyState = true;
  bool _forceAddChild = false;
  bool _isLoadingChildren = true;
  int _currentIndex = 0;
  int _childInitialTab = 0;
  final PageController _pubPageController = PageController();
  int _currentPubIndex = 0;
  Timer? _timer;

 
  bool _notifPush = true;
  bool _notifSms = false;
  bool _notifEmail = true;

  final List<Map<String, dynamic>> _childrenData = [];

  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _conversationRequests = [];
  List<Map<String, dynamic>> _apiNotifications = [];
  List<Map<String, dynamic>> _adminConversations = [];
  List<Map<String, dynamic>> _teacherConversationsAll = [];
  bool _isLoadingEvents = true;
  String? _pendingSelectChildName;
  int? _pendingChildInitialTab;
  int? _pendingSelectChildId;
  String? _pendingHighlightIncidentId;
  String? _pendingHighlightHomeworkId;
  Map<String, dynamic>? _notificationPayload;
  String? _parentFirstName;
  String? _parentLastName;
  String? _parentAvatarUrl;
  String? _parentEmail;
  String? _parentPhone;
  int _unreadNotificationsCount = 0;

  void _selectChildByName(String childName, int initialTab) {
    final idx = _childrenData.indexWhere((c) =>
        (c['name'] as String).toLowerCase().contains(childName.toLowerCase()));
    if (idx != -1) {
      setState(() {
        _childInitialTab = initialTab;
      });
      _onChildSelected(idx);
    }
  }

  Future<void> _loadParentProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _parentFirstName = prefs.getString('parent_prenom');
      _parentLastName = prefs.getString('parent_nom');
      _parentAvatarUrl = prefs.getString('parent_avatar_url');
      _parentEmail = prefs.getString('parent_email');
      _parentPhone = prefs.getString('parent_telephone');
    });
  }

  void _selectChildById(int childId, int initialTab) {
    final idx = _childrenData.indexWhere((c) => c['id'] == childId);
    if (idx != -1) {
      setState(() {
        _childInitialTab = initialTab;
      });
      _onChildSelected(idx);
    }
  }

  @override
  void initState() {
    super.initState();
    print('📥 [ParentHomePage] Arguments reçus: ${widget.arguments}');
    if (widget.arguments != null) {
      if (widget.arguments!['initialTab'] != null) {
        _currentIndex = widget.arguments!['initialTab'];
      }
      if (widget.arguments!['selectChildName'] != null) {
        _pendingSelectChildName = widget.arguments!['selectChildName'];
        _pendingChildInitialTab = widget.arguments!['childInitialTab'] ?? 0;
        _pendingHighlightIncidentId = widget.arguments!['highlightIncidentId'];
        _pendingHighlightHomeworkId = widget.arguments!['highlightHomeworkId'];
      }
      if (widget.arguments!['openNotifications'] == true) {
        _notificationPayload = widget.arguments!['notificationPayload'];
        print('📥 [ParentHomePage] openNotifications=true, payload: $_notificationPayload');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          print('📥 [ParentHomePage] Ouverture modal notifications');
          _showNotificationsModal(
            incidentPayload: _notificationPayload?.containsKey('type') == true && _notificationPayload!['type'] == 'incident'
                ? _notificationPayload
                : null,
          );
        });
      }

      // Ouvrir la page des rendez-vous depuis une notification
      if (widget.arguments!['openAppointments'] == true) {
        final int? appointmentId = widget.arguments!['highlightAppointmentId'];
        final bool isPostponed = widget.arguments!['isPostponed'] == true;
        print('📥 [ParentHomePage] openAppointments=true, appointmentId: $appointmentId, isPostponed: $isPostponed');

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final parentId = await AuthService.getParentId();
          if (parentId != null && mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AppointmentsListPage(
                  userId: parentId,
                  userRole: 'parent',
                  initialAppointmentId: appointmentId,
                ),
              ),
            );
          }
        });
      }

      // Gérer les notifications de messagerie
      if (widget.arguments!['openConversationId'] != null) {
        final String? conversationId = widget.arguments!['openConversationId'];
        final bool showValidation = widget.arguments!['showConversationValidation'] == true;
        final String? conversationStatus = widget.arguments!['conversationStatus'];
        final String? enseignantNom = widget.arguments!['enseignant_nom'];
        final String? subject = widget.arguments!['subject'];

        print('📥 [ParentHomePage] openConversationId=$conversationId, showValidation=$showValidation');

        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (mounted && conversationId != null) {
            // Naviguer directement vers le chat
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  conversation: {
                    'conversation_id': int.tryParse(conversationId),
                    'id': int.tryParse(conversationId),
                    'enseignant_nom': enseignantNom ?? 'Enseignant',
                    'subject': subject ?? 'Discussion',
                    'status': conversationStatus ?? 'pending',
                  },
                ),
              ),
            );
          }
        });
      }

      // Afficher notification de refus de conversation
      if (widget.arguments!['showRejectionNotification'] == true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ La demande de discussion a été refusée'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 5),
              ),
            );
          }
        });
      }
      if (widget.arguments!['forceAddChild'] == true) {
        _forceAddChild = true;
      }
    }
    _startPubTimer();
    _loadParentProfile();
    _loadLinkedChildren();
    _fetchEvents();
    _fetchNotifications();
    _fetchConversations();
    _loadUnreadNotificationsCount();
    
    // Enregistrer le callback pour les nouvelles notifications
    NotificationsService().setOnNotificationReceived(() {
      _loadUnreadNotificationsCount();
    });
  }

  Future<void> _loadUnreadNotificationsCount() async {
    final count = await NotificationStorage.getUnreadCount();
    setState(() {
      _unreadNotificationsCount = count;
    });
  }

  Future<void> _openNotificationsModal() async {
    // Marquer toutes les notifications comme lues
    await NotificationStorage.markAllAsRead();
    // Reset le compteur
    setState(() {
      _unreadNotificationsCount = 0;
    });
    // Ouvrir le modal
    _showNotificationsModal();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pubPageController.dispose();
    super.dispose();
  }

  Future<void> _refreshDashboard() async {
    await Future.wait([
      _loadLinkedChildren(),
      _fetchEvents(),
      _fetchNotifications(),
      _fetchConversations(),
    ]);
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
    print(' [DEBUG] parent_id en mémoire = $parentId');
    if (parentId == null) {
      print(' [DEBUG] parent_id est NULL → impossible de charger les enfants');
      setState(() => _isLoadingChildren = false);
      return;
    }

    try {
      final children = await ParentService.getChildren(parentId);
      print(' [DEBUG] Enfants reçus de l\'API : ${children.length}  $children');
      if (!mounted) return;

      setState(() {
        _childrenData
          ..clear()
          ..addAll(children.map(_mapApiChild));
        _isDemoEmptyState = children.isEmpty;
        _isLoadingChildren = false;
      });

      if (_pendingSelectChildName != null && _childrenData.isNotEmpty) {
        _selectChildByName(_pendingSelectChildName!, _pendingChildInitialTab ?? 0);
        _pendingSelectChildName = null;
        _pendingChildInitialTab = null;
      }
      if (_pendingSelectChildId != null && _childrenData.isNotEmpty) {
        _selectChildById(_pendingSelectChildId!, _pendingChildInitialTab ?? 0);
        _pendingSelectChildId = null;
        _pendingChildInitialTab = null;
      }
    } catch (e) {
      print(' [DEBUG] Erreur chargement enfants : $e');
      if (!mounted) return;
      setState(() {
        _isLoadingChildren = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur chargement enfants: $e')),
      );
      // En cas d'échec critique (ex: backend indisponible/DB vidée), forcer la déconnexion propre
      await AuthService.logout();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/select_role', (route) => false);
    }
  }

  Future<void> _fetchNotifications() async {
    final parentId = await AuthService.getParentId();
    if (parentId == null) return;
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.userNotifications('parent', parentId));
      if (response.data != null && response.data['success']) {
        if (!mounted) return;
        setState(() {
          _apiNotifications = List<Map<String, dynamic>>.from(response.data['notifications'] ?? []);
        });
      }
    } catch (e) {
      debugPrint("Erreur _fetchNotifications: $e");
    }
  }

  Future<void> _fetchConversations() async {
    final parentId = await AuthService.getParentId();
    if (parentId == null) return;
    try {
      final response = await ApiClient.instance.get(ApiEndpoints.parentConversations(parentId));
      if (response.data != null && response.data['success']) {
        final List<Map<String, dynamic>> all = List<Map<String, dynamic>>.from(response.data['conversations'] ?? []);
        if (!mounted) return;
        setState(() {
         
          _adminConversations = all.where((c) => c['enseignant_id'] == null).toList();
          
          _teacherConversationsAll = all.where((c) => c['enseignant_id'] != null && (c['status'] == 'accepted' || c['status'] == 'pending')).toList();
        });

       
        if (widget.arguments != null && widget.arguments!['openConversationId'] != null) {
          final convId = widget.arguments!['openConversationId'].toString();
          final convToOpen = all.firstWhere(
            (c) => c['id'].toString() == convId,
            orElse: () => <String, dynamic>{},
          );

          if (convToOpen.isNotEmpty) {
            
            widget.arguments!.remove('openConversationId');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ChatPage(conversation: convToOpen)),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Erreur _fetchConversations: $e");
    }
  }

  Future<void> _fetchEvents() async {
    final parentId = await AuthService.getParentId();
    if (parentId == null) {
      setState(() => _isLoadingEvents = false);
      return;
    }
    
    try {
      final response = await ApiClient.instance.get('/parents/$parentId/events');
      if (response.data != null && response.data['success']) {
        if (!mounted) return;
        setState(() {
          _appointments = List<Map<String, dynamic>>.from(response.data['appointments'] ?? []);
          final allConversations = List<Map<String, dynamic>>.from(response.data['conversations'] ?? []);
          _conversationRequests = allConversations.where((c) => c['enseignant_id'] != null).toList();
          _isLoadingEvents = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingEvents = false);
    }
  }

  Future<void> _updateAppointmentStatus(int? id, String status) async {
    if (id == null) return;
    try {
      await ApiClient.instance.put('/appointments/$id/status', data: {'statut': status});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(status == 'accepte' ? 'Rendez-vous accepté' : 'Rendez-vous refusé'),
          backgroundColor: status == 'accepte' ? AppTheme.forestGreen : Colors.red,
        ),
      );
      _fetchEvents(); 
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  Map<String, dynamic> _mapApiChild(Map<String, dynamic> child) {
    final imageUrl = child['photo_url']?.toString().isNotEmpty == true
        ? child['photo_url'].toString()
        : null;

    String? status;
    Color? statusColor;
    String? arrivalTime;

    if (child['attendance_status'] != null) {
      if (child['attendance_status'] == 'present') {
        status = 'Présent';
        statusColor = Colors.green;
      } else if (child['attendance_status'] == 'absent') {
        status = 'Absent';
        statusColor = Colors.red;
      } else if (child['attendance_status'] == 'late') {
        status = 'En retard';
        statusColor = Colors.orange;
      }
    }

    if (child['arrival_time'] != null) {
      try {
        final dt = DateTime.parse(child['arrival_time']);
        arrivalTime = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {}
    }

    return {
      'fromApi': true,
      'id': child['id'],
      'name': '${child['prenom'] ?? ''} ${child['nom'] ?? ''}'.trim(),
      'prenom': child['prenom'] ?? '',
      'grade': child['classe_nom'] ?? 'Classe non définie',
      'school': child['ecole_nom'] ?? 'École non définie',
      'color': const Color(0xFF2596be),
      'image': imageUrl ?? 'assets/images/profil/eleve1.jpg',
      'isNetworkImage': imageUrl != null,
      'notif': child['notif_count'] ?? 0,
      if (status != null) 'status': status,
      if (statusColor != null) 'statusColor': statusColor,
      if (arrivalTime != null) 'arrivalTime': arrivalTime,
      'arrival_time': child['arrival_time'], // Garder la valeur originale complète pour l'affichage date
      'attendance_status': child['attendance_status'],
      'raw': child,
    };
  }

  int get _totalUnreadMessages {
    int total = 0;
    for (var c in _adminConversations) {
      final val = c['unread_count'];
      total += (val is int) ? val : (int.tryParse(val?.toString() ?? '0') ?? 0);
    }
    for (var c in _teacherConversationsAll) {
      final val = c['unread_count'];
      total += (val is int) ? val : (int.tryParse(val?.toString() ?? '0') ?? 0);
    }
    return total;
  }

  /// Nombre de rendez-vous en attente (à valider)
  int get _pendingAppointmentsCount {
    return _appointments
        .where((a) => a['statut'] == 'en_attente' || a['statut'] == 'reporte')
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final bool hasFullTabs = _childrenData.isNotEmpty && !_forceAddChild;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: BackgroundWrapper(child: SafeArea(child: _buildBody())),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: hasFullTabs
            ? _currentIndex
            : (_currentIndex == 3 ? 1 : 0),
        onTap: (index) {
          setState(() {
            if (hasFullTabs) {
              _currentIndex = index;
            } else {
              // Quand seuls "Accueil" et "Profil" sont visibles,
              // on mappe l'index 0 -> 0 (Accueil) et 1 -> 3 (Profil)
              _currentIndex = index == 0 ? 0 : 3;
            }
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
          if (hasFullTabs)
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    _selectedChild == null
                        ? Icons.message
                        : Icons.menu_book,
                  ),
                  if (_selectedChild == null && _totalUnreadMessages > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '$_totalUnreadMessages',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              label: _selectedChild == null ? 'Messages' : 'Cahier',
            ),
          if (hasFullTabs)
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    _selectedChild == null
                        ? Icons.calendar_today
                        : Icons.notifications_active,
                  ),
                  // Badge pour les RDV en attente
                  if (_selectedChild == null && _pendingAppointmentsCount > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '$_pendingAppointmentsCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
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
          final highlightIncidentId = _pendingHighlightIncidentId;
          final highlightHomeworkId = _pendingHighlightHomeworkId;
          _pendingHighlightIncidentId = null; // Reset après usage
          _pendingHighlightHomeworkId = null; // Reset après usage
          return ChildDetailsView(
            child: _selectedChild!,
            initialTab: _childInitialTab,
            highlightIncidentId: highlightIncidentId,
            highlightHomeworkId: highlightHomeworkId,
            onBack: () => setState(() {
              _selectedChild = null;
              _childInitialTab = 0;
            }),
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
          return Container(
            color: const Color(0xFFF5F7FA),
            child: const Center(
              child: Text(
                'Aucune alerte pour le moment',
                style: TextStyle(color: Colors.grey),
              ),
            ),
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
    if (_isLoadingChildren) {
      return const Center(child: CircularProgressIndicator());
    }

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
                  if (((_parentFirstName ?? '').isNotEmpty) || ((_parentLastName ?? '').isNotEmpty))
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '${_parentFirstName ?? ''} ${_parentLastName ?? ''}'.trim(),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    backgroundImage: (_parentAvatarUrl != null && _parentAvatarUrl!.isNotEmpty)
                        ? NetworkImage(_parentAvatarUrl!)
                        : null,
                    child: (_parentAvatarUrl == null || _parentAvatarUrl!.isEmpty)
                        ? const Icon(Icons.person, color: AppTheme.seaBlue)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () => _openNotificationsModal(),
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
                        if (_unreadNotificationsCount > 0)
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
                                  '$_unreadNotificationsCount',
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
        if (_childrenData.isNotEmpty && !_forceAddChild)
          _buildAvatarSection(),

        const SizedBox(height: 25),

        // DASHBOARD CONTENU (avec pull-to-refresh)
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshDashboard,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              // On enlève le padding du SingleChildScrollView pour que les box puissent être plus larges
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  _buildPromoBanner(),
                  const SizedBox(height: 20),
                  if (_childrenData.isEmpty || _forceAddChild)
                    _buildEmptyState()
                  else
                    _buildChildrenList(), // Liste verticale des cartes complètes
                ],
              ),
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
                        gradient: LinearGradient(
                          colors: [AppTheme.seaBlue, AppTheme.seaBlue.withOpacity(0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.seaBlue.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          () {
                            final f = (_parentFirstName ?? '').isNotEmpty ? _parentFirstName![0].toUpperCase() : '';
                            final l = (_parentLastName ?? '').isNotEmpty ? _parentLastName![0].toUpperCase() : '';
                            return '$f$l'.isNotEmpty ? '$f$l' : 'P';
                          }(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  '${_parentFirstName ?? ''} ${_parentLastName ?? ''}'.trim().isNotEmpty
                      ? '${_parentFirstName ?? ''} ${_parentLastName ?? ''}'.trim()
                      : 'Votre profil',
                  style: const TextStyle(
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
                  (_parentEmail != null && _parentEmail!.isNotEmpty) ? _parentEmail! : 'Non renseigné',
                ),
                const Divider(height: 1, indent: 50),
                _buildInfoTile(
                  Icons.phone_outlined,
                  'TÉLÉPHONE',
                  (_parentPhone != null && _parentPhone!.isNotEmpty) ? _parentPhone! : 'Non renseigné',
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
              itemCount: (!_forceAddChild && _childrenData.isNotEmpty)
                  ? _childrenData.length + 1
                  : 1,
              separatorBuilder: (_, __) => const SizedBox(width: 15),
              itemBuilder: (context, index) {
                final bool hasVisibleChildren = !_forceAddChild && _childrenData.isNotEmpty;
                if (_childrenData.isEmpty || _forceAddChild || index == _childrenData.length) {
                  // S'il n'y a pas d'enfant lié, on n'affiche que la carte d'ajout.
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
              onTap: () async {
                await AuthService.logout();
                if (!context.mounted) return;
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
            Text(
              'Bonjour ${_parentFirstName ?? 'Parent'} 👋',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                onTap: () => _openNotificationsModal(),
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
                    if (_unreadNotificationsCount > 0)
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
                              '$_unreadNotificationsCount',
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

      final currentChild = index < _childrenData.length
          ? _childrenData[index]
          : null;
      if (currentChild != null && currentChild['fromApi'] == true) {
        _selectedChild = {
          'name': currentChild['name'],
          'prenom': currentChild['prenom'] ?? currentChild['name'],
          'grade': currentChild['grade'],
          'raw_id': currentChild['id'],
          'id': currentChild['id'] != null ? '#${currentChild['id']}' : '#0000',
          'image': currentChild['image'],
          'isNetworkImage': currentChild['isNetworkImage'],
          'newsImage': null,
          'school': currentChild['school'],
          'schoolIcon': null,
          'newsTitle': 'Aucune actualité',
          'newsContent': 'Rien à signaler pour le moment.',
          // Utiliser les vraies valeurs de présence de l'API
          'status': currentChild['status'] ?? currentChild['attendance_status'] ?? 'En attente',
          'statusColor': currentChild['statusColor'] ?? Colors.grey,
          'arrivalTime': currentChild['arrival_time'] ?? '--:--',
          'attendance_status': currentChild['attendance_status'],
          'arrival_time': currentChild['arrival_time'],
          'feesOwed': '0 FCFA',
          'homeworks': [],
          'notifications': [],
          'calendarDate': 'Mars 2026',
          'incidents': [],
          'fromApi': true,
          'raw': currentChild['raw'],
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
            'prenom': child['prenom'] ?? child['name'],
            'grade': child['grade'],
            'raw_id': child['id'],
            'id': child['id'] != null ? '#${child['id']}' : '#0000',
            'image': child['image'] ?? 'assets/images/profil/eleve1.jpg',
            'isNetworkImage': child['isNetworkImage'] == true,
            'newsImage': null,
            'school': child['school'],
            'schoolIcon': null,
            'newsTitle': 'Aucune actualité',
            'newsContent': 'Rien à signaler pour le moment.',
            'status': child['status'] ?? 'En attente',
            'statusColor': child['statusColor'] ?? Colors.grey,
            'arrivalTime': child['arrivalTime'] ?? '--:--',
            'feesOwed': '0 FCFA',
            'homeworks': [],
            'notifications': [],
            'incidents': [],
            'fromApi': true,
            'raw': child['raw'] ?? child,
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
      'https://i.pinimg.com/736x/46/c9/7f/46c97fda08fb8c284e70704de113fa1a.jpg',
      'https://i.pinimg.com/736x/70/84/85/7084854f0a3841d6cfda063c0ad64ccc.jpg',
      'https://www.aciafrica.org/images/gabon_1642722311.jpg',
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
            return Image.network(
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

  void _showNotificationsModal({String? filterChildName, Map<String, dynamic>? incidentPayload}) async {
    print('📥 [ParentHomePage] _showNotificationsModal - incidentPayload: $incidentPayload');
    final List<Map<String, dynamic>> allNotifications = [];
    
    // Charger les notifications locales (push notifications)
    final localNotifications = await NotificationStorage.getNotifications();
    for (var n in localNotifications) {
      allNotifications.add({
        'title': n['title'] ?? 'Notification',
        'type': n['data']?['type'] == 'incident' ? 'INCIDENT' : 'INFO',
        'child': n['data']?['child_name'] ?? '',
        'school': '',
        'sender': n['data']?['enseignant_nom'] ?? '',
        'time': n['timestamp'] != null 
            ? DateTime.parse(n['timestamp']).toString().substring(0, 16).replaceFirst('T', ' ')
            : 'Récemment',
        'color': n['data']?['type'] == 'incident' ? Colors.red : Colors.blue,
        'icon': n['data']?['type'] == 'incident' ? Icons.warning : Icons.notifications,
        'message': n['body'] ?? n['message'] ?? '',
        'source': 'local',
        'data': n['data'],
        'isLocal': true,
      });
    }
    
    for (var rdv in _appointments) {
      if (rdv['statut'] == 'en_attente') {
        allNotifications.add({
          'title': 'Demande de rendez-vous',
          'type': 'RDV',
          'child': '${rdv['eleve_prenom'] ?? ''} ${rdv['eleve_nom'] ?? ''}'.trim(),
          'school': '',
          'sender': '${rdv['enseignant_prenom'] ?? ''} ${rdv['enseignant_nom'] ?? ''}'.trim(),
          'time': rdv['date_rdv'] ?? 'À définir',
          'color': AppTheme.seaBlue,
          'icon': Icons.calendar_today,
          'isAppointmentRequest': true,
          'message': rdv['motif'] ?? '',
        });
      }
    }

    // _conversationRequests retirés des notifications selon la demande de l'utilisateur

    for (var n in _apiNotifications) {
      if (n['type'] == 'teacher_message' || n['type'] == 'admin_message') {
        continue; // Ne pas afficher les messages textuels dans les notifications
      }

      // Extraire les métadonnées de la notification (type fonctionnel, classe, etc.)
      Map<String, dynamic>? dataMap;
      final dynamic rawData = n['data'];
      if (rawData is Map<String, dynamic>) {
        dataMap = rawData;
      }

      final String dataType = dataMap?['type']?.toString() ?? '';

      // Icône et couleur par défaut
      IconData icon = Icons.notifications;
      Color color = n['is_read'] == true ? Colors.grey : Colors.blue;

      // Extraire le nom de l'enfant si disponible
      String childName = '';
      if (dataMap != null && dataMap['eleve_nom'] != null) {
        childName = dataMap['eleve_nom'].toString();
      }

      // Style spécifique pour un nouveau devoir
      if (dataType == 'new_homework') {
        icon = Icons.menu_book;
        color = n['is_read'] == true ? Colors.grey : Colors.deepPurple;
      }

      allNotifications.add({
        'title': n['title'] ?? 'Notification',
        'type': 'INFO',
        'child': childName,
        'school': '',
        'sender': dataMap?['matiere'] ?? '',
        'time': n['created_at'] != null ? n['created_at'].toString().substring(0, 10) : 'Récemment',
        'color': color,
        'icon': icon,
        'message': n['message'] ?? '',
        'id': n['id'],
        'data': dataMap ?? n['data'],
        'notificationId': n['id'],
        'source': 'api',
      });
    }

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
            // Bannière d'incident si présente dans le payload
            if (incidentPayload != null) ...[
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  final childName = incidentPayload['child_name'];
                  if (childName != null) {
                    _selectChildByName(childName, 5); // Onglet Infos (index 5)
                    setState(() {
                      _pendingHighlightIncidentId = incidentPayload['incident_id']?.toString();
                    });
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.2),
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
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.red,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Incident signalé',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  incidentPayload['body'] ?? 'Nouvel incident',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.red,
                            size: 16,
                          ),
                        ],
                      ),
                      if (incidentPayload['enseignant_nom'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Par ${incidentPayload['enseignant_nom']}${incidentPayload['matiere'] != null ? ' - ${incidentPayload['matiere']}' : ''}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
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
                        return GestureDetector(
                          onTap: () {
                            final data = n['data'];
                            final notificationId = n['notificationId'];

                            // Navigation pour les notifications locales (incidents)
                            if (n['source'] == 'local' && data is Map<String, dynamic>) {
                              if (data['type'] == 'incident') {
                                final childName = data['child_name'];
                                if (childName != null) {
                                  Navigator.pop(context);
                                  _selectChildByName(childName, 5); // Onglet Infos
                                  setState(() {
                                    _pendingHighlightIncidentId = data['incident_id']?.toString();
                                  });
                                  return;
                                }
                              }
                            }

                            if (n['source'] == 'api' && data is Map<String, dynamic>) {
                              if ((data['type'] == 'admin_info' || data['type'] == 'new_homework') && data['eleve_id'] != null) {
                                final eleveId = int.tryParse(data['eleve_id'].toString());
                                if (eleveId != null) {
                                  final childIndex = _childrenData.indexWhere((c) {
                                    if (c['fromApi'] == true) {
                                      final raw = c['raw'] as Map<String, dynamic>?;
                                      final cid = c['id'];
                                      if (cid is int && cid == eleveId) {
                                        return true;
                                      }
                                      if (raw != null && raw['id'] != null && int.tryParse(raw['id'].toString()) == eleveId) {
                                        return true;
                                      }
                                    }
                                    return false;
                                  });

                                  if (childIndex != -1) {
                                    Navigator.pop(context);
                                    setState(() {
                                      _childInitialTab = data['type'] == 'new_homework' ? 2 : 5; // 2 = Devoirs, 5 = Infos
                                      _currentIndex = 0;
                                      if (childIndex < _childrenData.length) {
                                        _childrenData[childIndex]['notif'] = 0;
                                      }
                                      if (data['type'] == 'new_homework' && data['devoir_id'] != null) {
                                        _pendingHighlightHomeworkId = data['devoir_id']?.toString();
                                      }
                                    });
                                    _onChildSelected(childIndex);
                                  }

                                  if (notificationId != null) {
                                    ApiClient.instance.put(
                                      ApiEndpoints.markNotificationRead(notificationId),
                                    );
                                  }
                                  return;
                                }
                              }
                            }

                            if (n['type'] == 'INFO' || n['type'] == 'RDV' || n['type'] == 'ABSENCE') {
                              final childName = n['child']?.toString().split(' ')[0];
                              if (childName != null && childName.isNotEmpty) {
                                final childIndex = _childrenData.indexWhere((c) => (c['name'] as String).contains(childName));
                                if (childIndex != -1) {
                                  Navigator.pop(context);
                                  setState(() {
                                    _childInitialTab = 5;
                                    _currentIndex = 0;
                                  });
                                  _onChildSelected(childIndex);
                                }
                              }
                            }
                          },
                          child: _buildNotificationItem(
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
                          ),
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
                          SharedPreferences.getInstance().then((prefs) {
                            prefs.setBool('parent_scan_done', true);
                          });
                          setState(() {
                            _forceAddChild = false;
                          });
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
                          MaterialPageRoute(
                            builder: (_) => const LinkChildPage(),
                          ),
                        );
                        if (result != null && result is Map) {
                          SharedPreferences.getInstance().then((prefs) {
                            prefs.setBool('parent_scan_done', true);
                          });
                          setState(() {
                            _forceAddChild = false;
                          });
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
    if (filter == 'Tous' || filter == 'Enseignants') {
      for (final conv in _teacherConversationsAll) {
        final enseignantNom = '${conv['enseignant_prenom'] ?? ''} ${conv['enseignant_nom'] ?? ''}'.trim();
        final initials = (conv['enseignant_nom'] ?? 'E').isNotEmpty
            ? (conv['enseignant_nom'] as String)[0].toUpperCase()
            : 'E';
        final unreadVal = conv['unread_count'];
        final unread = (unreadVal is int) ? unreadVal : (int.tryParse(unreadVal.toString()) ?? 0);
        tiles.add(
          _buildMessageTile(
            name: enseignantNom.isNotEmpty ? enseignantNom : 'Enseignant',
            role: conv['subject'] ?? 'Discussion',
            initials: initials,
            color: AppTheme.seaBlue,
            school: conv['admin_name'] ?? '',
            childName: '${conv['eleve_prenom'] ?? ''} ${conv['eleve_nom'] ?? ''}'.trim(),
            lastMsg: conv['subject'] ?? '',
            time: '',
            unreadCount: unread,
            conversationId: conv['conversation_id'],
            conversationData: Map<String, dynamic>.from(conv),
          ),
        );
      }
    }

    // CONVERSATIONS ADMINISTRATION (données réelles)
    if (filter == 'Tous' || filter == 'Administration') {
      for (final conv in _adminConversations) {
        final adminName = conv['admin_name'] ?? 'Administration';
        final unreadVal = conv['unread_count'];
        final unread = (unreadVal is int) ? unreadVal : (int.tryParse(unreadVal.toString()) ?? 0);
        tiles.add(
          _buildMessageTile(
            name: adminName,
            role: conv['subject'] ?? 'Message de l\'Administration',
            initials: 'AD',
            color: AppTheme.forestGreen,
            school: adminName,
            childName: '${conv['eleve_prenom'] ?? ''} ${conv['eleve_nom'] ?? ''}'.trim(),
            lastMsg: conv['subject'] ?? 'Nouveau message',
            time: '',
            unreadCount: unread,
            conversationId: conv['conversation_id'],
            conversationData: Map<String, dynamic>.from(conv),
          ),
        );
      }
    }

    if (tiles.isEmpty) {
      return const Center(
        child: Text(
          'Aucun message récent',
          style: TextStyle(color: Colors.grey),
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
    int? conversationId,
    Map<String, dynamic>? conversationData,
  }) {
    return GestureDetector(
      onTap: () {
        if (conversationId != null) {
          // Mettre à jour immédiatement les compteurs non lus côté UI
          setState(() {
            for (final conv in _teacherConversationsAll) {
              if (conv['conversation_id'] == conversationId) {
                conv['unread_count'] = 0;
              }
            }
            for (final conv in _adminConversations) {
              if (conv['conversation_id'] == conversationId) {
                conv['unread_count'] = 0;
              }
            }
          });

          // Naviguer vers la vraie page de chat
          final conv = conversationData ?? {};
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatPage(conversation: {
                ...conv,
                'conversation_id': conversationId,
                'status': 'accepted',
              }),
            ),
          ).then((_) => _fetchConversations());
        }
      },
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
    if (_isLoadingEvents) {
      return const Center(child: CircularProgressIndicator());
    }

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

          if (_appointments.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text("Aucun événement pour le moment.", style: TextStyle(color: Colors.grey)),
            ),


          if (_appointments.isNotEmpty) ...[
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
            ..._appointments.map((rdv) {
              final childName = '${rdv['eleve_prenom'] ?? ''} ${rdv['eleve_nom'] ?? ''}'.trim();
              return Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: _buildRdvCard(
                  teacherName: '${rdv['enseignant_prenom'] ?? ''} ${rdv['enseignant_nom'] ?? ''}'.trim(),
                  subject: rdv['enseignant_matiere'] ?? 'Enseignant',
                  meetingType: rdv['type'] ?? 'Rendez-vous',
                  childName: childName,
                  school: '', // Could be joined if available
                  motif: rdv['motif'] ?? 'Aucun motif',
                  date: rdv['date_heure'] ?? '',
                  color: _getChildColor(childName),
                  initials: (rdv['enseignant_nom'] ?? 'P')[0].toUpperCase(),
                  id: rdv['id'],
                  requester: rdv['requester'] ?? 'parent',
                  isPending: rdv['statut'] == 'en_attente',
                ),
              );
            }),
          ],

          // Les événements de l'établissement seront chargés dynamiquement ici plus tard
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Color _getChildColor(String childName) {
    if (childName.isEmpty) return AppTheme.seaBlue;
    final firstName = childName.split(' ')[0].toLowerCase();
    for (var child in _childrenData) {
      if ((child['name'] as String).toLowerCase().contains(firstName)) {
        return child['color'] ?? AppTheme.seaBlue;
      }
    }
    return AppTheme.seaBlue;
  }

  Widget _buildConversationRequestCard(Map<String, dynamic> req) {
    String teacherName = '${req['enseignant_prenom'] ?? ''} ${req['enseignant_nom'] ?? ''}'.trim();
    String subject = req['enseignant_matiere'] ?? req['subject'] ?? 'Messagerie';
    
    // Contexte de l'élève
    String eleveNom = req['eleve_nom'] ?? '';
    String elevePrenom = req['eleve_prenom'] ?? '';
    String childContext = elevePrenom.isNotEmpty ? 'Pour $elevePrenom $eleveNom' : '';
    
    String status = req['status'] ?? 'pending';
    String statusText = 'Nouvelle discussion';
    Color statusColor = Colors.orange;
    if (status == 'accepted') {
      statusText = 'Discussion acceptée';
      statusColor = Colors.green;
    } else if (status == 'rejected') {
      statusText = 'Discussion refusée';
      statusColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.05),
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
              CircleAvatar(
                backgroundColor: statusColor,
                radius: 20,
                child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: statusColor),
                    ),
                    Text(
                      '$teacherName ($subject)',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    if (childContext.isNotEmpty)
                      Text(
                        childContext,
                        style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (req['ecole_nom'] != null)
            Text('École: ${req['ecole_nom']}', style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
          const SizedBox(height: 12),
          if (status == 'pending')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(conversation: req),
                    ),
                  ).then((_) => _fetchEvents());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: statusColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Ouvrir la discussion'),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  status == 'accepted' ? 'Vous avez accepté cette discussion' : 'Vous avez refusé cette discussion',
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                ),
              ),
            ),
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
    int? id,
    String requester = 'parent',
    bool isPending = false,
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
              if (isPending) ...[
                const SizedBox(height: 15),
                if (requester == 'enseignant')
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _updateAppointmentStatus(id, 'refuse'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Refuser'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _updateAppointmentStatus(id, 'accepte'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                        Text('En attente d\'acceptation par l\'enseignant', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
              ]
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
                                  errorBuilder: (_, __, ___) =>
                                      const SizedBox(),
                                )
                              : Image.asset(
                                  image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const SizedBox(),
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
