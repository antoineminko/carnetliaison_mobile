import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/shared/pages/appointment_page.dart';
import 'package:app_mobile/shared/config/api_client.dart';
import 'package:intl/intl.dart';
import 'package:app_mobile/features/parent/messages/chat_page.dart';
part 'overview_modals.dart';
part 'overview_tab_view.dart';
part '../actualites/actualites_view.dart';
part '../devoirs/devoirs_view.dart';
part '../professeurs/professeurs_view.dart';
part '../notes/notes_view.dart';
part '../historique/historique_view.dart';
part '../informations/informations_view.dart';
part '../statistiques/statistiques_view.dart';

class ChildDetailsView extends StatefulWidget {
  final Map<String, dynamic> child;
  final VoidCallback onBack;
  final VoidCallback onGoToCalendar;
  final VoidCallback onShowNotifications;
  final int initialTab;
  final String? highlightIncidentId;
  final String? highlightHomeworkId;
  final int initialInfosSubTab;

  const ChildDetailsView({
    super.key,
    required this.child,
    required this.onBack,
    required this.onGoToCalendar,
    required this.onShowNotifications,
    this.initialTab = 0,
    this.highlightIncidentId,
    this.highlightHomeworkId,
    this.initialInfosSubTab = 0,
  });

  @override
  State<ChildDetailsView> createState() => _ChildDetailsViewState();
}

class _ChildDetailsViewState extends State<ChildDetailsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _dashboardData;
  bool _isLoadingDashboard = false;
  List<dynamic> _incidents = [];
  bool _isLoadingIncidents = false;
  String _selectedDevoirFilter = 'Tous';

  Future<void> _fetchDashboard() async {
    print('[DEBUG _fetchDashboard] fromApi: ${widget.child['fromApi']}');
    print('[DEBUG _fetchDashboard] child keys: ${widget.child.keys.toList()}');
    
    if (widget.child['fromApi'] != true) {
      print('[DEBUG _fetchDashboard] Skipping API call - not from API');
      return;
    }
    
    setState(() => _isLoadingDashboard = true);
    try {
      // raw_id = id numérique pur pour l'API (sans le '#' d'affichage)
      final rawId = widget.child['raw_id'] ?? widget.child['id'].toString().replaceAll('#', '');
      final response = await ApiClient.instance.get('/eleves/$rawId/dashboard');
      
      // DEBUG: Afficher la réponse API complète
      print('[DEBUG API RESPONSE] eleveId: $rawId');
      print('[DEBUG API RESPONSE] actualites: ${response.data['actualites']}');
      print('[DEBUG API RESPONSE] finances: ${response.data['finances']}');
      print('[DEBUG API RESPONSE] Full response: ${response.data}');
      
      // Also fetch admin infos
      final infosResponse = await ApiClient.instance.get('/admin/informations/$rawId');
      
      if (mounted) {
        setState(() {
          _dashboardData = response.data;
          if (_dashboardData != null) {
            _dashboardData!['adminInfos'] = infosResponse.data['informations'];
          }
          _isLoadingDashboard = false;
          
          // DEBUG: Confirmer le stockage
          print('[DEBUG API STORAGE] _dashboardData actualites: ${_dashboardData?['actualites']}');
          print('[DEBUG API STORAGE] _dashboardData finances: ${_dashboardData?['finances']}');
        });
      }
    } catch (e) {
      print('[DEBUG API ERROR] Error fetching dashboard: $e');
      if (mounted) setState(() => _isLoadingDashboard = false);
    }
  }

  Future<void> _fetchIncidents() async {
    if (widget.child['fromApi'] != true) return;
    
    setState(() => _isLoadingIncidents = true);
    try {
      final rawId = widget.child['raw_id'] ?? widget.child['id'].toString().replaceAll('#', '');
      final response = await ApiClient.instance.get('/eleves/$rawId/incidents');
      
      if (mounted && response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _incidents = response.data['data'] ?? [];
          _isLoadingIncidents = false;
        });
        
        // Marquer l'incident comme lu si highlightIncidentId est défini
        if (widget.highlightIncidentId != null) {
          _markIncidentAsRead(widget.highlightIncidentId!);
        }
      } else {
        if (mounted) setState(() => _isLoadingIncidents = false);
      }
    } catch (e) {
      print('[DEBUG] Erreur fetch incidents: $e');
      if (mounted) setState(() => _isLoadingIncidents = false);
    }
  }

  Future<void> _markIncidentAsRead(String incidentId) async {
    try {
      await ApiClient.instance.put('/incidents/$incidentId/read');
      // Rafraîchir la liste après avoir marqué comme lu
      _fetchIncidents();
    } catch (e) {
      print('[DEBUG] Erreur mark incident as read: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this, initialIndex: widget.initialTab);
    _fetchDashboard();
    _fetchIncidents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppTheme.seaBlue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.seaBlue,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Aperçu'),
            Tab(text: 'Actualités'),
            Tab(text: 'Devoirs'),
            Tab(text: 'Professeurs'),
            Tab(text: 'Notes'),
            Tab(text: 'Infos'),
            Tab(text: 'Statistiques'),
            Tab(text: 'Historique'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              _buildNewsTab(),
              _buildHomeworksTab(),
              _buildTeachersTab(),
              _buildNotesTab(),
              _buildInfosTab(),
              _buildStatsTab(),
              _buildHistoriqueTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppTheme.seaBlue,
              size: 20,
            ),
            onPressed: widget.onBack,
          ),
          Stack(
            children: [
              CircleAvatar(
                backgroundImage: widget.child['isNetworkImage'] == true 
                    ? NetworkImage(widget.child['image']) as ImageProvider
                    : AssetImage(widget.child['image']),
                radius: 20,
              ),
              if (widget.child['schoolIcon'] != null)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: CircleAvatar(
                      backgroundImage: AssetImage(widget.child['schoolIcon']),
                      radius: 8,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.child['name'],
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${widget.child['school'] ?? 'École'} • ${widget.child['grade']}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.seaBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.key, size: 12, color: AppTheme.seaBlue),
                      const SizedBox(width: 4),
                      Text(
                        'Code: ${widget.child['code_secret'] ?? 'ERR_KEY_MISSING'}',
                        style: const TextStyle(
                          color: AppTheme.seaBlue,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}