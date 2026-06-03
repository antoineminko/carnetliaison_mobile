import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/shared/pages/appointment_page.dart';
import 'package:app_mobile/shared/config/api_client.dart';
import 'package:intl/intl.dart';
import 'package:app_mobile/features/parent/pages/chat_page.dart';

class ChildDetailsView extends StatefulWidget {
  final Map<String, dynamic> child;
  final VoidCallback onBack;
  final VoidCallback onGoToCalendar;
  final VoidCallback onShowNotifications;
  final int initialTab;
  final String? highlightIncidentId;
  final String? highlightHomeworkId;

  const ChildDetailsView({
    super.key,
    required this.child,
    required this.onBack,
    required this.onGoToCalendar,
    required this.onShowNotifications,
    this.initialTab = 0,
    this.highlightIncidentId,
    this.highlightHomeworkId,
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
        setState(() => _isLoadingIncidents = false);
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
    _tabController = TabController(length: 7, vsync: this, initialIndex: widget.initialTab);
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
                  '${widget.child['school'] ?? 'École'} • ${widget.child['grade']} • ID: ${widget.child['id'] ?? '#---'}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppTheme.seaBlue,
                  size: 26,
                ),
                onPressed: widget.onShowNotifications,
              ),
              if (widget.child['notif'] != null && widget.child['notif'] > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${widget.child['notif']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    // Statut de présence et heure d'arrivée : on privilégie les données du dashboard si disponibles
    // Fallback sur les données de la liste des enfants (attendance_status, arrival_time)
    String rawStatus = widget.child['attendance_status']?.toString() ?? 'present';
    String status = 'Présent';
    if (rawStatus == 'absent') status = 'Absent';
    if (rawStatus == 'late') status = 'En retard';

    Color statusColor = Colors.green;
    if (status == 'Absent' || status == 'Absente') statusColor = Colors.red;
    if (status == 'En retard') statusColor = Colors.orange;

    // Parser arrival_time (format: 2026-06-02 14:58:05)
    String arrivalTime = '--:--';
    String dateAffichee = '';
    String jour = '';
    // Essayer arrival_time (API) puis arrivalTime (camelCase)
    final String? arrivalRaw = widget.child['arrival_time']?.toString() ?? widget.child['arrivalTime']?.toString();
    print('[DEBUG] child keys: ${widget.child.keys.toList()}');
    print('[DEBUG] arrivalRaw = $arrivalRaw');
    if (arrivalRaw != null && arrivalRaw.isNotEmpty) {
      try {
        final dt = DateTime.parse(arrivalRaw);
        arrivalTime = DateFormat('HH:mm', 'fr_FR').format(dt);
        dateAffichee = DateFormat('d MMM yyyy', 'fr_FR').format(dt);
        jour = DateFormat('EEEE', 'fr_FR').format(dt);
        jour = '${jour[0].toUpperCase()}${jour.substring(1)}';
        print('[DEBUG] Parsed OK: arrivalTime=$arrivalTime, dateAffichee=$dateAffichee');
      } catch (e) {
        print('[DEBUG] Parse error: $e');
        // Fallback: extraire manuellement HH:mm et date
        if (arrivalRaw.length >= 16) {
          arrivalTime = arrivalRaw.substring(11, 16); // HH:mm
          final datePart = arrivalRaw.substring(0, 10); // YYYY-MM-DD
          try {
            final dt = DateTime.parse(datePart);
            dateAffichee = DateFormat('d MMM yyyy', 'fr_FR').format(dt);
            jour = DateFormat('EEEE', 'fr_FR').format(dt);
            jour = '${jour[0].toUpperCase()}${jour.substring(1)}';
            print('[DEBUG] Fallback OK: dateAffichee=$dateAffichee');
          } catch (_) {}
        }
      }
    } else {
      print('[DEBUG] arrivalRaw is null or empty');
    }

    // Override avec dashboard si disponible
    Map<String, dynamic>? attendance;
    if (_dashboardData != null && _dashboardData!['attendance'] is Map) {
      attendance = Map<String, dynamic>.from(
        _dashboardData!['attendance'] as Map,
      );
    }

    String matiere = '';
    String enseignant = '';
    if (attendance != null) {
      final String? dashStatus = attendance['statut']?.toString();
      if (dashStatus != null && dashStatus.isNotEmpty) {
        status = dashStatus;
        if (status == 'Présent') statusColor = Colors.green;
        else if (status == 'Absent' || status == 'Absente') statusColor = Colors.red;
        else if (status == 'En retard') statusColor = Colors.orange;
      }

      final dynamic heureRaw = attendance['heure_arrivee'];
      if (heureRaw != null && heureRaw.toString().isNotEmpty) {
        arrivalTime = heureRaw.toString();
      }

      final String? dateRaw = attendance['date']?.toString();
      if (dateRaw != null && dateRaw.isNotEmpty) {
        try {
          final date = DateTime.parse(dateRaw);
          dateAffichee = DateFormat('d MMMM yyyy', 'fr_FR').format(date);
          jour = DateFormat('EEEE', 'fr_FR').format(date);
          jour = '${jour[0].toUpperCase()}${jour.substring(1)}';
        } catch (_) {}
      }

      matiere = attendance['matiere']?.toString() ?? '';
      enseignant = attendance['enseignant_nom']?.toString() ?? '';
    }

    final bool isAbsent = status == 'Absente' || status == 'Absent';

    return RefreshIndicator(
      onRefresh: _fetchDashboard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          _buildPriorityNotifications(),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Présence du jour',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (isAbsent)
                TextButton.icon(
                  onPressed: () => _showAbsenceModal(),
                  icon: const Icon(
                    Icons.edit_document,
                    size: 16,
                    color: AppTheme.sunYellow,
                  ),
                  label: const Text(
                    'Justifier',
                    style: TextStyle(
                      color: AppTheme.seaBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 15),
          // BOX 1: Statut + Arrivée (Heure + Date)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isAbsent
                  ? Colors.grey.withOpacity(0.1)
                  : const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isAbsent
                    ? Colors.grey.withOpacity(0.2)
                    : Colors.green.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                // Icône et statut
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isAbsent ? Icons.cancel : (status == 'En retard' ? Icons.warning : Icons.check_circle),
                            color: statusColor,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Statut',
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // Ligne verticale séparatrice
                Container(
                  width: 1,
                  height: 50,
                  color: Colors.grey.withOpacity(0.3),
                ),
                const SizedBox(width: 16),
                // Heure et date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_filled,
                            color: isAbsent ? Colors.grey : const Color(0xFF1565C0),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Arrivée',
                            style: TextStyle(
                              color: isAbsent ? Colors.grey : const Color(0xFF1565C0),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isAbsent ? '--:--' : arrivalTime,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isAbsent ? Colors.grey[700] : const Color(0xFF0D47A1),
                        ),
                      ),
                      if (dateAffichee.isNotEmpty)
                        Text(
                          dateAffichee,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          // BOX 2: Matière + Prof + Jour (toujours visible même si absent/retard)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isAbsent
                  ? Colors.grey.withOpacity(0.08)
                  : Colors.deepPurple.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isAbsent
                    ? Colors.grey.withOpacity(0.3)
                    : Colors.deepPurple.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                // Matière et prof
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Matière',
                        style: TextStyle(
                          fontSize: 13,
                          color: isAbsent ? Colors.grey[700] : Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        matiere.isNotEmpty ? matiere : (isAbsent ? 'Non spécifiée' : '-'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isAbsent ? Colors.grey[600] : Colors.deepPurple,
                        ),
                      ),
                      if (enseignant.isNotEmpty)
                        Text(
                          enseignant,
                          style: TextStyle(
                            fontSize: 12,
                            color: isAbsent ? Colors.grey[500] : Colors.deepPurple,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                // Ligne verticale séparatrice
                Container(
                  width: 1,
                  height: 50,
                  color: Colors.grey.withOpacity(0.3),
                ),
                const SizedBox(width: 16),
                // Jour (utiliser date du jour si pas d'arrival_time)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jour',
                        style: TextStyle(
                          fontSize: 13,
                          color: isAbsent ? Colors.grey[700] : Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        jour.isNotEmpty
                            ? jour
                            : DateFormat('EEEE', 'fr_FR').format(DateTime.now()),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isAbsent ? Colors.grey[600] : Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
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
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 15),
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
                          'Emploi du Temps de la Semaine',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: InteractiveViewer(
                              child: Image.asset(
                                'assets/emploie/emploie.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.picture_as_pdf,
                color: Color(0xFF37474F),
              ), // Dark slate grey
              label: const Text(
                'VOIR L\'EMPLOI DU TEMPS DE L\'ENFANT',
                style: TextStyle(
                  color: Color(0xFF37474F),
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFECEFF1), // Light grey/white
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Colors.blueGrey.withOpacity(0.1)),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Devoirs à venir',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: widget.onGoToCalendar,
                child: const Text(
                  'Voir Calendrier',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.seaBlue,
                  ),
                ),
              ),
            ],
          ),

          _buildHomeworkSummary(),
          
          const SizedBox(height: 30),
          // ACTUALITÉS RÉSUMÉ (Aperçu)
          Builder(
            builder: (context) {
              final actualites = _dashboardData?['actualites'] as List<dynamic>? ?? [];
              
              // DEBUG: Afficher les actualités reçues
              print('[DEBUG ACTUALITES Aperçu] actualites count: ${actualites.length}');
              print('[DEBUG ACTUALITES Aperçu] actualites data: $actualites');
              print('[DEBUG ACTUALITES Aperçu] _dashboardData keys: ${_dashboardData?.keys.toList()}');
              
              if (actualites.isEmpty) {
                print('[DEBUG ACTUALITES Aperçu] Aucune actualité à afficher');
                return const SizedBox.shrink();
              }
              
              // Afficher seulement la première actualité en résumé
              final actu = actualites.first;
              
              // DEBUG: Afficher les détails de l'actualité
              print('[DEBUG ACTUALITES Aperçu] titre: ${actu['titre']}');
              print('[DEBUG ACTUALITES Aperçu] contenu: ${actu['contenu']}');
              print('[DEBUG ACTUALITES Aperçu] type: ${actu['type']}');
              print('[DEBUG ACTUALITES Aperçu] image_url: ${actu['image_url']}');
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Actualités',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () => _tabController.animateTo(1), // Aller à l'onglet Actualités
                        child: const Text(
                          'Voir tout',
                          style: TextStyle(color: AppTheme.seaBlue, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  GestureDetector(
                    onTap: () => _tabController.animateTo(1),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image avec overlay gradient
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                child: Image.network(
                                  actu['image_url'] ?? 'https://i.pinimg.com/736x/51/b1/a7/51b1a798455b0af03492963412bf1689.jpg',
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    height: 180,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image, color: Colors.grey, size: 50),
                                  ),
                                ),
                              ),
                              // Badge type en haut à gauche
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getNewsTypeColor(actu['type']),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getNewsTypeIcon(actu['type']),
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        (actu['type'] ?? 'ANNONCE').toString().toUpperCase(),
                                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Titre
                                Text(
                                  actu['titre'] ?? 'Information',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.3),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 10),
                                // Description
                                Text(
                                  actu['contenu'] ?? '',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 12),
                                // Date et heure si présentes
                                if (actu['date'] != null || actu['heure'] != null)
                                  Row(
                                    children: [
                                      if (actu['date'] != null) ...[
                                        Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                                        const SizedBox(width: 6),
                                        Text(
                                          _formatNewsDate(actu['date']),
                                          style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                      if (actu['heure'] != null) ...[
                                        const SizedBox(width: 16),
                                        Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                                        const SizedBox(width: 6),
                                        Text(
                                          actu['heure'].toString(),
                                          style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    ),
  );
}

  Widget _buildPriorityNotifications() {
    final rawNotifs = widget.child['notifications'];
    final notifs = rawNotifs is List 
        ? rawNotifs.map((e) => e as Map<String, dynamic>).toList()
        : null;

    if (notifs == null || notifs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dernières notifications',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        ...notifs
            .map(
              (n) => GestureDetector(
                onTap: () {
                  if (n['tabIndex'] != null) {
                    _tabController.animateTo(n['tabIndex']);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                      ),
                    ],
                    border: Border.all(color: Colors.grey[50]!),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (n['color'] as Color).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          n['icon'] as IconData,
                          color: n['color'] as Color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              n['title'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Cliquez pour voir les détails',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 11,
                              ),
                            ),
                            if (n['type'] == 'BULLETIN' &&
                                n['bulletinImage'] != null) ...[
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 36,
                                child: ElevatedButton.icon(
                                  onPressed: () => _showBulletinModal(
                                    n['bulletinImage'] as String,
                                  ),
                                  icon: const Icon(
                                    Icons.remove_red_eye,
                                    size: 14,
                                  ),
                                  label: const Text(
                                    'VOIR LE BULLETIN',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.seaBlue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ],
    );
  }

  void _showBulletinModal(String imagePath) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 15),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'BULLETIN TRIMESTRE 3',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: InteractiveViewer(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Center(child: Text('Image bulletin introuvable')),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download),
                  label: const Text('TÉLÉCHARGER LE PDF'),
                  style: AppTheme.primaryButtonStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentAlertNotification() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (widget.child['isLowGrade'] == true)
                  ? AppTheme.sunYellow.withOpacity(0.1)
                  : Colors.purple[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              (widget.child['isLowGrade'] == true)
                  ? Icons.warning_amber_rounded
                  : Icons.campaign,
              color: (widget.child['isLowGrade'] == true)
                  ? AppTheme.sunYellow
                  : Colors.purple[400],
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nouvelle note publiée : Devoir de Science',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.sunYellow.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.child['school'] ?? 'École',
                    style: const TextStyle(
                      color: AppTheme.sunYellow,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'M. Okoro vient de mettre à jour le cahier de texte numérique pour les Sciences.',
                  style: TextStyle(
                    color: Colors.blueGrey[600],
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: _showGradeModal,
                  child: const Text(
                    'Voir le résultat',
                    style: TextStyle(
                      color: AppTheme.seaBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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

  void _showGradeModal() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: (widget.child['isLowGrade'] == true)
                      ? AppTheme.sunYellow.withOpacity(0.1)
                      : Colors.purple[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  (widget.child['isLowGrade'] == true)
                      ? Icons.warning_amber_rounded
                      : Icons.verified,
                  color: (widget.child['isLowGrade'] == true)
                      ? AppTheme.sunYellow
                      : Colors.purple[400],
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Résultat du Devoir',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                widget.child['scienceGrade'] ?? '14/20',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: (widget.child['isLowGrade'] == true)
                      ? AppTheme.sunYellow
                      : AppTheme.seaBlue,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.child['quizDetails'] ??
                    'Note interrogation en physique chimie',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: AppTheme.primaryButtonStyle,
                  child: const Text(
                    'Fermer',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAbsenceModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Signaler une absence',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Pour : ${widget.child['name']}',
              style: TextStyle(color: AppTheme.textGrey),
            ),
            const SizedBox(height: 20),
            _buildMotiveTile('Maladie / Santé', Icons.sick_outlined),
            _buildMotiveTile('Raison Familiale', Icons.family_restroom),
            _buildMotiveTile('Autre motif', Icons.info_outline),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notification envoyée à l\'école'),
                      backgroundColor: AppTheme.forestGreen,
                    ),
                  );
                },
                style: AppTheme.primaryButtonStyle,
                child: const Text('Envoyer le justificatif'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotiveTile(String label, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.seaBlue),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right, size: 16),
      onTap: () {},
    );
  }

  List<Map<String, dynamic>> _parseHomeworks() {
    final dynamic dashboardHomeworks = _dashboardData?['homeworks'];
    final dynamic childHomeworks = widget.child['homeworks'];

    List<dynamic>? source;
    if (dashboardHomeworks is List && dashboardHomeworks.isNotEmpty) {
      source = dashboardHomeworks;
    } else if (childHomeworks is List && childHomeworks.isNotEmpty) {
      source = childHomeworks;
    }

    if (source == null) return [];

    return source
        .whereType<Map>()
        .map((dynamic hw) {
          final map = Map<String, dynamic>.from(hw as Map);

          map['titre'] ??= map['topic'] ?? map['title'] ?? 'Devoir';
          map['matiere'] ??= map['subject'] ?? 'Matière';
          map['description'] ??= map['description_longue'] ?? map['details'];
          map['type'] = (map['type'] ?? map['category'] ?? 'maison').toString().toLowerCase();

          if (map['date_remise'] == null) {
            final rawDue = map['dueDate'] ?? map['deadline'];
            if (rawDue is String && rawDue.isNotEmpty) {
              map['date_remise'] = rawDue;
            } else {
              map['date_remise'] = DateTime.now().add(const Duration(days: 2)).toIso8601String();
            }
          }

          map['created_at'] ??= map['createdAt'] ?? map['date'] ?? DateTime.now().toIso8601String();
          map['is_targeted'] = map['is_targeted'] ?? map['ciblage'] ?? (map['ciblage_eleve_id'] != null) ?? false;

          return map;
        })
        .toList();
  }

  Widget _buildHomeworkSummary() {
    final homeworks = _parseHomeworks();
    if (homeworks.isEmpty) {
      return _buildEmptyHomeworkCard();
    }

    final nextHomework = homeworks.first;
    final type = nextHomework['type']?.toString() ?? 'maison';
    final title = nextHomework['titre']?.toString() ?? 'Devoir';
    final matiere = nextHomework['matiere']?.toString() ?? 'Matière';
    final dueDate = _formatHomeworkDate(nextHomework['date_remise']);
    final isTargeted = nextHomework['is_targeted'] == true;

    return GestureDetector(
      onTap: () => _tabController.animateTo(2),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getHomeworkTypeColor(type).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(_getHomeworkTypeIcon(type), color: _getHomeworkTypeColor(type)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getHomeworkTypeLabel(type),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _getHomeworkTypeColor(type)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.class_, size: 16, color: AppTheme.textGrey),
                const SizedBox(width: 6),
                Text(matiere, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                const Spacer(),
                const Icon(Icons.calendar_today, size: 16, color: AppTheme.textGrey),
                const SizedBox(width: 6),
                Text(dueDate, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
            if (isTargeted) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.push_pin, size: 14, color: Colors.orange),
                    SizedBox(width: 6),
                    Text('Devoir ciblé pour votre enfant', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.orange)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Text('Voir les détails', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.seaBlue)),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.seaBlue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeworksList() {
    final homeworks = _parseHomeworks();

    if (homeworks.isEmpty) {
      return _buildEmptyHomeworkCard();
    }

    return Column(
      children: homeworks.map((hw) {
        final type = hw['type']?.toString() ?? 'maison';
        final matiere = hw['matiere']?.toString() ?? 'Matière';
        final title = hw['titre']?.toString() ?? 'Devoir';
        final description = hw['description']?.toString();
        final dueDate = _formatHomeworkDate(hw['date_remise']);
        final createdAt = _formatHomeworkDate(hw['created_at']);
        final isTargeted = hw['is_targeted'] == true;
        final hwId = hw['id']?.toString();
        final isHighlighted = widget.highlightHomeworkId != null && widget.highlightHomeworkId == hwId;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: ExpansionTile(
            backgroundColor: isHighlighted ? AppTheme.seaBlue.withOpacity(0.05) : Colors.white,
            collapsedBackgroundColor: isHighlighted ? AppTheme.seaBlue.withOpacity(0.05) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: isHighlighted ? BorderSide(color: AppTheme.seaBlue, width: 2) : BorderSide.none,
            ),
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: isHighlighted ? BorderSide(color: AppTheme.seaBlue, width: 2) : BorderSide.none,
            ),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getHomeworkTypeColor(type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_getHomeworkTypeIcon(type), color: _getHomeworkTypeColor(type)),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      matiere,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getHomeworkTypeColor(type).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getHomeworkTypeLabel(type).toUpperCase(),
                        style: TextStyle(
                          color: _getHomeworkTypeColor(type),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (hw['enseignant_nom'] != null && hw['enseignant_nom'].toString().trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2.0),
                          child: Icon(Icons.person, size: 12, color: AppTheme.textGrey),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            hw['enseignant_nom'].toString(),
                            style: const TextStyle(
                              color: AppTheme.textGrey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.blueGrey[700],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_month, size: 14, color: AppTheme.textGrey),
                          const SizedBox(width: 4),
                          Text('À rendre le $dueDate', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.schedule, size: 14, color: AppTheme.textGrey),
                          const SizedBox(width: 4),
                          Text('Publié $createdAt', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isTargeted)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Row(
                      children: const [
                        Icon(Icons.push_pin, size: 14, color: Colors.orange),
                        SizedBox(width: 4),
                        Text('Ciblé pour votre enfant', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.orange)),
                      ],
                    ),
                  ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    if (description != null && description.isNotEmpty) ...[
                      const Text(
                        'Consignes :',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyHomeworkCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text(
          'Aucun devoir prévu',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  String _formatHomeworkDate(dynamic date) {
    if (date == null) return '--/--/----';
    try {
      final dt = DateTime.parse(date.toString());
      return DateFormat('dd/MM/yyyy', 'fr_FR').format(dt);
    } catch (_) {
      return date.toString();
    }
  }

  String _getHomeworkTypeLabel(String type) {
    switch (type) {
      case 'classe':
        return 'Devoir de classe';
      case 'exercice':
        return 'Exercice maison';
      case 'maison':
      default:
        return 'Devoir de maison';
    }
  }

  Color _getHomeworkTypeColor(String type) {
    switch (type) {
      case 'classe':
        return Colors.green;
      case 'exercice':
        return Colors.orange;
      case 'maison':
      default:
        return Colors.blue;
    }
  }

  IconData _getHomeworkTypeIcon(String type) {
    switch (type) {
      case 'classe':
        return Icons.school;
      case 'exercice':
        return Icons.edit_note;
      case 'maison':
      default:
        return Icons.home_work;
    }
  }

  // Helper methods for news display
  Color _getNewsTypeColor(String? type) {
    switch (type?.toUpperCase()) {
      case 'MESSE':
        return Colors.purple;
      case 'EVENT':
      case 'EVENEMENT':
        return Colors.orange;
      case 'INFO':
      case 'INFORMATION':
        return Colors.blue;
      case 'URGENT':
        return Colors.red;
      default:
        return AppTheme.seaBlue;
    }
  }

  IconData _getNewsTypeIcon(String? type) {
    switch (type?.toUpperCase()) {
      case 'MESSE':
        return Icons.church;
      case 'EVENT':
      case 'EVENEMENT':
        return Icons.event;
      case 'INFO':
      case 'INFORMATION':
        return Icons.info;
      case 'URGENT':
        return Icons.warning;
      default:
        return Icons.notifications;
    }
  }

  String _formatNewsDate(dynamic date) {
    if (date == null) return '';
    try {
      final DateTime dt = DateTime.parse(date.toString());
      return DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(dt);
    } catch (e) {
      return date.toString();
    }
  }

  Widget _buildNewsTab() {
    final actualites = _dashboardData?['actualites'] as List<dynamic>? ?? [];
    
    // DEBUG: Afficher les actualités dans l'onglet Actualités
    print('[DEBUG ACTUALITES Tab] actualites count: ${actualites.length}');
    print('[DEBUG ACTUALITES Tab] actualites data: $actualites');
    
    if (actualites.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: const Center(
            child: Text(
              'Aucune actualité pour le moment.',
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ),
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actualités de l\'école',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ...actualites.map((actu) {
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image avec badge type
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.network(
                          actu['image_url'] ?? 'https://i.pinimg.com/736x/51/b1/a7/51b1a798455b0af03492963412bf1689.jpg',
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 220,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 50, color: Colors.grey),
                          ),
                        ),
                      ),
                      // Badge type coloré
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: _getNewsTypeColor(actu['type']),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getNewsTypeIcon(actu['type']),
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                (actu['type'] ?? 'ANNONCE').toString().toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titre
                        Text(
                          actu['titre'] ?? 'Information',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.3),
                        ),
                        const SizedBox(height: 14),
                        // Description complète
                        Text(
                          actu['contenu'] ?? '',
                          style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.6),
                        ),
                        const SizedBox(height: 16),
                        // Détails : Date, Heure, Prêtre
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              if (actu['date'] != null) ...[
                                _buildDetailRow(Icons.calendar_today, 'Date', 
                                  DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(DateTime.parse(actu['date']))),
                                const SizedBox(height: 8),
                              ],
                              if (actu['heure'] != null) ...[
                                _buildDetailRow(Icons.access_time, 'Heure', actu['heure']),
                                const SizedBox(height: 8),
                              ],
                              if (actu['celebrant'] != null || actu['pretre'] != null) ...[
                                _buildDetailRow(Icons.person, 'Célébrant', 
                                  actu['celebrant'] ?? actu['pretre'] ?? 'Prêtre Gabonais'),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.seaBlue),
        const SizedBox(width: 10),
        Text(
          '$label : ',
          style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildHomeworksTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tous les devoirs',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          _buildHomeworksList(),
        ],
      ),
    );
  }

  Widget _buildTeachersTab() {
    final List<dynamic> teachers = _dashboardData?['teachers'] ?? [];

    if (teachers.isEmpty) {
      return const Center(
        child: Text(
          'Aucun professeur trouvé pour cette classe.',
          style: TextStyle(color: Colors.grey, fontSize: 15),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: teachers.length,
      itemBuilder: (context, index) {
        final teacher = teachers[index];
        final String fullName = "${teacher['prenom'] ?? ''} ${teacher['nom'] ?? ''}".trim();
        final String subject = teacher['matiere'] ?? 'Matière Inconnue';
        final bool isPrincipal = teacher['is_principal'] == true;
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isPrincipal ? AppTheme.seaBlue.withOpacity(0.5) : Colors.grey[100]!),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
            ],
          ),
          child: Column(
            children: [
              // Info row avec avatar et nom
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: isPrincipal ? AppTheme.seaBlue.withOpacity(0.2) : AppTheme.seaBlue.withOpacity(0.12),
                    child: Text(
                      fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: isPrincipal ? AppTheme.seaBlue : AppTheme.seaBlue.withOpacity(0.8),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nom complet avec badge Principal
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                fullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isPrincipal) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.seaBlue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star, color: Colors.white, size: 12),
                                    SizedBox(width: 4),
                                    Text(
                                      'Principal',
                                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subject,
                          style: TextStyle(
                            color: AppTheme.textGrey,
                            fontSize: 14,
                            fontWeight: isPrincipal ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AppointmentPage(
                              source: AppointmentSource.parent,
                              targetName: fullName.isNotEmpty && fullName != ' ' ? fullName : 'Professeur',
                              studentName: widget.child['prenom'] ?? widget.child['name'],
                              enseignantId: int.tryParse(teacher['id']?.toString() ?? ''),
                              eleveId: int.tryParse(widget.child['id']?.toString() ?? ''),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2596be),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: const Text(
                        'Prendre RDV',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(conversation: {
                              'enseignant_id': teacher['id'],
                              'enseignant_nom': teacher['nom'],
                              'enseignant_prenom': teacher['prenom'],
                              'subject': subject,
                            }),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.withOpacity(0.1),
                        foregroundColor: Colors.green.shade700,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.chat, size: 18),
                      label: const Text(
                        'Discuter',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
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

  Widget _buildNotesTab() {
    final List<dynamic> grades = _dashboardData?['grades'] ?? [];

    if (grades.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Aucune note trouvée.',
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RELEVÉ DES NOTES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 15),
          ...grades.map((g) => _buildGradeItem(g)),
        ],
      ),
    );
  }

  Widget _buildGradeItem(Map<String, dynamic> g) {
    bool isBad = g['isBad'] == true;
    final String subject = g['matiere'] ?? g['subject'] ?? 'Inconnu';
    final String topic = g['titre'] ?? g['topic'] ?? 'Devoir';
    final String grade = g['note'] ?? g['grade'] ?? '0/20';
    final String teacher = g['teacher'] ?? '';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isBad ? Colors.red.withOpacity(0.1) : Colors.grey[100]!,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppTheme.seaBlue,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  topic,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (teacher.isNotEmpty)
                  Text(
                    'Prof: $teacher',
                    style: TextStyle(color: AppTheme.textGrey, fontSize: 11),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                grade,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isBad ? Colors.red : AppTheme.seaBlue,
                ),
              ),
              if (isBad && teacher.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppointmentPage(
                            source: AppointmentSource.parent,
                            targetName: teacher,
                            studentName: widget.child['prenom'] ?? widget.child['name'],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Prendre RDV',
                        style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentCard({
    required String title,
    required String subtitle,
    required String type,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppointmentPage(
                      source: AppointmentSource.parent,
                      targetName: 'Administration',
                      studentName: widget.child['name'],
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.calendar_month, size: 16),
              label: const Text(
                'DEMANDER UN RDV',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfosTab() {
    final finances = _dashboardData?['finances'];
    final allInfos = _dashboardData?['adminInfos'] as List<dynamic>? ?? [];
    
    // DEBUG: Afficher les données finances reçues
    print('[DEBUG INFOS Tab] finances data: $finances');
    print('[DEBUG INFOS Tab] finances type: ${finances?.runtimeType}');
    print('[DEBUG INFOS Tab] solde_restant: ${finances?['solde_restant']}');
    print('[DEBUG INFOS Tab] _dashboardData keys: ${_dashboardData?.keys.toList()}');

    final financialInfos = allInfos.where((info) => info['type'] == 'finance' || info['montant'] != null).toList();
    final adminInfos = allInfos.where((info) => info['type'] != 'finance' && info['montant'] == null).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section INCIDENTS SIGNALÉS
          if (_incidents.isNotEmpty) ...[
            const Text(
              'INCIDENTS SIGNALÉS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.red,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 15),
            ..._incidents.map((incident) {
              final bool isHighlighted = widget.highlightIncidentId != null && 
                  widget.highlightIncidentId == incident['id'].toString();
              final bool isRead = incident['is_read'] == true;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isHighlighted ? Colors.red[100] : (isRead ? Colors.grey[50] : Colors.red[50]),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isHighlighted ? Colors.red : Colors.red[200]!,
                    width: isHighlighted ? 2 : 1,
                  ),
                  boxShadow: isHighlighted ? [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ] : null,
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
                          child: Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red[700],
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                incident['type_label'] ?? 'Incident',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.red[800],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Signalé par ${incident['enseignant_nom']} - ${incident['matiere'] ?? 'Matière non spécifiée'}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isRead)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Nouveau',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (incident['description'] != null && incident['description'].toString().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        incident['description'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[800],
                          height: 1.4,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Le ${incident['date']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        if (!isRead)
                          TextButton.icon(
                            onPressed: () => _markIncidentAsRead(incident['id'].toString()),
                            icon: const Icon(Icons.check_circle, size: 16),
                            label: const Text('Marquer comme lu'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 30),
          ],
          // Afficher la section finances uniquement si solde_restant existe et est > 0
          // Gérer le cas où solde_restant est une String ou un int
          Builder(
            builder: (context) {
              final soldeRaw = finances?['solde_restant'];
              
              // DEBUG: Afficher le solde reçu
              print('[DEBUG FINANCES Builder] soldeRaw: $soldeRaw');
              print('[DEBUG FINANCES Builder] soldeRaw type: ${soldeRaw?.runtimeType}');
              
              final solde = soldeRaw is int 
                  ? soldeRaw 
                  : (soldeRaw is String ? int.tryParse(soldeRaw) : null);
              
              print('[DEBUG FINANCES Builder] solde parsed: $solde');
              
              if (solde == null || solde <= 0) {
                print('[DEBUG FINANCES Builder] Section cachée car solde = $solde');
                return const SizedBox.shrink(); // Ne rien afficher si solde = 0 ou null
              }
              print('[DEBUG FINANCES Builder] Section affichée avec solde = $solde');
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SITUATION FINANCIÈRE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.seaBlue, Color(0xFF1565C0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: AppTheme.seaBlue.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Reste à payer', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 5),
                        Text(
                          '$solde FCFA',
                          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Prochain paiement', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                const SizedBox(height: 2),
                                Text(
                                  finances['prochain_paiement'] != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(finances['prochain_paiement'])) : 'N/A',
                                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () => _showPaymentModal(solde),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppTheme.seaBlue,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              child: const Text('PAYER', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
            
          if (financialInfos.isNotEmpty) ...[
            const SizedBox(height: 15),
            ...financialInfos.map((info) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red[100]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red[700]),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(info['titre'] ?? 'Règlement de frais de scolarité', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red[800])),
                          const SizedBox(height: 4),
                          Text(info['contenu'] ?? '', style: TextStyle(color: Colors.red[900], fontSize: 13, height: 1.4)),
                          if (info['montant'] != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Payé', style: TextStyle(fontSize: 12, color: Colors.green[700], fontWeight: FontWeight.bold)),
                                    Text('${info['montant_paye'] ?? 0} FCFA', style: TextStyle(fontSize: 14, color: Colors.green[800], fontWeight: FontWeight.w900)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('Reste', style: TextStyle(fontSize: 12, color: Colors.red[700], fontWeight: FontWeight.bold)),
                                    Text('${info['montant_restant'] ?? info['montant']} FCFA', style: TextStyle(fontSize: 14, color: Colors.red[800], fontWeight: FontWeight.w900)),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 8),
                            Stack(
                              children: [
                                Container(
                                  height: 8,
                                  width: double.infinity,
                                  decoration: BoxDecoration(color: Colors.red[200], borderRadius: BorderRadius.circular(4)),
                                ),
                                FractionallySizedBox(
                                  widthFactor: (double.tryParse(info['montant']?.toString() ?? '1') ?? 1) > 0 
                                    ? ((double.tryParse(info['montant_paye']?.toString() ?? '0') ?? 0) / (double.tryParse(info['montant']?.toString() ?? '1') ?? 1)).clamp(0.0, 1.0) 
                                    : 0,
                                  child: Container(
                                    height: 8,
                                    decoration: BoxDecoration(color: Colors.green[600], borderRadius: BorderRadius.circular(4)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Center(child: Text('Total : ${info['montant']} FCFA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red[900], fontSize: 12))),
                          ]
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

          const SizedBox(height: 30),
          const Text(
            'MESSAGES ADMINISTRATION',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 15),
          if (adminInfos.isEmpty)
            const Center(child: Text('Aucun message', style: TextStyle(color: Colors.grey)))
          else
            ...adminInfos.map((info) {
              bool isConvocation = info['type'] == 'convocation';
              Color bgColor = isConvocation ? Colors.orange[50]! : Colors.white;
              Color iconColor = isConvocation ? Colors.orange[700]! : Colors.blue[700]!;
              IconData icon = isConvocation ? Icons.calendar_month : Icons.info_outline;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                  border: Border.all(color: isConvocation ? Colors.orange[200]! : Colors.grey[100]!),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: isConvocation ? Colors.orange[100] : Colors.blue[50], shape: BoxShape.circle),
                      child: Icon(icon, color: iconColor),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(info['titre'] ?? 'Information', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text(info['contenu'] ?? '', style: TextStyle(color: Colors.grey[800], fontSize: 13, height: 1.4)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  void _showPaymentModal(dynamic amount) {
    String phone = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Paiement Mobile Money', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Montant :  FCFA', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextField(
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Numéro de téléphone',
                hintText: 'Ex: 066xxxxxx',
                prefixIcon: const Icon(Icons.phone_android),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) => phone = val,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Demande de paiement envoyée sur votre téléphone.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.seaBlue),
            child: const Text('Valider', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildStatHeader(),
        const SizedBox(height: 25),
        const Text(
          'COMPARAISON TRIMESTRIELLE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 15),
        _buildTermComparison(),
        const SizedBox(height: 30),
        const Text(
          'POINTS D\'ATTENTION',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 15),
        _buildVulnerabilityCard(),
        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildStatHeader() {
    String average = 'N/A';
    String absences = 'N/A';
    String conduite = 'N/A';

    // Extraction dynamique des statistiques si disponibles
    if (_dashboardData != null) {
      if (_dashboardData!['attendance'] != null) {
        final statut = _dashboardData!['attendance']['statut'];
        absences = (statut == 'Absente' || statut == 'Absent') ? '1j' : '0j';
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2596be), Color(0xFF1a7a9e)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2596be).withOpacity(0.35),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Moyenne — 2ᵉ Trimestre',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$average / 20',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'T2 EN COURS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(color: Colors.white24),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat('Total Absences', absences),
              _buildMiniStat('Note Conduite', conduite),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildEvolutionGraph() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBar(0.4, 'Oct'),
                _buildBar(0.6, 'Nov'),
                _buildBar(0.5, 'Déc'),
                _buildBar(0.7, 'Jan'),
                _buildBar(0.85, 'Fév', isSelected: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(
    double heightFactor,
    String label, {
    bool isSelected = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 30,
          height: 120 * heightFactor,
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.seaBlue
                : AppTheme.seaBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.seaBlue : Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTermComparison() {
    final String childName = widget.child['name'].split(' ')[0];

    Widget termBadge(
      String label,
      String avg,
      String rang, {
      bool isPending = false,
    }) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isPending ? Colors.grey[100] : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isPending
                  ? Colors.grey[300]!
                  : const Color(0xFF2596be).withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isPending ? Colors.grey : const Color(0xFF2596be),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isPending ? 'En cours...' : '$avg/20',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: isPending ? Colors.grey : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isPending ? '' : 'Rang $rang',
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        termBadge('1er Trimestre', 'N/A', '-'),
        const SizedBox(width: 10),
        termBadge('2ᵉ Trimestre', 'N/A', '-'),
        const SizedBox(width: 10),
        termBadge('3ᵉ Trimestre', '', '', isPending: true),
      ],
    );
  }

  Widget _buildCauseRow(
    IconData icon,
    String subject,
    String progression,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Text(
          subject,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(width: 8),
        Text(
          progression,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildVulnerabilityCard() {
    String title = 'Point de vigilance';
    String message = 'Maintenez les efforts pour ce trimestre.';
    Color color = Colors.blue;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: color, size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(color: Colors.black87, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
