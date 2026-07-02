part of '../apercu/child_details_view.dart';

extension ProfesseursViewExtension on _ChildDetailsViewState {
  Widget _buildTeachersTab() {
    final List<dynamic> teachers = _dashboardData?['teachers'] ?? [];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ── BLOC ADMINISTRATION (toujours affiché en premier)
        _buildAdminCard(),
        const SizedBox(height: 20),

        // ── SECTION PROFESSEURS
        if (teachers.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Column(
                children: [
                  Icon(Icons.person_off_outlined, size: 48, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text('Aucun professeur trouvé',
                      style: TextStyle(color: Colors.grey[500], fontSize: 15)),
                ],
              ),
            ),
          )
        else ...[
          const Text(
            'ÉQUIPE ENSEIGNANTE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          ...teachers.map((teacher) => _buildTeacherCard(teacher)),
        ],
        const SizedBox(height: 40),
      ],
    );
  }

  // ─── CARTE ADMINISTRATION ──────────────────────────────────────────────────
  Widget _buildAdminCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.account_balance, color: Colors.green[700], size: 26),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Administration',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                    Text(
                      widget.child['school'] ?? 'l\'école',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showMessageAdminModal(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.withOpacity(0.1),
                foregroundColor: Colors.green[700],
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.green.withOpacity(0.25)),
                ),
              ),
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: const Text(
                'Message à l\'administration',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── CARTE PROFESSEUR ──────────────────────────────────────────────────────
  Widget _buildTeacherCard(Map<String, dynamic> teacher) {
    final String fullName = "${teacher['prenom'] ?? ''} ${teacher['nom'] ?? ''}".trim();
    final String subject = teacher['matiere'] ?? 'Matière Inconnue';
    final bool isPrincipal = teacher['is_principal'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPrincipal ? AppTheme.seaBlue.withOpacity(0.4) : Colors.grey[100]!,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: isPrincipal
                    ? AppTheme.seaBlue.withOpacity(0.18)
                    : AppTheme.seaBlue.withOpacity(0.10),
                child: Text(
                  fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: AppTheme.seaBlue,
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            fullName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
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
                                Text('Principal',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold)),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: const Text('Prendre RDV',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
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
                    backgroundColor: Colors.green.withOpacity(0.10),
                    foregroundColor: Colors.green.shade700,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.green.withOpacity(0.2)),
                    ),
                  ),
                  icon: const Icon(Icons.chat, size: 18),
                  label: const Text('Message',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── MODAL MESSAGE À L'ADMINISTRATION ─────────────────────────────────────
  void _showMessageAdminModal() {
    String selectedRaison = 'Absence maladie';
    final TextEditingController msgCtrl = TextEditingController();
    bool isSending = false;

    final List<Map<String, dynamic>> raisons = [
      {'label': 'Absence maladie', 'icon': '🤒'},
      {'label': 'Absence familiale', 'icon': '👨‍👩‍👧'},
      {'label': 'Retard prévu', 'icon': '⏰'},
      {'label': 'Question administrative', 'icon': '📋'},
      {'label': 'Autre', 'icon': '💬'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40, height: 4,
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
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.account_balance, color: Colors.green[700], size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Message à l\'Administration',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(
                          'Concerne : ${widget.child['prenom'] ?? widget.child['name']}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Raison
                const Text('Motif',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: raisons.map((r) {
                    final bool isSelected = selectedRaison == r['label'];
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedRaison = r['label']),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.green : Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? Colors.green : Colors.grey[200]!,
                          ),
                        ),
                        child: Text(
                          '${r['icon']} ${r['label']}',
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // Message
                const Text('Message',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                const SizedBox(height: 10),
                TextField(
                  controller: msgCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Décrivez la situation à l\'administration...',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF2596be)),
                    ),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),

                const SizedBox(height: 24),

                // Bouton envoyer
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isSending
                        ? null
                        : () async {
                            if (msgCtrl.text.trim().isEmpty) return;
                            setModalState(() => isSending = true);
                            try {
                              final childId = widget.child['id'];
                              await ApiClient.instance.post('/admin/messages/send', data: {
                                'eleve_id': childId,
                                'motif': selectedRaison,
                                'content': msgCtrl.text.trim(),
                                'type': 'parent_to_admin',
                              });
                              if (ctx.mounted) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(
                                    content: const Row(
                                      children: [
                                        Icon(Icons.check_circle, color: Colors.white),
                                        SizedBox(width: 10),
                                        Text('Message envoyé à l\'administration'),
                                      ],
                                    ),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              }
                            } catch (e) {
                              setModalState(() => isSending = false);
                              if (ctx.mounted) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(
                                    content: const Text('Erreur lors de l\'envoi'),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: isSending
                        ? const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.send_rounded),
                    label: Text(isSending ? 'Envoi...' : 'Envoyer le message',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
