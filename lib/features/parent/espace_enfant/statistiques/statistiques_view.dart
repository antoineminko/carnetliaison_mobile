part of '../apercu/child_details_view.dart';

extension StatistiquesViewExtension on _ChildDetailsViewState {
  Widget _buildStatsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildStatHeader(),
        const SizedBox(height: 25),
        const Text(
          'COMPARAISON TRIMESTRIELLE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 15),
        _buildTermComparison(),
        const SizedBox(height: 30),
        const Text(
          'POINTS D\'ATTENTION',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 15),
        _buildVulnerabilityCard(),
        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildStatHeader() {
    String average = 'N/A';
    String absences = 'N/A';
    String conduite = 'N/A';

    // Extraction dynamique des statistiques si disponibles
    if (_dashboardData != null) {
      if (_dashboardData!['attendance'] != null) {
        final statut = _dashboardData!['attendance']['statut'];
        absences = (statut == 'Absente' || statut == 'Absent') ? '1j' : '0j';
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2596be), Color(0xFF1a7a9e)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2596be).withOpacity(0.35),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Moyenne — 2ᵉ Trimestre',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$average / 20',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'T2 EN COURS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(color: Colors.white24),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStat('Total Absences', absences),
              _buildMiniStat('Note Conduite', conduite),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildEvolutionGraph() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBar(0.4, 'Oct'),
                _buildBar(0.6, 'Nov'),
                _buildBar(0.5, 'Déc'),
                _buildBar(0.7, 'Jan'),
                _buildBar(0.85, 'Fév', isSelected: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(
    double heightFactor,
    String label, {
    bool isSelected = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 30,
          height: 120 * heightFactor,
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.seaBlue
                : AppTheme.seaBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.seaBlue : Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTermComparison() {
    final String childName = widget.child['name'].split(' ')[0];

    Widget termBadge(
      String label,
      String avg,
      String rang, {
      bool isPending = false,
    }) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isPending ? Colors.grey[100] : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isPending
                  ? Colors.grey[300]!
                  : const Color(0xFF2596be).withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isPending ? Colors.grey : const Color(0xFF2596be),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isPending ? 'En cours...' : '$avg/20',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: isPending ? Colors.grey : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isPending ? '' : 'Rang $rang',
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        termBadge('1er Trimestre', 'N/A', '-'),
        const SizedBox(width: 10),
        termBadge('2ᵉ Trimestre', 'N/A', '-'),
        const SizedBox(width: 10),
        termBadge('3ᵉ Trimestre', '', '', isPending: true),
      ],
    );
  }

  Widget _buildCauseRow(
    IconData icon,
    String subject,
    String progression,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Text(
          subject,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(width: 8),
        Text(
          progression,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildVulnerabilityCard() {
    String title = 'Point de vigilance';
    String message = 'Maintenez les efforts pour ce trimestre.';
    Color color = Colors.blue;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: color, size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(color: Colors.black87, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
