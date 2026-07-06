part of '../accueil/dashboard/parent_home_page.dart';

extension EvenementsViewExtension on _ParentHomePageState {
  Widget _buildEventsTab() {
    if (_isLoadingEvents) {
      return const Center(child: CircularProgressIndicator());
    }

    final filters = ['Tous', 'En attente', 'Accepté', 'À venir'];
    final now = DateTime.now();

    // Filtrer les événements
    List<Map<String, dynamic>> filteredAppointments = _appointments;

    if (_selectedEventFilter != 'Tous') {
      filteredAppointments = _appointments.where((rdv) {
        final status = rdv['statut'] ?? 'en_attente';
        final dateStr = rdv['date_heure']?.toString() ?? '';
        DateTime? date;
        if (dateStr.isNotEmpty) {
          try {
            if (dateStr.contains('/')) {
              final parts = dateStr.split(' ')[0].split('/');
              if (parts.length >= 3) {
                date = DateTime(
                  int.parse(parts[2]),
                  int.parse(parts[1]),
                  int.parse(parts[0]),
                );
              }
            } else {
              date = DateTime.parse(dateStr);
            }
          } catch (_) {}
        }

        switch (_selectedEventFilter) {
          case 'En attente':
            return status == 'en_attente';
          case 'Accepté':
            return status == 'accepted' || status == 'accepte';
          case 'À venir':
            if (date == null) return false;
            return date.isAfter(now.subtract(const Duration(days: 1))) &&
                status != 'rejected';
          default:
            return true;
        }
      }).toList();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Événements et Rendez-vous',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Chips de filtre
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: filters.map((filter) {
                final isSelected = _selectedEventFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      // ignore: invalid_use_of_protected_member
                      setState(() {
                        _selectedEventFilter = filter;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1377b5)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          if (filteredAppointments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Aucun événement pour ce filtre.",
                style: TextStyle(color: Colors.grey),
              ),
            ),

          if (filteredAppointments.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'DEMANDES DE RENDEZ-VOUS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 15),
            ...filteredAppointments.map((rdv) {
              final childName =
                  '${rdv['eleve_prenom'] ?? ''} ${rdv['eleve_nom'] ?? ''}'
                      .trim();
              return Padding(
                padding: const EdgeInsets.only(bottom: 15, left: 20, right: 20),
                child: _buildRdvCard(
                  teacherName:
                      '${rdv['enseignant_prenom'] ?? ''} ${rdv['enseignant_nom'] ?? ''}'
                          .trim(),
                  subject: rdv['enseignant_matiere'] ?? 'Enseignant',
                  meetingType: rdv['type'] ?? 'Rendez-vous',
                  childName: childName,
                  school: '', // Could be joined if available
                  motif: rdv['motif'] ?? 'Aucun motif',
                  date: rdv['date_heure'] ?? '',
                  color: _getChildColor(childName),
                  initials: (rdv['enseignant_nom'] ?? 'P')[0].toUpperCase(),
                  id: rdv['id'],
                  requester: rdv['requester'] ?? 'parent',
                  isPending: rdv['statut'] == 'en_attente',
                ),
              );
            }),
          ],

          // Les événements de l'établissement seront chargés dynamiquement ici plus tard
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildRdvCard({
    required String teacherName,
    required String subject,
    required String meetingType,
    required String childName,
    required String school,
    required String motif,
    required String date,
    required Color color,
    required String initials,
    int? id,
    String requester = 'parent',
    bool isPending = false,
  }) {
    bool showMotif = false;
    return StatefulBuilder(
      builder: (context, setCardState) {
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: color.withOpacity(0.12),
                    radius: 22,
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          teacherName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '$subject — $meetingType',
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Icône œil pour afficher motif
                  GestureDetector(
                    onTap: () => setCardState(() => showMotif = !showMotif),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        showMotif
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: color,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 13,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    childName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.school_outlined,
                    size: 13,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      school,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 13,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              // Motif visible si œil cliqué
              if (showMotif) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MOTIF',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        motif,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (isPending) ...[
                const SizedBox(height: 15),
                if (requester == 'enseignant')
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              _updateAppointmentStatus(id, 'refuse'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Refuser'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              _updateAppointmentStatus(id, 'accepte'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Accepter'),
                        ),
                      ),
                    ],
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.hourglass_empty,
                          color: Colors.orange,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'En attente d\'acceptation par l\'enseignant',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}
