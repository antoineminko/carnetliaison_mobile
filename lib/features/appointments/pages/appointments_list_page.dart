import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/shared/config/api_client.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// Page des événements (rendez-vous) avec workflow complet
/// Accepter / Reporter / Refuser / Annuler
class AppointmentsListPage extends StatefulWidget {
  final int userId;
  final String userRole; // 'parent' ou 'enseignant'
  final int?
  initialAppointmentId; // Pour ouvrir un RDV spécifique depuis notification

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
  List<dynamic> _pendingAppointments = []; // En attente
  List<dynamic> _upcomingAppointments = []; // Acceptés à venir
  List<dynamic> _pastAppointments = []; // Passés ou refusés
  bool _isLoading = true;
  int _selectedTab = 0; // 0 = En attente, 1 = À venir, 2 = Historique

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Rafraîchir les données quand on revient sur la page
    // (par exemple après une notification)
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
      final paramName = widget.userRole == 'parent'
          ? 'parent_id'
          : 'enseignant_id';
      final response = await ApiClient.instance.get(
        '/appointments?$paramName=${widget.userId}',
      );

      if (mounted) {
        final allAppointments = response.data['appointments'] ?? [];

        // Trier les rendez-vous par catégorie
        final now = DateTime.now();

        setState(() {
          _appointments = allAppointments;
          _pendingAppointments = allAppointments
              .where(
                (a) => a['statut'] == 'en_attente' || a['statut'] == 'reporte',
              )
              .toList();
          _upcomingAppointments = allAppointments
              .where(
                (a) =>
                    a['statut'] == 'accepte' &&
                    DateTime.parse(a['date_heure']).isAfter(now),
              )
              .toList();
          _pastAppointments = allAppointments
              .where(
                (a) =>
                    a['statut'] == 'refuse' ||
                    a['statut'] == 'cancelled' ||
                    (a['statut'] == 'accepte' &&
                        DateTime.parse(a['date_heure']).isBefore(now)),
              )
              .toList();
          _isLoading = false;
        });

        // Si un appointmentId est fourni, ouvrir la carte correspondante
        if (widget.initialAppointmentId != null) {
          _highlightAppointment(widget.initialAppointmentId!);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur de chargement: $e')));
      }
    }
  }

  void _highlightAppointment(int id) {
    // Trouver l'index de l'appointment dans les listes
    final appointment = _appointments.firstWhere(
      (a) => a['id'] == id,
      orElse: () => null,
    );
    if (appointment != null) {
      // Déterminer dans quelle liste il est
      if (_pendingAppointments.any((a) => a['id'] == id)) {
        setState(() => _selectedTab = 0);
      } else if (_upcomingAppointments.any((a) => a['id'] == id)) {
        setState(() => _selectedTab = 1);
      } else {
        setState(() => _selectedTab = 2);
      }
    }
  }

  /// Accepter un rendez-vous
  Future<void> _acceptAppointment(int id) async {
    try {
      await ApiClient.instance.put(
        '/appointments/$id/status',
        data: {'statut': 'accepte'},
      );
      _fetchAppointments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rendez-vous accepté'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Refuser un rendez-vous
  Future<void> _refuseAppointment(int id) async {
    try {
      await ApiClient.instance.put(
        '/appointments/$id/status',
        data: {'statut': 'refuse'},
      );
      _fetchAppointments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(' Rendez-vous refusé'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Reporter un rendez-vous avec proposition de nouvelle date
  Future<void> _postponeAppointment(
    int id,
    DateTime newDate,
    String reason,
  ) async {
    try {
      await ApiClient.instance.put(
        '/appointments/$id/status',
        data: {
          'statut': 'reporte',
          'new_proposed_date': newDate.toIso8601String(),
          'report_reason': reason,
        },
      );
      _fetchAppointments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🔄 Report proposé'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Accepter une date reportée
  Future<void> _acceptPostponedDate(int id) async {
    try {
      await ApiClient.instance.put('/appointments/$id/accept-postponed');
      _fetchAppointments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Nouvelle date acceptée'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Annuler un rendez-vous
  Future<void> _cancelAppointment(int id) async {
    try {
      await ApiClient.instance.put(
        '/appointments/$id/cancel',
        data: {'user_type': widget.userRole},
      );
      _fetchAppointments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🚫 Rendez-vous annulé'),
            backgroundColor: Colors.grey,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _launchVideoCall(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de lancer l\'appel vidéo.')),
        );
      }
    }
  }

  /// Afficher le modal pour reporter un rendez-vous
  void _showPostponeDialog(int appointmentId) {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));
    String? selectedTime = '14:00';
    final reasonController = TextEditingController();

    final List<String> timeSlots = [
      '08:00',
      '09:00',
      '10:00',
      '11:00',
      '14:00',
      '15:00',
      '16:00',
      '17:00',
      '18:00',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.schedule,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Expanded(
                          child: Text(
                            'Proposer une nouvelle date',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Sélection de la date
                    const Text(
                      'Nouvelle date proposée',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CalendarDatePicker(
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 90)),
                        onDateChanged: (date) {
                          setModalState(() => selectedDate = date);
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Sélection du créneau horaire
                    const Text(
                      'Créneau horaire',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: timeSlots.map((time) {
                        final isSelected = selectedTime == time;
                        return ChoiceChip(
                          label: Text(time),
                          selected: isSelected,
                          selectedColor: AppTheme.seaBlue,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setModalState(() => selectedTime = time);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Raison du report
                    const Text(
                      'Raison du report (optionnel)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: reasonController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Ex: Indisponibilité, congés...',
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Bouton de confirmation
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          final parts = selectedTime!.split(':');
                          final newDate = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            int.parse(parts[0]),
                            int.parse(parts[1]),
                          );
                          Navigator.pop(context);
                          _postponeAppointment(
                            appointmentId,
                            newDate,
                            reasonController.text,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Proposer cette date',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Confirmer l'annulation
  void _showCancelConfirmDialog(int appointmentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler le rendez-vous ?'),
        content: const Text(
          'Cette action est irréversible. Le rendez-vous sera marqué comme annulé.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Non'),
          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Mes Rendez-vous',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.2)
                        : Colors.grey[300],
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
      case 0:
        return _buildAppointmentsList(_pendingAppointments, 'pending');
      case 1:
        return _buildAppointmentsList(_upcomingAppointments, 'upcoming');
      case 2:
        return _buildAppointmentsList(_pastAppointments, 'past');
      default:
        return const SizedBox.shrink();
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
              type == 'pending'
                  ? 'Aucun rendez-vous en attente'
                  : type == 'upcoming'
                  ? 'Aucun rendez-vous à venir'
                  : 'Aucun rendez-vous dans l\'historique',
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
        final bool isHighlighted =
            widget.initialAppointmentId != null &&
            appt['id'] == widget.initialAppointmentId;
        return _buildAppointmentCard(appt, isHighlighted: isHighlighted);
      },
    );
  }

  Widget _buildAppointmentCard(dynamic appt, {bool isHighlighted = false}) {
    final dateHeure = DateTime.parse(appt['date_heure']);
    final status = appt['statut'];
    final mode = appt['mode'] ?? 'presentiel';
    final isVideo = mode == 'video';
    final isVocal = mode == 'vocal';

    // Nom de l'autre partie
    String otherPartyName = '';
    if (widget.userRole == 'parent') {
      final ens = appt['enseignant'];
      if (ens != null) {
        otherPartyName = '${ens['prenom'] ?? ''} ${ens['nom'] ?? ''}'.trim();
      }
    } else {
      final parent = appt['parent'];
      if (parent != null) {
        otherPartyName = '${parent['prenom'] ?? ''} ${parent['nom'] ?? ''}'
            .trim();
      }
    }

    // Nom de l'élève
    String eleveName = '';
    final eleve = appt['eleve'];
    if (eleve != null) {
      eleveName = '${eleve['prenom'] ?? ''} ${eleve['nom'] ?? ''}'.trim();
    }

    final dateFormatted = DateFormat(
      'EEEE d MMMM yyyy',
      'fr_FR',
    ).format(dateHeure);
    final timeFormatted = DateFormat('HH:mm', 'fr_FR').format(dateHeure);

    // Nouvelle date proposée si reporté
    DateTime? newProposedDate;
    if (appt['new_proposed_date'] != null) {
      newProposedDate = DateTime.parse(appt['new_proposed_date']);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppTheme.seaBlue.withOpacity(0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isHighlighted
            ? Border.all(color: AppTheme.seaBlue, width: 2)
            : Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showAppointmentDetails(appt),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header avec mode et statut
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getModeColor(mode).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _getModeIcon(mode),
                          color: _getModeColor(mode),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getModeLabel(mode),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            if (otherPartyName.isNotEmpty)
                              Text(
                                otherPartyName,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                ),
                              ),
                          ],
                        ),
                      ),
                      _buildStatusBadge(status),
                    ],
                  ),
                  const Divider(height: 25),

                  // Objet
                  if (appt['objet'] != null) ...[
                    Text(
                      appt['objet'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Date et heure
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          dateFormatted,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeFormatted,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (eleveName.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.person, size: 16, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(
                          eleveName,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Motif
                  if (appt['motif'] != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.label_outline,
                          size: 14,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          appt['motif'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Nouvelle date proposée (si reporté)
                  if (status == 'reporte' && newProposedDate != null) ...[
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.schedule,
                                color: Colors.orange,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Nouvelle date proposée',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            DateFormat(
                              'EEEE d MMMM yyyy à HH:mm',
                              'fr_FR',
                            ).format(newProposedDate),
                            style: const TextStyle(fontSize: 14),
                          ),
                          if (appt['report_reason'] != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Raison: ${appt['report_reason']}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          // Boutons pour accepter/refuser la nouvelle date
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () =>
                                      _acceptPostponedDate(appt['id']),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Accepter cette date'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Boutons d'action selon le statut
                  const SizedBox(height: 15),
                  _buildActionButtons(appt, status, isVideo, isVocal),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    dynamic appt,
    String status,
    bool isVideo,
    bool isVocal,
  ) {
    final appointmentId = appt['id'];
    final isEnAttente = status == 'en_attente';
    final isAccepte = status == 'accepte';
    final isReporte = status == 'reporte';

    // Déterminer si l'utilisateur peut interagir
    // Si c'est le requester, il ne peut pas accepter/refuser son propre RDV
    // C'est l'autre partie qui doit répondre
    final isRequester =
        (widget.userRole == 'parent' && appt['requester'] == 'parent') ||
        (widget.userRole == 'enseignant' && appt['requester'] == 'enseignant');
    final canRespond = isEnAttente && !isRequester;
    final canPostpone = (isEnAttente || isAccepte) && !isReporte;
    final canCancel = isEnAttente || isAccepte || isReporte;

    return Column(
      children: [
        // Accepter / Refuser (si en attente et pas le requester)
        if (canRespond)
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _acceptAppointment(appointmentId),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Accepter'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _refuseAppointment(appointmentId),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Refuser'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),

        // Reporter / Annuler
        if (canPostpone || canCancel) ...[
          if (canRespond) const SizedBox(height: 10),
          Row(
            children: [
              if (canPostpone)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showPostponeDialog(appointmentId),
                    icon: const Icon(
                      Icons.schedule,
                      size: 18,
                      color: Colors.orange,
                    ),
                    label: const Text('Reporter'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              if (canPostpone && canCancel) const SizedBox(width: 10),
              if (canCancel)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showCancelConfirmDialog(appointmentId),
                    icon: const Icon(
                      Icons.cancel_outlined,
                      size: 18,
                      color: Colors.grey,
                    ),
                    label: const Text('Annuler'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      side: BorderSide(color: Colors.grey[400]!),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],

        // Bouton Rejoindre l'appel (si vidéo et accepté ou en cours)
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showAppointmentDetails(dynamic appt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
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
                  const SizedBox(height: 20),
                  // Contenu détaillé
                  _buildDetailContent(appt),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailContent(dynamic appt) {
    final dateHeure = DateTime.parse(appt['date_heure']);
    final status = appt['statut'];
    final mode = appt['mode'] ?? 'presentiel';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getModeColor(mode).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getModeIcon(mode),
                color: _getModeColor(mode),
                size: 28,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appt['objet'] ?? 'Rendez-vous',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildStatusBadge(status),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),

        // Détails
        _buildDetailSection('Date & Heure', [
          _buildDetailRow(
            Icons.calendar_today,
            DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(dateHeure),
          ),
          _buildDetailRow(
            Icons.access_time,
            DateFormat('HH:mm', 'fr_FR').format(dateHeure),
          ),
        ]),

        _buildDetailSection('Participants', [
          if (widget.userRole == 'parent')
            _buildDetailRow(
              Icons.person_outline,
              'Enseignant: ${appt['enseignant']?['prenom'] ?? ''} ${appt['enseignant']?['nom'] ?? ''}',
            ),
          if (widget.userRole == 'enseignant')
            _buildDetailRow(
              Icons.person_outline,
              'Parent: ${appt['parent']?['prenom'] ?? ''} ${appt['parent']?['nom'] ?? ''}',
            ),
          if (appt['eleve'] != null)
            _buildDetailRow(
              Icons.child_care,
              'Élève: ${appt['eleve']['prenom'] ?? ''} ${appt['eleve']['nom'] ?? ''}',
            ),
        ]),

        if (appt['motif'] != null)
          _buildDetailSection('Motif', [
            _buildDetailRow(Icons.label_outline, appt['motif']),
          ]),

        if (appt['report_reason'] != null)
          _buildDetailSection('Raison du report', [
            _buildDetailRow(Icons.info_outline, appt['report_reason']),
          ]),

        const SizedBox(height: 30),
        // Actions
        _buildActionButtons(appt, status, mode == 'video', mode == 'vocal'),
      ],
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 10),
        ...children,
        const SizedBox(height: 25),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[500]),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  Color _getModeColor(String mode) {
    switch (mode) {
      case 'video':
        return Colors.blue;
      case 'vocal':
        return Colors.orange;
      case 'presentiel':
      default:
        return Colors.green;
    }
  }

  IconData _getModeIcon(String mode) {
    switch (mode) {
      case 'video':
        return Icons.videocam;
      case 'vocal':
        return Icons.phone;
      case 'presentiel':
      default:
        return Icons.location_on;
    }
  }

  String _getModeLabel(String mode) {
    switch (mode) {
      case 'video':
        return 'Appel Vidéo';
      case 'vocal':
        return 'Appel Vocal';
      case 'presentiel':
      default:
        return 'Rendez-vous Présentiel';
    }
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor = Colors.white;
    String label;

    switch (status) {
      case 'accepte':
        bgColor = Colors.green;
        label = 'Accepté';
        break;
      case 'refuse':
        bgColor = Colors.red[400]!;
        label = 'Refusé';
        break;
      case 'reporte':
        bgColor = Colors.orange;
        label = 'Reporté';
        break;
      case 'cancelled':
        bgColor = Colors.grey[500]!;
        label = 'Annulé';
        break;
      default:
        bgColor = Colors.blue;
        label = 'En attente';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
