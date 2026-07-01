part of 'child_details_view.dart';

extension OverviewModalsExtension on _ChildDetailsViewState {
  Widget _buildPriorityNotifications() {
    final rawNotifs = widget.child['notifications'];
    final notifs = rawNotifs is List 
        ? rawNotifs.map((e) => e as Map<String, dynamic>).toList()
        : null;

    if (notifs == null || notifs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dernières notifications',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        ...notifs
            .map(
              (n) => GestureDetector(
                onTap: () {
                  if (n['tabIndex'] != null) {
                    _tabController.animateTo(n['tabIndex']);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                      ),
                    ],
                    border: Border.all(color: Colors.grey[50]!),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (n['color'] as Color).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          n['icon'] as IconData,
                          color: n['color'] as Color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              n['title'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Cliquez pour voir les détails',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 11,
                              ),
                            ),
                            if (n['type'] == 'BULLETIN' &&
                                n['bulletinImage'] != null) ...[
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 36,
                                child: ElevatedButton.icon(
                                  onPressed: () => _showBulletinModal(
                                    n['bulletinImage'] as String,
                                  ),
                                  icon: const Icon(
                                    Icons.remove_red_eye,
                                    size: 14,
                                  ),
                                  label: const Text(
                                    'VOIR LE BULLETIN',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.seaBlue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ],
    );
  }

  void _showBulletinModal(String imagePath) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 15),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'BULLETIN TRIMESTRE 3',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: InteractiveViewer(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Center(child: Text('Image bulletin introuvable')),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download),
                  label: const Text('TÉLÉCHARGER LE PDF'),
                  style: AppTheme.primaryButtonStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentAlertNotification() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (widget.child['isLowGrade'] == true)
                  ? AppTheme.sunYellow.withOpacity(0.1)
                  : Colors.purple[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              (widget.child['isLowGrade'] == true)
                  ? Icons.warning_amber_rounded
                  : Icons.campaign,
              color: (widget.child['isLowGrade'] == true)
                  ? AppTheme.sunYellow
                  : Colors.purple[400],
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nouvelle note publiée : Devoir de Science',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.sunYellow.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.child['school'] ?? 'École',
                    style: const TextStyle(
                      color: AppTheme.sunYellow,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'M. Okoro vient de mettre à jour le cahier de texte numérique pour les Sciences.',
                  style: TextStyle(
                    color: Colors.blueGrey[600],
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: _showGradeModal,
                  child: const Text(
                    'Voir le résultat',
                    style: TextStyle(
                      color: AppTheme.seaBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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

  void _showGradeModal() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: (widget.child['isLowGrade'] == true)
                      ? AppTheme.sunYellow.withOpacity(0.1)
                      : Colors.purple[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  (widget.child['isLowGrade'] == true)
                      ? Icons.warning_amber_rounded
                      : Icons.verified,
                  color: (widget.child['isLowGrade'] == true)
                      ? AppTheme.sunYellow
                      : Colors.purple[400],
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Résultat du Devoir',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                widget.child['scienceGrade'] ?? '14/20',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: (widget.child['isLowGrade'] == true)
                      ? AppTheme.sunYellow
                      : AppTheme.seaBlue,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.child['quizDetails'] ??
                    'Note interrogation en physique chimie',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: AppTheme.primaryButtonStyle,
                  child: const Text(
                    'Fermer',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAbsenceModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Signaler une absence',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Pour : ${widget.child['name']}',
              style: TextStyle(color: AppTheme.textGrey),
            ),
            const SizedBox(height: 20),
            _buildMotiveTile('Maladie / Santé', Icons.sick_outlined),
            _buildMotiveTile('Raison Familiale', Icons.family_restroom),
            _buildMotiveTile('Autre motif', Icons.info_outline),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notification envoyée à l\'école'),
                      backgroundColor: AppTheme.forestGreen,
                    ),
                  );
                },
                style: AppTheme.primaryButtonStyle,
                child: const Text('Envoyer le justificatif'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotiveTile(String label, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.seaBlue),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right, size: 16),
      onTap: () {},
    );
  }









  // Helper methods for news display



  















}
