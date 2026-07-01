part of '../apercu/child_details_view.dart';

extension HistoriqueViewExtension on _ChildDetailsViewState {
  Widget _buildHistoriqueTab() {
    if (_isLoadingIncidents) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_incidents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline_rounded,
                  size: 64,
                  color: Colors.green[400],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Aucun incident',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Aucun incident ou absence enregistré\npour cet élève.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchIncidents,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _incidents.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final incident = _incidents[index] as Map<String, dynamic>;
          return _buildIncidentCard(
            title: incident['type']?.toString() ?? 'Incident',
            subtitle: incident['motif']?.toString() ?? incident['description']?.toString() ?? 'Aucun détail',
            type: incident['type']?.toString() ?? '',
            color: _incidentColor(incident['type']?.toString() ?? ''),
            icon: _incidentIcon(incident['type']?.toString() ?? ''),
            date: incident['date']?.toString() ?? incident['created_at']?.toString() ?? '',
            isRead: incident['lu'] == true || incident['read'] == true,
          );
        },
      ),
    );
  }

  Color _incidentColor(String type) {
    final t = type.toLowerCase();
    if (t.contains('absent')) return Colors.red;
    if (t.contains('retard')) return Colors.orange;
    if (t.contains('disciplin') || t.contains('comportement')) return Colors.purple;
    if (t.contains('félicit') || t.contains('merit')) return Colors.green;
    return AppTheme.seaBlue;
  }

  IconData _incidentIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('absent')) return Icons.event_busy;
    if (t.contains('retard')) return Icons.watch_later_outlined;
    if (t.contains('disciplin') || t.contains('comportement')) return Icons.report_outlined;
    if (t.contains('félicit') || t.contains('merit')) return Icons.star_outline;
    return Icons.info_outline;
  }

  Widget _buildIncidentCard({
    required String title,
    required String subtitle,
    required String type,
    required Color color,
    required IconData icon,
    required String date,
    bool isRead = false,
  }) {
    // Formater la date
    String dateFormatted = '';
    if (date.isNotEmpty) {
      try {
        final dt = DateTime.parse(date);
        final months = ['jan', 'fév', 'mar', 'avr', 'mai', 'juin',
                        'juil', 'août', 'sep', 'oct', 'nov', 'déc'];
        dateFormatted = '${dt.day} ${months[dt.month - 1]} ${dt.year}';
      } catch (_) {
        dateFormatted = date.length >= 10 ? date.substring(0, 10) : date;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : color.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead ? Colors.grey.withOpacity(0.15) : color.withOpacity(0.2),
          width: isRead ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icône
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          // Contenu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: color,
                        ),
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                if (dateFormatted.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 13, color: Colors.grey[400]),
                      const SizedBox(width: 5),
                      Text(
                        dateFormatted,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
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
                    icon: const Icon(Icons.calendar_month, size: 15),
                    label: const Text(
                      'Demander un RDV',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: color,
                      side: BorderSide(color: color.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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
}
