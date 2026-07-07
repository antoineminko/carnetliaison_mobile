part of '../../accueil/accueil_page.dart';

extension EvenementsViewExtension on _TeacherHomePageState {
  Widget _buildPlanningTab() {
    final filters = ['Tous', 'En attente', 'Validé', 'Passé'];
    final now = DateTime.now();

    // Filtrer les événements (Rendez-vous et Conversations)
    List<dynamic> filteredAppointments = _appointments;
    List<dynamic> filteredConversations = _conversations;

    if (_selectedEventFilter != 'Tous') {
      filteredAppointments = _appointments.where((appt) {
        final status = appt['statut'] ?? 'en_attente';
        final dateStr = appt['date_heure']?.toString() ?? '';
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
          case 'Validé':
            return status == 'accepted' || status == 'accepte';
          case 'Passé':
            if (date == null) return false;
            return date.isBefore(now);
          default:
            return true;
        }
      }).toList();

      filteredConversations = _conversations.where((conv) {
        final status = conv['status'] ?? 'pending';
        switch (_selectedEventFilter) {
          case 'En attente':
            return status == 'pending';
          case 'Validé':
            return status == 'accepted' || status == 'accepte';
          case 'Passé':
            return false; // Les messages n'ont généralement pas de notion de "passé" avec date
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
              'Agenda & Réunions',
              style: TextStyle(
                fontSize: 24,
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1377b5) // Couleur cohérente avec le parent
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

          // Availability Toggle (Spécifique à l'enseignant)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.seaBlue.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_available, color: AppTheme.seaBlue),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Text(
                      'Ma disponibilité pour RDV',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Switch(
                    value: true,
                    onChanged: (v) {},
                    activeColor: AppTheme.seaBlue,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'RENDEZ-VOUS PARENTS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 15),

          if (filteredAppointments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Aucun rendez-vous prévu pour ce filtre.',
                style: TextStyle(color: Colors.grey),
              ),
            ),

          ...filteredAppointments.map((appt) {
            final parentName = '${appt['parent_prenom']} ${appt['parent_nom']}';
            final eleveName = appt['eleve_prenom'] != null
                ? '${appt['eleve_prenom']} ${appt['eleve_nom']}'
                : 'Élève';
            final date = appt['date_heure'] != null
                ? appt['date_heure']
                      .toString()
                      .substring(0, 16)
                      .replaceFirst('T', ' ')
                : '';
            final isPending = appt['statut'] == 'en_attente';
            final requester = appt['requester'] ?? 'parent';
            final motif = appt['motif'] ?? 'Aucun motif';
            final status = appt['statut'];

            return Padding(
              padding: const EdgeInsets.only(bottom: 15, left: 20, right: 20),
              child: _buildMeetingCard(
                title:
                    'RDV ${appt['type'] == 'video' ? 'Vidéo' : 'Présentiel'} : $parentName',
                time: '$date\nMotif : $motif',
                location: appt['type'] == 'video'
                    ? 'Visioconférence'
                    : 'À l\'école',
                participants: '$parentName (pour $eleveName)',
                color: isPending ? Colors.orange : Colors.deepPurple,
                icon: appt['type'] == 'video'
                    ? Icons.videocam
                    : Icons.location_on,
                showVisioButton: appt['type'] == 'video' && status == 'accepted',
                isPending: isPending,
                requester: requester,
                id: appt['id'],
                type: 'appointment',
                status: status,
              ),
            );
          }).toList(),

          const SizedBox(height: 25),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'DEMANDES DE MESSAGERIE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 15),

          if (filteredConversations.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Aucune demande en attente pour ce filtre.',
                style: TextStyle(color: Colors.grey),
              ),
            ),

          ...filteredConversations.map((conv) {
            final parentName = '${conv['parent_prenom']} ${conv['parent_nom']}';
            final status = conv['status'] ?? 'pending';
            final isPending = status == 'pending';

            String title = 'Nouvelle conversation: $parentName';
            Color color = Colors.blue;
            if (status == 'accepted' || status == 'accepte') {
              title = 'Discussion acceptée: $parentName';
              color = Colors.green;
            } else if (status == 'rejected' || status == 'refuse') {
              title = 'Discussion refusée: $parentName';
              color = Colors.red;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 15, left: 20, right: 20),
              child: _buildMeetingCard(
                title: title,
                time: 'Objet: ${conv['subject'] ?? 'Non spécifié'}',
                location: 'Messagerie',
                participants: parentName,
                color: color,
                icon: Icons.message,
                showVisioButton: false,
                isPending: isPending,
                status: status,
                id: conv['id'],
                type: 'conversation',
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMeetingCard({
    required String title,
    required String time,
    required String location,
    required String participants,
    required Color color,
    required IconData icon,
    bool showVisioButton = false,
    bool isPending = false,
    String requester = 'parent',
    int? id,
    String? type,
    String? status,
  }) {
    // Adapter le design sur celui du Parent
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
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
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.grey[600],
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
          const Divider(height: 1),
          const SizedBox(height: 15),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppTheme.textGrey,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  location,
                  style: const TextStyle(color: AppTheme.textGrey, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.group_outlined,
                size: 16,
                color: AppTheme.textGrey,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  participants,
                  style: const TextStyle(color: AppTheme.textGrey, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (showVisioButton) ...[
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.video_call),
                label: const Text(
                  'Rejoindre la visio',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
          if (isPending) ...[
            const SizedBox(height: 15),
            if (requester == 'parent' || requester == 'system')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          _updateRequestStatus(id, type, 'rejected'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Refuser'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          _updateRequestStatus(id, type, 'accepted'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
                    Icon(Icons.hourglass_empty, color: Colors.orange, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'En attente d\'acceptation',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ] else if (status == 'accepted' || status == 'accepte' || status == 'rejected' || status == 'refuse') ...[
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  (status == 'accepted' || status == 'accepte')
                      ? 'Vous avez accepté cette demande'
                      : 'Vous avez refusé cette demande',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
