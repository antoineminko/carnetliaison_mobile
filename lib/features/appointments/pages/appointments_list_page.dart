import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/core/network/api_client.dart';
import 'package:url_launcher/url_launcher.dart';

class AppointmentsListPage extends StatefulWidget {
  final int userId;
  final String userRole; // 'parent' ou 'enseignant'

  const AppointmentsListPage({super.key, required this.userId, required this.userRole});

  @override
  State<AppointmentsListPage> createState() => _AppointmentsListPageState();
}

class _AppointmentsListPageState extends State<AppointmentsListPage> {
  List<dynamic> _appointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    try {
      final paramName = widget.userRole == 'parent' ? 'parent_id' : 'enseignant_id';
      final response = await ApiClient.instance.get('/appointments?$paramName=${widget.userId}');
      
      if (mounted) {
        setState(() {
          _appointments = response.data['appointments'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  Future<void> _updateStatus(int id, String status) async {
    try {
      await ApiClient.instance.put('/appointments/$id/status', data: {'statut': status});
      _fetchAppointments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  Future<void> _launchVideoCall(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Impossible de lancer l\'appel vidéo.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Rendez-vous', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _appointments.isEmpty
              ? const Center(child: Text('Aucun rendez-vous.', style: TextStyle(color: AppTheme.textGrey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _appointments.length,
                  itemBuilder: (context, index) {
                    final appt = _appointments[index];
                    final dateHeure = DateTime.parse(appt['date_heure']);
                    final isVideo = appt['type'] == 'video';
                    final status = appt['statut'];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(isVideo ? Icons.videocam : Icons.meeting_room, color: AppTheme.seaBlue),
                              const SizedBox(width: 10),
                              Text(
                                isVideo ? 'Appel Vidéo' : 'Rendez-vous Physique',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const Spacer(),
                              _buildStatusBadge(status),
                            ],
                          ),
                          const Divider(height: 30),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 16, color: AppTheme.textGrey),
                              const SizedBox(width: 8),
                              Text('${dateHeure.day}/${dateHeure.month}/${dateHeure.year} à ${dateHeure.hour}h${dateHeure.minute.toString().padLeft(2, '0')}'),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text('Motif : ${appt['motif'] ?? 'Non précisé'}', style: const TextStyle(color: Colors.black87)),
                          
                          const SizedBox(height: 20),

                          if (status == 'en_attente' && widget.userRole == 'parent')
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => _updateStatus(appt['id'], 'accepte'),
                                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.forestGreen, foregroundColor: Colors.white),
                                    child: const Text('Accepter'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => _updateStatus(appt['id'], 'refuse'),
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF14668), foregroundColor: Colors.white),
                                    child: const Text('Refuser'),
                                  ),
                                ),
                              ],
                            ),

                          if (status == 'accepte' && isVideo && appt['lien_video'] != null)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _launchVideoCall(appt['lien_video']),
                                icon: const Icon(Icons.video_call),
                                label: const Text('Rejoindre l\'appel'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.seaBlue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor = Colors.white;
    String label;

    switch (status) {
      case 'accepte':
        bgColor = AppTheme.forestGreen;
        label = 'Accepté';
        break;
      case 'refuse':
        bgColor = const Color(0xFFF14668);
        label = 'Refusé';
        break;
      case 'reporte':
        bgColor = Colors.orange;
        label = 'Reporté';
        break;
      default:
        bgColor = Colors.grey[300]!;
        textColor = Colors.black87;
        label = 'En attente';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
