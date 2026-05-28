import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/shared/pages/appointment_page.dart';
import 'package:app_mobile/shared/config/api_client.dart';
import 'package:intl/intl.dart';

class ChildDetailsView extends StatefulWidget {
  final Map<String, dynamic> child;
  final VoidCallback onBack;
  final VoidCallback onGoToCalendar;
  final VoidCallback onShowNotifications;

  const ChildDetailsView({
    super.key,
    required this.child,
    required this.onBack,
    required this.onGoToCalendar,
    required this.onShowNotifications,
  });

  @override
  State<ChildDetailsView> createState() => _ChildDetailsViewState();
}

class _ChildDetailsViewState extends State<ChildDetailsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _dashboardData;
  bool _isLoadingDashboard = false;

  Future<void> _fetchDashboard() async {
    if (widget.child['fromApi'] != true) return;
    
    setState(() => _isLoadingDashboard = true);
    try {
      final id = widget.child['id'];
      final response = await ApiClient.instance.get('/eleves//dashboard');
      if (mounted) {
        setState(() {
          _dashboardData = response.data;
          _isLoadingDashboard = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingDashboard = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _fetchDashboard();
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
    final bool isAbsent = widget.child['status'] == 'Absente' || widget.child['status'] == 'Absent';

    return SingleChildScrollView(
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
                    Icons.sick_outlined,
                    size: 16,
                    color: AppTheme.sunYellow,
                  ),
                  label: const Text(
                    'Signaler absence',
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
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        (widget.child['statusColor'] as Color? ?? Colors.green)
                            .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          (widget.child['statusColor'] as Color? ??
                                  Colors.green)
                              .withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isAbsent
                                ? Icons.cancel
                                : (widget.child['status'] == 'En retard'
                                    ? Icons.warning
                                    : Icons.check_circle),
                            color:
                                widget.child['statusColor'] as Color? ??
                                Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Statut',
                            style: TextStyle(
                              color:
                                  widget.child['statusColor'] as Color? ??
                                  Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.child['status'] ?? 'Présent',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color:
                              widget.child['statusColor'] as Color? ??
                              const Color(0xFF1B5E20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isAbsent
                        ? Colors.grey.withOpacity(0.1)
                        : const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isAbsent
                          ? Colors.grey.withOpacity(0.1)
                          : Colors.blue.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_filled,
                            color: isAbsent
                                ? Colors.grey
                                : const Color(0xFF1565C0),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Arrivée',
                            style: TextStyle(
                              color: isAbsent
                                  ? Colors.grey
                                  : const Color(0xFF1565C0),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isAbsent ? '--:--' : (widget.child['arrivalTime'] ?? '07:55'),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isAbsent
                              ? Colors.grey[700]
                              : const Color(0xFF0D47A1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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

          _buildHomeworksList(),

          const SizedBox(height: 30),
          const Text(
            'Actualités de l\'école',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          Builder(
            builder: (context) {
              final actualites = _dashboardData?['actualites'] as List<dynamic>? ?? [];
              if (actualites.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: const Center(
                    child: Text(
                      'Aucune actualité récente',
                      style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                  ),
                );
              }
              return Column(
                children: actualites.map((actu) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              (actu['type'] ?? 'ANNONCE').toString().toUpperCase(),
                              style: TextStyle(color: Colors.blue[800], fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(actu['titre'] ?? 'Information', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(actu['contenu'] ?? '', style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5)),
                          const SizedBox(height: 12),
                          Text(actu['date'] != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(actu['date'])) : '', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
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

  Widget _buildHomeworksList() {
    final rawHomeworks = widget.child['homeworks'];
    final homeworks = rawHomeworks is List 
        ? rawHomeworks.map((e) => e as Map<String, dynamic>).toList()
        : null;

    if (homeworks == null || homeworks.isEmpty) {
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

    return Column(
      children: homeworks.map((hw) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: ExpansionTile(
            backgroundColor: Colors.white,
            collapsedBackgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (hw['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.menu_book, color: hw['color']),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    hw['subject'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (hw['type'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: (hw['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      hw['type'],
                      style: TextStyle(
                        color: hw['color'],
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hw['topic'],
                  style: TextStyle(
                    color: Colors.blueGrey[700],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (hw['status'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      hw['status'],
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
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
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Horaire : ${hw['time']}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (hw['description'] != null) ...[
                      const Text(
                        'Consignes :',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hw['description'],
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

  Widget _buildNewsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.asset(
                    widget.child['newsImage'] ??
                        'assets/images/profil/actualité/actu1.png',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Séance discussion sur métier d\'avenir',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Dans le cadre de l\'orientation scolaire, une séance d\'échange est organisée avec des professionnels de divers secteurs.',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 15,
                          height: 1.5,
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
    final String childName = widget.child['name'].split(' ')[0];

    final List<Map<String, dynamic>> teachers;

    if (childName == 'Yannick') {
      // Notre Dame de Quaben — Terminale C
      teachers = [
        {
          'name': 'M. Obiang',
          'subject': 'Mathématiques',
          'color': AppTheme.seaBlue,
          'mode': 'Présentiel',
        },
        {
          'name': 'M. Okoro',
          'subject': 'SVT (Sciences de la Vie)',
          'color': Colors.red,
          'mode': 'Présentiel',
        },
        {
          'name': 'M. Mvondo',
          'subject': 'Physique-Chimie',
          'color': Colors.orange,
          'mode': 'Présentiel',
        },
        {
          'name': 'Mme Zara',
          'subject': 'Philosophie',
          'color': Colors.purple,
          'mode': 'Visioconférence',
        },
        {
          'name': 'M. Bongo',
          'subject': 'Histoire-Géographie',
          'color': Colors.brown,
          'mode': 'Présentiel',
        },
      ];
    } else if (childName == 'Emmanuella') {
      // Lycée Michel Montaigne — 3ème
      teachers = [
        {
          'name': 'Mme Eyi',
          'subject': 'Français',
          'color': Colors.indigo,
          'mode': 'Présentiel',
        },
        {
          'name': 'Miss Sarah',
          'subject': 'Anglais',
          'color': Colors.teal,
          'mode': 'Présentiel',
        },
        {
          'name': 'M. Abessolo',
          'subject': 'Physique-Chimie',
          'color': Colors.green,
          'mode': 'Visioconférence',
        },
        {
          'name': 'M. Ndong',
          'subject': 'Mathématiques',
          'color': AppTheme.seaBlue,
          'mode': 'Présentiel',
        },
        {
          'name': 'Mme Koumba',
          'subject': 'Histoire-Géographie',
          'color': Colors.brown,
          'mode': 'Présentiel',
        },
      ];
    } else {
      // Junior — Scolaire Bambino Village — 5e Année
      teachers = [
        {
          'name': 'Mme Eyi',
          'subject': 'Français',
          'color': Colors.redAccent,
          'mode': 'Visioconférence',
        },
        {
          'name': 'M. Koumba',
          'subject': 'Histoire-Géographie',
          'color': Colors.brown,
          'mode': 'Présentiel',
        },
        {
          'name': 'Mme Nze',
          'subject': 'Mathématiques',
          'color': AppTheme.seaBlue,
          'mode': 'Présentiel',
        },
        {
          'name': 'M. Mbadinga',
          'subject': 'Sciences Naturelles',
          'color': Colors.green,
          'mode': 'Présentiel',
        },
        {
          'name': 'Mme Ondo',
          'subject': 'Éducation Civique',
          'color': Colors.orange,
          'mode': 'Présentiel',
        },
      ];
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: teachers.length,
      itemBuilder: (context, index) {
        final teacher = teachers[index];
        final Color tColor = teacher['color'] as Color;
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[100]!),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: tColor.withOpacity(0.12),
                child: Text(
                  teacher['name'].split(' ').last[0],
                  style: TextStyle(color: tColor, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacher['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      teacher['subject'],
                      style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppointmentPage(
                        source: AppointmentSource.parent,
                        targetName: teacher['name'],
                        studentName: widget.child['name'],
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2596be),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                child: const Text(
                  'RDV',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotesTab() {
    final String childName = widget.child['name'].split(' ')[0];
    final List<Map<String, dynamic>> grades;

    if (childName == 'Yannick') {
      grades = [
        {
          'subject': 'SVT',
          'topic': 'Devoir maison (Génétique)',
          'grade': '08/20',
          'isBad': true,
          'teacher': 'M. Okoro',
          'date': 'Aujourd\'hui',
        },
        {
          'subject': 'Mathématiques',
          'topic': 'Devoir en classe n°1',
          'grade': '14/20',
          'isBad': false,
          'teacher': 'M. Obiang',
          'date': '20 Fév',
        },
        {
          'subject': 'Philosophie',
          'topic': 'Dissertation',
          'grade': '11/20',
          'isBad': false,
          'teacher': 'Mme. Zara',
          'date': '12 Fév',
        },
      ];
    } else if (childName == 'Junior') {
      grades = [
        {
          'subject': 'Français',
          'topic': 'Devoir en classe (Dictée)',
          'grade': '00/20',
          'isBad': true,
          'teacher': 'Mme. Eyi',
          'date': 'Aujourd\'hui',
        },
        {
          'subject': 'Histoire-Géo',
          'topic': 'Contrôle continu',
          'grade': '13/20',
          'isBad': false,
          'teacher': 'M. Koumba',
          'date': '15 Fév',
        },
      ];
    } else {
      grades = [
        {
          'subject': 'Français',
          'topic': 'Interrogation Orale',
          'grade': '12/20',
          'isBad': false,
          'teacher': 'Mme. Eyi',
          'date': '18 Fév',
        },
        {
          'subject': 'Anglais',
          'topic': 'Vocabulary Test',
          'grade': '16/20',
          'isBad': false,
          'teacher': 'Miss Sarah',
          'date': '10 Fév',
        },
      ];
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
    bool isBad = g['isBad'] as bool;
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
                  g['subject'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppTheme.seaBlue,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  g['topic'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Prof: ${g['teacher']}',
                  style: TextStyle(color: AppTheme.textGrey, fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                g['grade'],
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isBad ? Colors.red : AppTheme.seaBlue,
                ),
              ),
              if (isBad)
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppointmentPage(
                            source: AppointmentSource.parent,
                            targetName: g['teacher'],
                            studentName: widget.child['name'],
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
                        style: TextStyle(
                          color: Colors.red,
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
    final adminInfos = _dashboardData?['adminInfos'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
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
          if (finances != null)
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
                    ' ',
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
                        onPressed: () => _showPaymentModal(finances['solde_restant']),
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
            )
          else
            const Text('Données financières non disponibles', style: TextStyle(color: Colors.grey)),
            
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
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                  border: Border.all(color: Colors.grey[100]!),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
                      child: Icon(Icons.info_outline, color: Colors.blue[700]),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(info['titre'] ?? 'Information', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text(info['contenu'] ?? '', style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4)),
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
    final String childName = widget.child['name'].split(' ')[0];
    // Moyenne 2e trimestre, absences, conduite par enfant
    String average = '10.00';
    String absences = '0j';
    String conduite = 'A';

    if (childName == 'Yannick') {
      average = '10.00'; // 2e trim
      absences = '2j';
      conduite = 'B';
    } else if (childName == 'Emmanuella') {
      average = '14.80';
      absences = '1j';
      conduite = 'A';
    } else if (childName == 'Junior') {
      average = '09.50';
      absences = '5j';
      conduite = 'C';
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

    if (childName == 'Yannick') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              termBadge('1er Trimestre', '12', '10ᵉ'),
              const SizedBox(width: 10),
              termBadge('2ᵉ Trimestre', '10', '20ᵉ'),
              const SizedBox(width: 10),
              termBadge('3ᵉ Trimestre', '', '', isPending: true),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.red.withOpacity(0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.trending_down, color: Colors.red, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Causes de la chute (T1→T2)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildCauseRow(
                  Icons.science_outlined,
                  'SVT',
                  '15/20 → 08/20',
                  Colors.red,
                ),
                const SizedBox(height: 6),
                _buildCauseRow(
                  Icons.psychology_outlined,
                  'Philosophie',
                  '13/20 → 11/20',
                  Colors.orange,
                ),
              ],
            ),
          ),
        ],
      );
    } else if (childName == 'Emmanuella') {
      return Row(
        children: [
          termBadge('1er Trimestre', '14', '5ᵉ'),
          const SizedBox(width: 10),
          termBadge('2ᵉ Trimestre', '14.8', '3ᵉ'),
          const SizedBox(width: 10),
          termBadge('3ᵉ Trimestre', '', '', isPending: true),
        ],
      );
    } else {
      return Row(
        children: [
          termBadge('1er Trimestre', '10', '18ᵉ'),
          const SizedBox(width: 10),
          termBadge('2ᵉ Trimestre', '09.5', '20ᵉ'),
          const SizedBox(width: 10),
          termBadge('3ᵉ Trimestre', '', '', isPending: true),
        ],
      );
    }
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
    final String childName = widget.child['name'].split(' ')[0];
    String title = 'Alerte Régression';
    String message =
        'Baisse notable en Sciences. L\'élève avait une meilleure moyenne auparavant.';
    Color color = Colors.red;

    if (childName == 'Yannick') {
      title = 'Alerte SVT';
      message =
          'Chute brutale de la note du devoir de maison (08/20). Yannick avait pourtant eu 15/20 au dernier devoir.';
    } else if (childName == 'Junior') {
      title = 'Alerte Assiduité';
      message =
          'Les retards répétés (notamment à 09:30) commencent à impacter les notes de Français.';
      color = Colors.orange;
    } else {
      title = 'Point de vigilance';
      message =
          'Emmanuella maintient un bon niveau, mais les Mathématiques restent sa matière la plus faible.';
      color = Colors.blue;
    }

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
