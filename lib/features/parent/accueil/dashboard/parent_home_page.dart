import 'package:app_mobile/features/parent/accueil/dashboard/child_card_widget.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/features/parent/evenements/calendar_page.dart';
import 'package:app_mobile/features/parent/espace_enfant/apercu/child_details_page.dart';
import 'package:app_mobile/features/parent/accueil/publicite/promo_banner_widget.dart';
import 'package:app_mobile/features/parent/espace_enfant/devoirs/textbook_page.dart';
import 'package:app_mobile/features/parent/espace_enfant/apercu/child_details_view.dart';
import 'package:app_mobile/shared/config/school_config.dart';
import 'package:app_mobile/shared/widgets/background_wrapper.dart';
import 'package:app_mobile/features/parent/accueil/liaison/qr_scan_page.dart';
import 'package:app_mobile/features/parent/accueil/liaison/link_child_page.dart';
import 'package:app_mobile/features/auth/parent/services/parent_auth_service.dart';
import 'package:app_mobile/features/parent/services/parent_service.dart';
import 'package:app_mobile/features/parent/messages/chat_page.dart';
import 'package:app_mobile/shared/config/api_client.dart';
import 'package:app_mobile/shared/config/api_endpoints.dart';
import 'package:app_mobile/features/notifications/services/notification_storage.dart';
import 'package:app_mobile/features/notifications/services/notifications_service.dart';
import 'package:app_mobile/features/appointments/pages/appointments_list_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'dashboard_cards_view.dart';
part 'dashboard_header_view.dart';
part 'dashboard_modals_view.dart';
part 'dashboard_tiles_view.dart';
part '../../notifications/parent_notifications_view.dart';
part '../../messages/messages_view.dart';
part '../../evenements/evenements_view.dart';
part '../../profil/parent_profile_page.dart';








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
  bool _isEmptyState = true;
  bool _forceAddChild = false;
  bool _isLoadingChildren = true;
  int _currentIndex = 0;
  int _childInitialTab = 0;




 
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
  String _selectedEventFilter = 'Tous';
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
    // Compter les notifications push locales non lues (Firebase)
    final localCount = await NotificationStorage.getUnreadCount();
    // Compter les notifications API non lues (serveur)
    final apiCount = _apiNotifications.where((n) => n['is_read'] != true && n['is_read'] != 1).length;
    if (mounted) {
      setState(() {
        _unreadNotificationsCount = localCount + apiCount;
      });
    }
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

  Future<void> _loadLinkedChildren() async {
    final parentId = await AuthService.getParentId();
    if (parentId == null) {
      setState(() => _isLoadingChildren = false);
      return;
    }

    try {
      final children = await ParentService.getChildren(parentId);
      if (!mounted) return;

      // ─── MIGRATION UNE SEULE FOIS ───────────────────────────────────────
      // Si l'utilisateur a déjà fait un scan sur CE téléphone (parent_scan_done=true)
      // mais que la mémoire locale est vide (bug des versions précédentes),
      // on synchronise automatiquement les enfants vérifiés par l'API.
      // Sur un NOUVEAU téléphone : parent_scan_done n'est pas défini → pas de sync.
      final prefs = await SharedPreferences.getInstance();
      final migrationDone = prefs.getBool('_local_verify_v2_migrated') == true;
      if (!migrationDone) {
        final scanDone = prefs.getBool('parent_scan_done') == true;
        if (scanDone) {
          // Scan déjà fait sur ce téléphone → sync les enfants is_verified=1 en local
          for (final child in children) {
            final v = child['is_verified'];
            final isVerified = v == 1 || v == true || v == '1';
            if (isVerified) {
              final idRaw = child['id'];
              if (idRaw != null) {
                final childId = idRaw is int ? idRaw : int.tryParse(idRaw.toString());
                if (childId != null) {
                  await ParentService.addLocallyVerifiedChild(childId);
                  print('[MIGRATION] Enfant $childId synchronisé localement');
                }
              }
            }
          }
        }
        await prefs.setBool('_local_verify_v2_migrated', true);
      }
      // ─────────────────────────────────────────────────────────────────────

      // IDs des enfants vérifiés localement sur CE téléphone
      final localVerifiedIds = await ParentService.getLocallyVerifiedChildren();
      print('[DEBUG] localVerifiedIds = $localVerifiedIds');

      // Cas 1 - Premier téléphone :
      //   is_verified=0 → enfant jamais scanné → n'apparaît PAS (doit être scanné via +)
      //   is_verified=1 → enfant scanné au moins une fois → s'affiche débloqué
      //
      // Cas 2 - Nouveau téléphone :
      //   is_verified=1 + local_verified=false → s'affiche VERROUILLÉ (cadenas)
      //   Après entrée du code secret → local_verified=true → DÉBLOQUÉ

      // On n'affiche que les enfants qui ont déjà été scannés au moins une fois (is_verified=1)
      final verifiedByApi = children.where((c) {
        final v = c['is_verified'];
        return v == 1 || v == true || v == '1';
      }).toList();

      setState(() {
        _childrenData
          ..clear()
          ..addAll(verifiedByApi.map((c) => _mapApiChild(c, localVerifiedIds)));
        // Empty state = aucun enfant vérifié par l'API
        // → redirige vers page "ajouter un enfant"
        _isEmptyState = _childrenData.isEmpty;
        _forceAddChild = false;
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
      setState(() => _isLoadingChildren = false);
      // Afficher un message sans déconnecter (peut être juste un problème réseau temporaire)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de charger les enfants. Vérifiez votre connexion.'),
          duration: Duration(seconds: 4),
        ),
      );
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
        // Mettre à jour le badge après chargement des notifs API
        _loadUnreadNotificationsCount();
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

  Map<String, dynamic> _mapApiChild(Map<String, dynamic> child, List<int> localVerifiedIds) {
    final imageUrl = child['photo_url']?.toString().isNotEmpty == true
        ? child['photo_url'].toString()
        : null;

    String status = child['status'] ?? 'Présent';
    Color statusColor = AppTheme.forestGreen;
    String? arrivalTime;

    if (child['attendance_status'] != null) {
      status = child['attendance_status'];
      if (status == 'Absent') {
        statusColor = Colors.red;
      } else if (status == 'En retard') {
        statusColor = Colors.orange;
      } else if (status == 'En attente') {
        statusColor = Colors.grey;
      }
    } else {
      status = 'En attente';
      statusColor = Colors.grey;
    }

    if (child['arrival_time'] != null) {
      try {
        final dt = DateTime.parse(child['arrival_time']);
        arrivalTime = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {}
    }

    final childIdRaw = child['id'];
    final childId = childIdRaw is int ? childIdRaw : int.tryParse(childIdRaw?.toString() ?? '') ?? -1;

    final isApiVerified = child['is_verified'] == 1 || child['is_verified'] == true || child['is_verified'] == '1';
    final isLocalVerified = localVerifiedIds.contains(childId);

    print('[DEBUG] child $childId: isApiVerified=$isApiVerified, isLocalVerified=$isLocalVerified, localIds=$localVerifiedIds');

    return {
      'fromApi': true,
      'id': childId,
      'name': '${child['prenom'] ?? ''} ${child['nom'] ?? ''}'.trim(),
      'prenom': child['prenom'] ?? '',
      'grade': child['classe_nom'] ?? 'Classe non définie',
      'school': child['ecole_nom'] ?? 'École non définie',
      'color': const Color(0xFF2596be),
      'image': imageUrl ?? 'assets/images/profil/eleve1.jpg',
      'isNetworkImage': imageUrl != null,
      'notif': child['notif_count'] ?? 0,
      'status': status,
      'statusColor': statusColor,
      if (arrivalTime != null) 'arrivalTime': arrivalTime,
      'arrival_time': child['arrival_time'],
      'attendance_status': child['attendance_status'],
      'is_verified': isApiVerified,
      // Verrouillé si pas encore vérifié localement sur CE téléphone
      'local_verified': isLocalVerified,
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

    return PopScope(
      // Bloquer le pop système si un enfant est sélectionné
      canPop: _selectedChild == null,
      onPopInvokedWithResult: (didPop, result) {
          if (!didPop && _selectedChild != null) {
          setState(() {
            _selectedChild = null;
            _selectedChildIndex = null;
            _childInitialTab = 0;
          });
        }
      },
      child: Scaffold(
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
              _currentIndex = index == 0 ? 0 : 3;
            }
            // Quand on tape Accueil, revenir à la liste des enfants
            if (index == 0) {
              _selectedChild = null;
              _selectedChildIndex = null;
              _childInitialTab = 0;
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
      ), // fin Scaffold
    ); // fin PopScope
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
              _selectedChildIndex = null;
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

  Widget _buildGlobalDashboard() {
    if (_isEmptyState) {
      return _buildEmptyState();
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          _buildAvatarSection(),
          const SizedBox(height: 20),
          _buildChildrenList(),
          const SizedBox(height: 20),
          const PromoBannerWidget(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }














  void _onChildSelected(int index) {
    setState(() {
      _selectedChildIndex = index;
      if (index < _childrenData.length) {
        _childrenData[index]['notif'] = 0; // Reset visuel immédiat
      }

      final currentChild = index < _childrenData.length
          ? _childrenData[index]
          : null;
          
      if (currentChild != null) {
        if (currentChild['local_verified'] != true) {
          // Si l'enfant n'est pas vérifié localement, afficher la popup de vérification au lieu de le sélectionner
          _selectedChildIndex = null;
          _showVerifyChildModal(currentChild);
          return;
        }

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
          'status': currentChild['status'] ?? currentChild['attendance_status'] ?? 'En attente',
          'statusColor': currentChild['statusColor'] ?? Colors.grey,
          'arrivalTime': currentChild['arrival_time'] ?? currentChild['arrivalTime'] ?? '--:--',
          'attendance_status': currentChild['attendance_status'],
          'arrival_time': currentChild['arrival_time'],
          'feesOwed': '0 FCFA',
          'homeworks': [],
          'notifications': [],
          'calendarDate': 'Mars 2026',
          'incidents': [],
          'fromApi': true,
          'raw': currentChild['raw'] ?? currentChild,
        };

        // Marquer toutes les notifications de cet enfant comme lues côté API
        final childId = currentChild['id'];
        if (childId != null) {
          _markAllChildNotificationsRead(childId);
        }
      }
    });
  }

  /// Appelle l'API pour marquer toutes les notifications d'un enfant comme lues
  /// → remet le notif_count à 0 côté serveur (admin_informations.is_read = true)
  Future<void> _markAllChildNotificationsRead(dynamic childId) async {
    try {
      final eleveId = childId is int ? childId : int.tryParse(childId.toString());
      if (eleveId == null) return;
      final parentId = await AuthService.getParentId();
      await ApiClient.instance.put(
        ApiEndpoints.markAllNotificationsReadForChild(eleveId),
        data: parentId != null ? {'parent_id': parentId} : null,
      );
      debugPrint('[Notifications] Toutes les notifs de l\'enfant $eleveId marquées comme lues');
    } catch (e) {
      debugPrint('[Notifications] Erreur markAllChildNotificationsRead: $e');
    }
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



}
