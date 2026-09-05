import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/features/appointments/utils/appointment_utils.dart';

class AppointmentCard extends StatelessWidget {
  final dynamic appt;
  final String userRole;
  final bool isHighlighted;
  final VoidCallback onTap;
  final Widget actionButtons;

  const AppointmentCard({
    super.key,
    required this.appt,
    required this.userRole,
    required this.onTap,
    required this.actionButtons,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final dateHeure = AppointmentUtils.safeParseDate(appt['date_heure']);
    final status = appt['statut'];
    final mode = appt['mode'] ?? 'presentiel';

    // Nom de l'autre partie
    String otherPartyName = '';
    if (userRole == 'parent') {
      final ens = appt['enseignant'];
      if (ens != null) {
        otherPartyName = '${ens['prenom'] ?? ''} ${ens['nom'] ?? ''}'.trim();
      }
    } else {
      final parent = appt['parent'];
      if (parent != null) {
        otherPartyName = '${parent['prenom'] ?? ''} ${parent['nom'] ?? ''}'.trim();
      }
    }

    // Nom de l'élève
    String eleveName = '';
    final eleve = appt['eleve'];
    if (eleve != null) {
      eleveName = '${eleve['prenom'] ?? ''} ${eleve['nom'] ?? ''}'.trim();
    }

    String dateFormatted = 'Date invalide';
    String timeFormatted = '--:--';
    if (dateHeure != null) {
      dateFormatted = DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(dateHeure);
      timeFormatted = DateFormat('HH:mm', 'fr_FR').format(dateHeure);
    }

    // Nouvelle date proposée si reporté
    DateTime? newProposedDate;
    if (appt['new_proposed_date'] != null) {
      newProposedDate = AppointmentUtils.safeParseDate(appt['new_proposed_date']);
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
            onTap: onTap,
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
                          color: AppointmentUtils.getModeColor(mode).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          AppointmentUtils.getModeIcon(mode),
                          color: AppointmentUtils.getModeColor(mode),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppointmentUtils.getModeLabel(mode),
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
                      AppointmentUtils.buildStatusBadge(status),
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
                            DateFormat('EEEE d MMMM yyyy à HH:mm', 'fr_FR')
                                .format(newProposedDate),
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
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 15),
                  actionButtons,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
