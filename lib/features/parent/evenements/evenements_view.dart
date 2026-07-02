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
                   date = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
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
            return date.isAfter(now.subtract(const Duration(days: 1))) && status != 'rejected';
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
                      setState(() {
                        _selectedEventFilter = filter;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF1377b5) : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
              child: Text("Aucun événement pour ce filtre.", style: TextStyle(color: Colors.grey)),
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
              final childName = '${rdv['eleve_prenom'] ?? ''} ${rdv['eleve_nom'] ?? ''}'.trim();
              return Padding(
                padding: const EdgeInsets.only(bottom: 15, left: 20, right: 20),
                child: _buildRdvCard(
                  teacherName: '${rdv['enseignant_prenom'] ?? ''} ${rdv['enseignant_nom'] ?? ''}'.trim(),
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

  Widget _buildConversationRequestCard(Map<String, dynamic> req) {
    String teacherName = '${req['enseignant_prenom'] ?? ''} ${req['enseignant_nom'] ?? ''}'.trim();
    String subject = req['enseignant_matiere'] ?? req['subject'] ?? 'Messagerie';
    
    // Contexte de l'élève
    String eleveNom = req['eleve_nom'] ?? '';
    String elevePrenom = req['eleve_prenom'] ?? '';
    String childContext = elevePrenom.isNotEmpty ? 'Pour $elevePrenom $eleveNom' : '';
    
    String status = req['status'] ?? 'pending';
    String statusText = 'Nouvelle discussion';
    Color statusColor = Colors.orange;
    if (status == 'accepted') {
      statusText = 'Discussion acceptée';
      statusColor = Colors.green;
    } else if (status == 'rejected') {
      statusText = 'Discussion refusée';
      statusColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.05),
            blurRadius: 10,
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
                backgroundColor: statusColor,
                radius: 20,
                child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: statusColor),
                    ),
                    Text(
                      '$teacherName ($subject)',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    if (childContext.isNotEmpty)
                      Text(
                        childContext,
                        style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (req['ecole_nom'] != null)
            Text('École: ${req['ecole_nom']}', style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
          const SizedBox(height: 12),
          if (status == 'pending')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(conversation: req),
                    ),
                  ).then((_) => _fetchEvents());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: statusColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Ouvrir la discussion'),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  status == 'accepted' ? 'Vous avez accepté cette discussion' : 'Vous avez refusé cette discussion',
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                ),
              ),
            ),
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
    return StatefulBuilder(
      builder: (context, setCardState) {
        bool showMotif = false;
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
                          onPressed: () => _updateAppointmentStatus(id, 'refuse'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Refuser'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _updateAppointmentStatus(id, 'accepte'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                        Icon(Icons.hourglass_empty, color: Colors.orange, size: 16),
                        SizedBox(width: 8),
                        Text('En attente d\'acceptation par l\'enseignant', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
              ]
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventSmallCard({
    required String title,
    required String date,
    required String location,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 5),
                    Text(
                      date,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        location,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
