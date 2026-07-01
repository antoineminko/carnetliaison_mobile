part of '../apercu/child_details_view.dart';

extension ProfesseursViewExtension on _ChildDetailsViewState {
  Widget _buildTeachersTab() {
    final List<dynamic> teachers = _dashboardData?['teachers'] ?? [];

    if (teachers.isEmpty) {
      return const Center(
        child: Text(
          'Aucun professeur trouvé pour cette classe.',
          style: TextStyle(color: Colors.grey, fontSize: 15),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: teachers.length,
      itemBuilder: (context, index) {
        final teacher = teachers[index];
        final String fullName = "${teacher['prenom'] ?? ''} ${teacher['nom'] ?? ''}".trim();
        final String subject = teacher['matiere'] ?? 'Matière Inconnue';
        final bool isPrincipal = teacher['is_principal'] == true;
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isPrincipal ? AppTheme.seaBlue.withOpacity(0.5) : Colors.grey[100]!),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
            ],
          ),
          child: Column(
            children: [
              // Info row avec avatar et nom
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: isPrincipal ? AppTheme.seaBlue.withOpacity(0.2) : AppTheme.seaBlue.withOpacity(0.12),
                    child: Text(
                      fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: isPrincipal ? AppTheme.seaBlue : AppTheme.seaBlue.withOpacity(0.8),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nom complet avec badge Principal
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                fullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isPrincipal) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.seaBlue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star, color: Colors.white, size: 12),
                                    SizedBox(width: 4),
                                    Text(
                                      'Principal',
                                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subject,
                          style: TextStyle(
                            color: AppTheme.textGrey,
                            fontSize: 14,
                            fontWeight: isPrincipal ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AppointmentPage(
                              source: AppointmentSource.parent,
                              targetName: fullName.isNotEmpty && fullName != ' ' ? fullName : 'Professeur',
                              studentName: widget.child['prenom'] ?? widget.child['name'],
                              enseignantId: int.tryParse(teacher['id']?.toString() ?? ''),
                              eleveId: int.tryParse(widget.child['id']?.toString() ?? ''),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2596be),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: const Text(
                        'Prendre RDV',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(conversation: {
                              'enseignant_id': teacher['id'],
                              'enseignant_nom': teacher['nom'],
                              'enseignant_prenom': teacher['prenom'],
                              'subject': subject,
                            }),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.withOpacity(0.1),
                        foregroundColor: Colors.green.shade700,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.chat, size: 18),
                      label: const Text(
                        'Discuter',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

}
