part of '../apercu/child_details_view.dart';

extension ActualitesViewExtension on _ChildDetailsViewState {
  Color _getNewsTypeColor(String? type) {
    switch (type?.toUpperCase()) {
      case 'MESSE':
        return Colors.purple;
      case 'EVENT':
      case 'EVENEMENT':
        return Colors.orange;
      case 'INFO':
      case 'INFORMATION':
        return Colors.blue;
      case 'URGENT':
        return Colors.red;
      default:
        return AppTheme.seaBlue;
    }
  }

  IconData _getNewsTypeIcon(String? type) {
    switch (type?.toUpperCase()) {
      case 'MESSE':
        return Icons.church;
      case 'EVENT':
      case 'EVENEMENT':
        return Icons.event;
      case 'INFO':
      case 'INFORMATION':
        return Icons.info;
      case 'URGENT':
        return Icons.warning;
      default:
        return Icons.notifications;
    }
  }

  String _formatNewsDate(dynamic date) {
    if (date == null) return '';
    try {
      final DateTime dt = DateTime.parse(date.toString());
      return DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(dt);
    } catch (e) {
      return date.toString();
    }
  }

  Widget _buildNewsTab() {
    final actualites = _dashboardData?['actualites'] as List<dynamic>? ?? [];
    
    // DEBUG: Afficher les actualités dans l'onglet Actualités
    print('[DEBUG ACTUALITES Tab] actualites count: ${actualites.length}');
    print('[DEBUG ACTUALITES Tab] actualites data: $actualites');
    
    if (actualites.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: const Center(
            child: Text(
              'Aucune actualité pour le moment.',
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ),
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actualités de l\'école',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ...actualites.map((actu) {
            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image avec badge type
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.network(
                          actu['image_url'] ?? 'https://i.pinimg.com/736x/51/b1/a7/51b1a798455b0af03492963412bf1689.jpg',
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 220,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 50, color: Colors.grey),
                          ),
                        ),
                      ),
                      // Badge type coloré
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: _getNewsTypeColor(actu['type']),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getNewsTypeIcon(actu['type']),
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                (actu['type'] ?? 'ANNONCE').toString().toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titre
                        Text(
                          actu['titre'] ?? 'Information',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.3),
                        ),
                        const SizedBox(height: 14),
                        // Description complète
                        Text(
                          actu['contenu'] ?? '',
                          style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.6),
                        ),
                        const SizedBox(height: 16),
                        // Détails : Date, Heure, Prêtre
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              if (actu['date'] != null) ...[
                                _buildDetailRow(Icons.calendar_today, 'Date', 
                                  DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(DateTime.parse(actu['date']))),
                                const SizedBox(height: 8),
                              ],
                              if (actu['heure'] != null) ...[
                                _buildDetailRow(Icons.access_time, 'Heure', actu['heure']),
                                const SizedBox(height: 8),
                              ],
                              if (actu['celebrant'] != null || actu['pretre'] != null) ...[
                                _buildDetailRow(Icons.person, 'Célébrant', 
                                  actu['celebrant'] ?? actu['pretre'] ?? 'Prêtre Gabonais'),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.seaBlue),
        const SizedBox(width: 10),
        Text(
          '$label : ',
          style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

}
