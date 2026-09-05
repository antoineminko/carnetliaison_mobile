import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_mobile/features/appointments/utils/appointment_utils.dart';

class AppointmentDetailsSheet extends StatelessWidget {
  final dynamic appt;
  final String userRole;
  final Widget actionButtons;

  const AppointmentDetailsSheet({
    super.key,
    required this.appt,
    required this.userRole,
    required this.actionButtons,
  });

  @override
  Widget build(BuildContext context) {
    final dateHeure = AppointmentUtils.safeParseDate(appt['date_heure']);
    final status = appt['statut'];
    final mode = appt['mode'] ?? 'presentiel';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
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
            
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppointmentUtils.getModeColor(mode).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    AppointmentUtils.getModeIcon(mode),
                    color: AppointmentUtils.getModeColor(mode),
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
                      AppointmentUtils.buildStatusBadge(status),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Détails
            if (dateHeure != null)
              _buildDetailSection('Date & Heure', [
                _buildDetailRow(
                  Icons.calendar_today,
                  DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(dateHeure),
                ),
                _buildDetailRow(
                  Icons.access_time,
                  DateFormat('HH:mm', 'fr_FR').format(dateHeure),
                ),
              ])
            else 
               _buildDetailSection('Date & Heure', [
                _buildDetailRow(Icons.calendar_today, 'Date invalide ou non fournie'),
              ]),

            _buildDetailSection('Participants', [
              if (userRole == 'parent')
                _buildDetailRow(
                  Icons.person_outline,
                  'Enseignant: ${appt['enseignant']?['prenom'] ?? ''} ${appt['enseignant']?['nom'] ?? ''}',
                ),
              if (userRole == 'enseignant')
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
            actionButtons,
          ],
        ),
      ),
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
}
