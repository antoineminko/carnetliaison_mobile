part of '../apercu/child_details_view.dart';

extension InformationsViewExtension on _ChildDetailsViewState {
  Widget _buildInfosTab() {
    final finances = _dashboardData?['finances'];
    final allInfos = _dashboardData?['adminInfos'] as List<dynamic>? ?? [];
    
    // DEBUG: Afficher les données finances reçues
    print('[DEBUG INFOS Tab] finances data: $finances');
    print('[DEBUG INFOS Tab] finances type: ${finances?.runtimeType}');
    print('[DEBUG INFOS Tab] solde_restant: ${finances?['solde_restant']}');
    print('[DEBUG INFOS Tab] _dashboardData keys: ${_dashboardData?.keys.toList()}');

    final financialInfos = allInfos.where((info) => info['type'] == 'finance' || info['montant'] != null).toList();
    final adminInfos = allInfos.where((info) => info['type'] != 'finance' && info['montant'] == null).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section INCIDENTS SIGNALÉS
          if (_incidents.isNotEmpty) ...[
            const Text(
              'INCIDENTS SIGNALÉS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.red,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 15),
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
                  boxShadow: isHighlighted ? [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ] : null,
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
                          child: Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red[700],
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                incident['type_label'] ?? 'Incident',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.red[800],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Signalé par ${incident['enseignant_nom']} - ${incident['matiere'] ?? 'Matière non spécifiée'}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isRead)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Nouveau',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (incident['description'] != null && incident['description'].toString().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        incident['description'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[800],
                          height: 1.4,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Le ${incident['date']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
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
            const SizedBox(height: 30),
          ],
          // Afficher la section finances uniquement si solde_restant existe et est > 0
          // Gérer le cas où solde_restant est une String ou un int
          Builder(
            builder: (context) {
              final soldeRaw = finances?['solde_restant'];
              
              // DEBUG: Afficher le solde reçu
              print('[DEBUG FINANCES Builder] soldeRaw: $soldeRaw');
              print('[DEBUG FINANCES Builder] soldeRaw type: ${soldeRaw?.runtimeType}');
              
              final solde = soldeRaw is int 
                  ? soldeRaw 
                  : (soldeRaw is String ? int.tryParse(soldeRaw) : null);
              
              print('[DEBUG FINANCES Builder] solde parsed: $solde');
              
              if (solde == null || solde <= 0) {
                print('[DEBUG FINANCES Builder] Section cachée car solde = $solde');
                return const SizedBox.shrink(); // Ne rien afficher si solde = 0 ou null
              }
              print('[DEBUG FINANCES Builder] Section affichée avec solde = $solde');
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SITUATION FINANCIÈRE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.seaBlue, Color(0xFF1565C0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: AppTheme.seaBlue.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Reste à payer', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 5),
                        Text(
                          '$solde FCFA',
                          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                        ),
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
                                  finances['prochain_paiement'] != null ? DateFormat('dd MMM yyyy').format(DateTime.parse(finances['prochain_paiement'])) : 'N/A',
                                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () => _showPaymentModal(solde),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppTheme.seaBlue,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              child: const Text('PAYER', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
            
          if (financialInfos.isNotEmpty) ...[
            const SizedBox(height: 15),
            ...financialInfos.map((info) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red[100]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red[700]),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(info['titre'] ?? 'Règlement de frais de scolarité', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red[800])),
                          const SizedBox(height: 4),
                          Text(info['contenu'] ?? '', style: TextStyle(color: Colors.red[900], fontSize: 13, height: 1.4)),
                          if (info['montant'] != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Payé', style: TextStyle(fontSize: 12, color: Colors.green[700], fontWeight: FontWeight.bold)),
                                    Text('${info['montant_paye'] ?? 0} FCFA', style: TextStyle(fontSize: 14, color: Colors.green[800], fontWeight: FontWeight.w900)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('Reste', style: TextStyle(fontSize: 12, color: Colors.red[700], fontWeight: FontWeight.bold)),
                                    Text('${info['montant_restant'] ?? info['montant']} FCFA', style: TextStyle(fontSize: 14, color: Colors.red[800], fontWeight: FontWeight.w900)),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 8),
                            Stack(
                              children: [
                                Container(
                                  height: 8,
                                  width: double.infinity,
                                  decoration: BoxDecoration(color: Colors.red[200], borderRadius: BorderRadius.circular(4)),
                                ),
                                FractionallySizedBox(
                                  widthFactor: (double.tryParse(info['montant']?.toString() ?? '1') ?? 1) > 0 
                                    ? ((double.tryParse(info['montant_paye']?.toString() ?? '0') ?? 0) / (double.tryParse(info['montant']?.toString() ?? '1') ?? 1)).clamp(0.0, 1.0) 
                                    : 0,
                                  child: Container(
                                    height: 8,
                                    decoration: BoxDecoration(color: Colors.green[600], borderRadius: BorderRadius.circular(4)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Center(child: Text('Total : ${info['montant']} FCFA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red[900], fontSize: 12))),
                          ]
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],

          const SizedBox(height: 30),
          const Text(
            'MESSAGES ADMINISTRATION',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 15),
          if (adminInfos.isEmpty)
            const Center(child: Text('Aucun message', style: TextStyle(color: Colors.grey)))
          else
            ...adminInfos.map((info) {
              bool isConvocation = info['type'] == 'convocation';
              Color bgColor = isConvocation ? Colors.orange[50]! : Colors.white;
              Color iconColor = isConvocation ? Colors.orange[700]! : Colors.blue[700]!;
              IconData icon = isConvocation ? Icons.calendar_month : Icons.info_outline;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                  border: Border.all(color: isConvocation ? Colors.orange[200]! : Colors.grey[100]!),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: isConvocation ? Colors.orange[100] : Colors.blue[50], shape: BoxShape.circle),
                      child: Icon(icon, color: iconColor),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(info['titre'] ?? 'Information', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text(info['contenu'] ?? '', style: TextStyle(color: Colors.grey[800], fontSize: 13, height: 1.4)),
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

  void _showPaymentModal(dynamic amount) {
    String phone = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Paiement Mobile Money', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Montant :  FCFA', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextField(
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Numéro de téléphone',
                hintText: 'Ex: 066xxxxxx',
                prefixIcon: const Icon(Icons.phone_android),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) => phone = val,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Demande de paiement envoyée sur votre téléphone.')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.seaBlue),
            child: const Text('Valider', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

}
