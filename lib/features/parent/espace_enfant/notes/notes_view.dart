part of '../apercu/child_details_view.dart';

extension NotesViewExtension on _ChildDetailsViewState {
  Widget _buildNotesTab() {
    final List<dynamic> grades = _dashboardData?['grades'] ?? [];

    if (grades.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            'Aucune note trouvée.',
            style: TextStyle(color: Colors.grey, fontSize: 15),
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
            'RELEVÉ DES NOTES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 15),
          ...grades.map((g) => _buildGradeItem(g)),
        ],
      ),
    );
  }

  Widget _buildGradeItem(Map<String, dynamic> g) {
    bool isBad = g['isBad'] == true;
    final String subject = g['matiere'] ?? g['subject'] ?? 'Inconnu';
    final String topic = g['titre'] ?? g['topic'] ?? 'Devoir';
    final String grade = g['note'] ?? g['grade'] ?? '0/20';
    final String teacher = g['teacher'] ?? '';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isBad ? Colors.red.withOpacity(0.1) : Colors.grey[100]!,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppTheme.seaBlue,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  topic,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (teacher.isNotEmpty)
                  Text(
                    'Prof: $teacher',
                    style: TextStyle(color: AppTheme.textGrey, fontSize: 11),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                grade,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isBad ? Colors.red : AppTheme.seaBlue,
                ),
              ),
              if (isBad && teacher.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppointmentPage(
                            source: AppointmentSource.parent,
                            targetName: teacher,
                            studentName: widget.child['prenom'] ?? widget.child['name'],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Prendre RDV',
                        style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

}
