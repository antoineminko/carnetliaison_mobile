part of '../apercu/child_details_view.dart';

extension InformationsViewExtension on _ChildDetailsViewState {
  Widget _buildInfosTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Sous-onglets internes
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[600],
              indicator: BoxDecoration(
                color: const Color(0xFF2596be),
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.warning_amber_rounded, size: 16),
                      SizedBox(width: 6),
                      Text('Signalements'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.info_outline, size: 16),
                      SizedBox(width: 6),
                      Text('Informations'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildSignalementsSubTab(),
                _buildInformationsSubTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── SOUS-ONGLET : SIGNALEMENTS ────────────────────────────────────────────
  Widget _buildSignalementsSubTab() {
    final allInfos = _dashboardData?['adminInfos'] as List<dynamic>? ?? [];
    final financialInfos = allInfos.where((info) => info['type'] == 'finance' || info['montant'] != null).toList();

    if (_isLoadingIncidents) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_incidents.isEmpty && financialInfos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle_outline, size: 40, color: Colors.green[400]),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucun signalement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              'Tout va bien, aucun incident n\'a\nété signalé cette période.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Incidents comportementaux
          if (_incidents.isNotEmpty) ...[
            _buildSectionLabel('INCIDENTS COMPORTEMENTAUX', Colors.red),
            const SizedBox(height: 12),
            ..._incidents.map((incident) {
              final bool isHighlighted = widget.highlightIncidentId != null &&
                  widget.highlightIncidentId == incident['id'].toString();
              final bool isRead = incident['is_read'] == true;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isHighlighted ? Colors.red[100] : (isRead ? Colors.grey[50] : Colors.red[50]),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isHighlighted ? Colors.red : Colors.red[200]!,
                    width: isHighlighted ? 2 : 1,
                  ),
                  boxShadow: isHighlighted
                      ? [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.warning_amber_rounded, color: Colors.red[700], size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                incident['type_label'] ?? 'Incident',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red[800]),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Signalé par ${incident['enseignant_nom']} — ${incident['matiere'] ?? 'N/A'}',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        if (!isRead)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                            child: const Text('Nouveau', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    if (incident['description'] != null && incident['description'].toString().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(incident['description'], style: TextStyle(fontSize: 13, color: Colors.grey[800], height: 1.4)),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Le ${incident['date']}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                        if (!isRead)
                          TextButton.icon(
                            onPressed: () => _markIncidentAsRead(incident['id'].toString()),
                            icon: const Icon(Icons.check_circle, size: 16),
                            label: const Text('Marquer comme lu'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],

          // ── Alertes financières
          if (financialInfos.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildSectionLabel('ALERTES FINANCIÈRES', Colors.orange),
            const SizedBox(height: 12),
            ...financialInfos.map((info) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.account_balance_wallet, color: Colors.orange[700]),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(info['titre'] ?? 'Alerte financière',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.orange[800])),
                          const SizedBox(height: 4),
                          Text(info['contenu'] ?? '', style: TextStyle(color: Colors.orange[900], fontSize: 13, height: 1.4)),
                          if (info['montant_restant'] != null) ...[
                            const SizedBox(height: 8),
                            Text('Reste à payer : ${info['montant_restant']} FCFA',
                                style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  // ─── SOUS-ONGLET : INFORMATIONS ─────────────────────────────────────────────
  Widget _buildInformationsSubTab() {
    final finances = _dashboardData?['finances'];
    final allInfos = _dashboardData?['adminInfos'] as List<dynamic>? ?? [];
    final adminInfos = allInfos.where((info) => info['type'] != 'finance' && info['montant'] == null).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Situation financière
          Builder(builder: (context) {
            final soldeRaw = finances?['solde_restant'];
            final solde = soldeRaw is int ? soldeRaw : (soldeRaw is String ? int.tryParse(soldeRaw) : null);
            if (solde == null || solde <= 0) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionLabel('SITUATION FINANCIÈRE', const Color(0xFF2596be)),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2596be), Color(0xFF1565C0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: const Color(0xFF2596be).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Reste à payer', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 5),
                      Text('$solde FCFA', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Prochain paiement', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              const SizedBox(height: 2),
                              Text(
                                finances['prochain_paiement'] != null
                                    ? DateFormat('dd MMM yyyy').format(DateTime.parse(finances['prochain_paiement']))
                                    : 'N/A',
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () => _showPaymentModal(solde),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF2596be),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('PAYER', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            );
          }),

          // ── Messages Administration
          _buildSectionLabel('MESSAGES DE L\'ADMINISTRATION', Colors.blueGrey),
          const SizedBox(height: 12),
          if (_isLoadingDashboard)
            const Center(child: CircularProgressIndicator())
          else if (adminInfos.isEmpty)
            _buildEmptyInfo(
              icon: Icons.mark_email_read_outlined,
              label: 'Aucun message de l\'administration',
            )
          else
            ...adminInfos.map((info) {
              bool isConvocation = info['type'] == 'convocation';
              Color bgColor = isConvocation ? Colors.orange[50]! : Colors.blue[50]!;
              Color iconColor = isConvocation ? Colors.orange[700]! : Colors.blue[700]!;
              IconData icon = isConvocation ? Icons.calendar_month : Icons.info_outline;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isConvocation ? Colors.orange[200]! : Colors.blue[100]!),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isConvocation ? Colors.orange[100] : Colors.blue[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: iconColor),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(info['titre'] ?? 'Information',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text(info['contenu'] ?? '',
                              style: TextStyle(color: Colors.grey[800], fontSize: 13, height: 1.4)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ─── HELPERS ────────────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: color,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildEmptyInfo({required IconData icon, required String label}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
        ],
      ),
    );
  }

  void _showPaymentModal(dynamic amount) {
    String phone = '';
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          title: const Text('Paiement Mobile Money', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Montant : $amount FCFA', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              TextField(
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Numéro de téléphone',
                  hintText: 'Ex: 066xxxxxx',
                  prefixIcon: const Icon(Icons.phone_android),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (val) => setModalState(() => phone = val),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: phone.isEmpty ? null : () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Demande de paiement envoyée au $phone.')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2596be)),
              child: const Text('Valider', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
