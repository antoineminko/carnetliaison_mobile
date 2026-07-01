part of '../apercu/child_details_view.dart';

extension DevoirsViewExtension on _ChildDetailsViewState {
  List<Map<String, dynamic>> _parseHomeworks() {
    final dynamic dashboardHomeworks = _dashboardData?['homeworks'];
    final dynamic childHomeworks = widget.child['homeworks'];

    List<dynamic>? source;
    if (dashboardHomeworks is List && dashboardHomeworks.isNotEmpty) {
      source = dashboardHomeworks;
    } else if (childHomeworks is List && childHomeworks.isNotEmpty) {
      source = childHomeworks;
    }

    if (source == null) return [];

    return source
        .whereType<Map>()
        .map((dynamic hw) {
          final map = Map<String, dynamic>.from(hw as Map);

          map['titre'] ??= map['topic'] ?? map['title'] ?? 'Devoir';
          map['matiere'] ??= map['subject'] ?? 'Matière';
          map['description'] ??= map['description_longue'] ?? map['details'];
          map['type'] = (map['type'] ?? map['category'] ?? 'maison').toString().toLowerCase();

          if (map['date_remise'] == null) {
            final rawDue = map['dueDate'] ?? map['deadline'];
            if (rawDue is String && rawDue.isNotEmpty) {
              map['date_remise'] = rawDue;
            } else {
              map['date_remise'] = DateTime.now().add(const Duration(days: 2)).toIso8601String();
            }
          }

          map['created_at'] ??= map['createdAt'] ?? map['date'] ?? DateTime.now().toIso8601String();
          map['is_targeted'] = map['is_targeted'] ?? map['ciblage'] ?? (map['ciblage_eleve_id'] != null) ?? false;

          return map;
        })
        .toList();
  }

  Widget _buildHomeworkSummary() {
    final homeworks = _parseHomeworks();
    if (homeworks.isEmpty) {
      return _buildEmptyHomeworkCard();
    }

    final nextHomework = homeworks.first;
    final type = nextHomework['type']?.toString() ?? 'maison';
    final title = nextHomework['titre']?.toString() ?? 'Devoir';
    final matiere = nextHomework['matiere']?.toString() ?? 'Matière';
    final dueDate = _formatHomeworkDate(nextHomework['date_remise']);
    final isTargeted = nextHomework['is_targeted'] == true;

    return GestureDetector(
      onTap: () => _tabController.animateTo(2),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getHomeworkTypeColor(type).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(_getHomeworkTypeIcon(type), color: _getHomeworkTypeColor(type)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getHomeworkTypeLabel(type),
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _getHomeworkTypeColor(type)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.class_, size: 16, color: AppTheme.textGrey),
                const SizedBox(width: 6),
                Text(matiere, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                const Spacer(),
                const Icon(Icons.calendar_today, size: 16, color: AppTheme.textGrey),
                const SizedBox(width: 6),
                Text(dueDate, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
            if (isTargeted) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.push_pin, size: 14, color: Colors.orange),
                    SizedBox(width: 6),
                    Text('Devoir ciblé pour votre enfant', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.orange)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Text('Voir les détails', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.seaBlue)),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.seaBlue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeworksList() {
    final homeworks = _parseHomeworks();

    if (homeworks.isEmpty) {
      return _buildEmptyHomeworkCard();
    }

    return Column(
      children: homeworks.map((hw) {
        final type = hw['type']?.toString() ?? 'maison';
        final matiere = hw['matiere']?.toString() ?? 'Matière';
        final title = hw['titre']?.toString() ?? 'Devoir';
        final description = hw['description']?.toString();
        final dueDate = _formatHomeworkDate(hw['date_remise']);
        final createdAt = _formatHomeworkDate(hw['created_at']);
        final isTargeted = hw['is_targeted'] == true;
        final hwId = hw['id']?.toString();
        final isHighlighted = widget.highlightHomeworkId != null && widget.highlightHomeworkId == hwId;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: ExpansionTile(
            backgroundColor: isHighlighted ? AppTheme.seaBlue.withOpacity(0.05) : Colors.white,
            collapsedBackgroundColor: isHighlighted ? AppTheme.seaBlue.withOpacity(0.05) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: isHighlighted ? BorderSide(color: AppTheme.seaBlue, width: 2) : BorderSide.none,
            ),
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: isHighlighted ? BorderSide(color: AppTheme.seaBlue, width: 2) : BorderSide.none,
            ),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getHomeworkTypeColor(type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_getHomeworkTypeIcon(type), color: _getHomeworkTypeColor(type)),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      matiere,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getHomeworkTypeColor(type).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getHomeworkTypeLabel(type).toUpperCase(),
                        style: TextStyle(
                          color: _getHomeworkTypeColor(type),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (hw['enseignant_nom'] != null && hw['enseignant_nom'].toString().trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2.0),
                          child: Icon(Icons.person, size: 12, color: AppTheme.textGrey),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            hw['enseignant_nom'].toString(),
                            style: const TextStyle(
                              color: AppTheme.textGrey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.blueGrey[700],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_month, size: 14, color: AppTheme.textGrey),
                          const SizedBox(width: 4),
                          Text('À rendre le $dueDate', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.schedule, size: 14, color: AppTheme.textGrey),
                          const SizedBox(width: 4),
                          Text('Publié $createdAt', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isTargeted)
                  Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Row(
                      children: const [
                        Icon(Icons.push_pin, size: 14, color: Colors.orange),
                        SizedBox(width: 4),
                        Text('Ciblé pour votre enfant', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.orange)),
                      ],
                    ),
                  ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    if (description != null && description.isNotEmpty) ...[
                      const Text(
                        'Consignes :',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyHomeworkCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text(
          'Aucun devoir prévu',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  String _formatHomeworkDate(dynamic date) {
    if (date == null) return '--/--/----';
    try {
      final dt = DateTime.parse(date.toString());
      return DateFormat('dd/MM/yyyy', 'fr_FR').format(dt);
    } catch (_) {
      return date.toString();
    }
  }

  String _getHomeworkTypeLabel(String type) {
    switch (type) {
      case 'classe':
        return 'Devoir de classe';
      case 'exercice':
        return 'Exercice maison';
      case 'maison':
      default:
        return 'Devoir de maison';
    }
  }

  Color _getHomeworkTypeColor(String type) {
    switch (type) {
      case 'classe':
        return Colors.green;
      case 'exercice':
        return Colors.orange;
      case 'maison':
      default:
        return Colors.blue;
    }
  }

  IconData _getHomeworkTypeIcon(String type) {
    switch (type) {
      case 'classe':
        return Icons.school;
      case 'exercice':
        return Icons.edit_note;
      case 'maison':
      default:
        return Icons.home_work;
    }
  }

  Widget _buildHomeworksTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tous les devoirs',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          _buildHomeworksList(),
        ],
      ),
    );
  }

}
