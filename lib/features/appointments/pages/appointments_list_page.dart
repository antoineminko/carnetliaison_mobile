import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/shared/config/api_client.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:app_mobile/features/appointments/widgets/appointment_card.dart';
import 'package:app_mobile/features/appointments/widgets/appointment_details_sheet.dart';
import 'package:app_mobile/features/appointments/widgets/postpone_bottom_sheet.dart';

class AppointmentsListPage extends StatefulWidget {
  final int userId;
  final String userRole;
  final int? initialAppointmentId;

  const AppointmentsListPage({
    super.key,
    required this.userId,
    required this.userRole,
    this.initialAppointmentId,
  });

  @override
  State<AppointmentsListPage> createState() => _AppointmentsListPageState();
}

class _AppointmentsListPageState extends State<AppointmentsListPage> {
  List<dynamic> _appointments = [];
  List<dynamic> _pendingAppointments = [];
  List<dynamic> _upcomingAppointments = [];
  List<dynamic> _pastAppointments = [];
  bool _isLoading = true;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      final refresh = args['refresh'] as bool? ?? false;
      final appointmentId = args['highlightAppointmentId'] as int?;
      if (refresh || appointmentId != null) {
        _fetchAppointments();
      }
    }
  }

  Future<void> _fetchAppointments() async {
    try {
      final paramName = widget.userRole == 'parent' ? 'parent_id' : 'enseignant_id';
      final response = await ApiClient.instance.get('/appointments?$paramName=${widget.userId}');

      if (mounted) {
        final allAppointments = response.data['appointments'] ?? [];
        final now = DateTime.now();

        setState(() {
          _appointments = allAppointments;
          _pendingAppointments = allAppointments.where((a) => a['statut'] == 'en_attente' || a['statut'] == 'reporte').toList();
          _upcomingAppointments = allAppointments.where((a) => a['statut'] == 'accepte' && _isAfterOrEqual(a['date_heure'], now)).toList();
          _pastAppointments = allAppointments.where((a) => a['statut'] == 'refuse' || a['statut'] == 'cancelled' || (a['statut'] == 'accepte' && _isBefore(a['date_heure'], now))).toList();
          _isLoading = false;
        });

        if (widget.initialAppointmentId != null) {
          _highlightAppointment(widget.initialAppointmentId!);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur de chargement: $e')));
      }
    }
  }

  bool _isAfterOrEqual(dynamic dateStr, DateTime now) {
    if (dateStr == null) return false;
    try {
      final d = DateTime.parse(dateStr.toString());
      return d.isAfter(now) || d.isAtSameMomentAs(now);
    } catch (e) {
      return false;
    }
  }

  bool _isBefore(dynamic dateStr, DateTime now) {
    if (dateStr == null) return true;
    try {
      final d = DateTime.parse(dateStr.toString());
      return d.isBefore(now);
    } catch (e) {
      return true;
    }
  }

  void _highlightAppointment(int id) {
    final appointment = _appointments.firstWhere((a) => a['id'] == id, orElse: () => null);
    if (appointment != null) {
      if (_pendingAppointments.any((a) => a['id'] == id)) {
        setState(() => _selectedTab = 0);
      } else if (_upcomingAppointments.any((a) => a['id'] == id)) {
        setState(() => _selectedTab = 1);
      } else {
        setState(() => _selectedTab = 2);
      }
    }
  }

  Future<void> _updateStatus(int id, String status, {Map<String, dynamic>? extraData}) async {
    try {
      final Map<String, dynamic> data = {'statut': status};
      if (extraData != null) data.addAll(extraData);
      
      await ApiClient.instance.put('/appointments/$id/status', data: data);
      _fetchAppointments();
      if (mounted) {
        Color bgColor = Colors.blue;
        String msg = 'Action effectuée';
        if (status == 'accepte') { bgColor = Colors.green; msg = 'Rendez-vous accepté'; }
        if (status == 'refuse') { bgColor = Colors.orange; msg = 'Rendez-vous refusé'; }
        if (status == 'reporte') { bgColor = Colors.blue; msg = 'Report proposé'; }
        
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: bgColor));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _acceptPostponedDate(int id) async {
    try {
      await ApiClient.instance.put('/appointments/$id/accept-postponed');
      _fetchAppointments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nouvelle date acceptée'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _cancelAppointment(int id) async {
    try {
      await ApiClient.instance.put('/appointments/$id/cancel', data: {'user_type': widget.userRole});
      _fetchAppointments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rendez-vous annulé'), backgroundColor: Colors.grey));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _launchVideoCall(String? url) async {
    if (url == null || url.isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lien vidéo manquant.')));
      return;
    }
    try {
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible de lancer l\'appel vidéo.')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lien vidéo invalide.')));
    }
  }

  void _showPostponeDialog(int appointmentId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PostponeBottomSheet(
        appointmentId: appointmentId,
        onPostpone: (id, newDate, reason) {
          _updateStatus(id, 'reporte', extraData: {
            'new_proposed_date': newDate.toIso8601String(),
            'report_reason': reason,
          });
        },
      ),
    );
  }

  void _showCancelConfirmDialog(int appointmentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler le rendez-vous ?'),
        content: const Text('Cette action est irréversible. Le rendez-vous sera marqué comme annulé.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Non')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelAppointment(appointmentId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
  }

  void _showAppointmentDetails(dynamic appt) {
    final status = appt['statut'];
    final mode = appt['mode'] ?? 'presentiel';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return AppointmentDetailsSheet(
            appt: appt,
            userRole: widget.userRole,
            actionButtons: _buildActionButtons(appt, status, mode == 'video'),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(dynamic appt, String status, bool isVideo) {
    final appointmentId = appt['id'];
    final isEnAttente = status == 'en_attente';
    final isAccepte = status == 'accepte';
    final isReporte = status == 'reporte';

    final isRequester = (widget.userRole == 'parent' && appt['requester'] == 'parent') ||
                        (widget.userRole == 'enseignant' && appt['requester'] == 'enseignant');
    final canRespond = isEnAttente && !isRequester;
    final canPostpone = (isEnAttente || isAccepte) && !isReporte;
    final canCancel = isEnAttente || isAccepte || isReporte;

    return Column(
      children: [
        // Bouton pour accepter la nouvelle date (Si reporté, on l'affiche pour les 2 pour l'instant)
        if (isReporte) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _acceptPostponedDate(appointmentId),
              icon: const Icon(Icons.check_circle_outline, size: 20),
              label: const Text('Accepter cette date'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (canRespond)
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _updateStatus(appointmentId, 'accepte'),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Accepter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _updateStatus(appointmentId, 'refuse'),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Refuser'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        if (canPostpone || canCancel) ...[
          if (canRespond) const SizedBox(height: 10),
          Row(
            children: [
              if (canPostpone)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showPostponeDialog(appointmentId),
                    icon: const Icon(Icons.schedule, size: 18, color: Colors.orange),
                    label: const Text('Reporter'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              if (canPostpone && canCancel) const SizedBox(width: 10),
              if (canCancel)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showCancelConfirmDialog(appointmentId),
                    icon: const Icon(Icons.cancel_outlined, size: 18, color: Colors.grey),
                    label: const Text('Annuler'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      side: BorderSide(color: Colors.grey[400]!),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
            ],
          ),
        ],
        if (isAccepte && isVideo && appt['lien_video'] != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _launchVideoCall(appt['lien_video']),
              icon: const Icon(Icons.video_call, size: 20),
              label: const Text('Rejoindre l\'appel vidéo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.seaBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Mes Rendez-vous', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildTabButton('En attente', 0, _pendingAppointments.length),
                  _buildTabButton('À venir', 1, _upcomingAppointments.length),
                  _buildTabButton('Historique', 2, _pastAppointments.length),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchAppointments,
              child: _buildCurrentTabContent(),
            ),
    );
  }

  Widget _buildTabButton(String label, int index, int count) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.seaBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withOpacity(0.2) : Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTabContent() {
    switch (_selectedTab) {
      case 0: return _buildAppointmentsList(_pendingAppointments, 'pending');
      case 1: return _buildAppointmentsList(_upcomingAppointments, 'upcoming');
      case 2: return _buildAppointmentsList(_pastAppointments, 'past');
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildAppointmentsList(List<dynamic> appointments, String type) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 20),
            Text(
              type == 'pending' ? 'Aucun rendez-vous en attente' :
              type == 'upcoming' ? 'Aucun rendez-vous à venir' :
              'Aucun rendez-vous dans l\'historique',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appt = appointments[index];
        final bool isHighlighted = widget.initialAppointmentId != null && appt['id'] == widget.initialAppointmentId;
        return AppointmentCard(
          appt: appt,
          userRole: widget.userRole,
          isHighlighted: isHighlighted,
          onTap: () => _showAppointmentDetails(appt),
          actionButtons: _buildActionButtons(appt, appt['statut'], appt['mode'] == 'video'),
        );
      },
    );
  }
}
