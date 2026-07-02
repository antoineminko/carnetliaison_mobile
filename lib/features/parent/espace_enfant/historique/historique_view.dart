part of '../apercu/child_details_view.dart';

// ─── DONNÉES SIMULÉES — RÉCAPS HEBDOMADAIRES ─────────────────────────────────
class _WeekRecap {
  final String label;       // "Semaine du 23 au 27 juin 2026"
  final DateTime startDate;
  final DateTime endDate;
  final List<_RecapSection> sections;

  const _WeekRecap({
    required this.label,
    required this.startDate,
    required this.endDate,
    required this.sections,
  });
}

class _RecapSection {
  final IconData icon;
  final Color color;
  final String titre;
  final String resume;

  const _RecapSection({
    required this.icon,
    required this.color,
    required this.titre,
    required this.resume,
  });
}

// Génère des récaps de semaines passées dynamiquement
List<_WeekRecap> _generateWeekRecaps(String childName) {
  final now = DateTime.now();

  // Trouver le lundi de la semaine courante
  final currentMonday = now.subtract(Duration(days: now.weekday - 1));

  List<_WeekRecap> recaps = [];
  final months = ['jan.', 'fév.', 'mars', 'avr.', 'mai', 'juin',
                   'juil.', 'août', 'sep.', 'oct.', 'nov.', 'déc.'];

  // Générer 4 semaines passées
  for (int w = 1; w <= 4; w++) {
    final monday = currentMonday.subtract(Duration(days: 7 * w));
    final friday = monday.add(const Duration(days: 4));

    final label =
        'Semaine du ${monday.day} au ${friday.day} ${months[friday.month - 1]} ${friday.year}';

    List<_RecapSection> sections;

    switch (w) {
      case 1:
        sections = [
          _RecapSection(
            icon: Icons.check_circle_outline,
            color: Colors.green,
            titre: 'Présence',
            resume: '$childName a été présent(e) 4 jours sur 5. '
                'Une absence le ${monday.add(const Duration(days: 2)).day}/${monday.month} '
                'signalée par les parents (maladie).',
          ),
          _RecapSection(
            icon: Icons.book_outlined,
            color: Colors.blue,
            titre: 'Devoirs rendus',
            resume: '3 devoirs rendus cette semaine : Mathématiques (14/20), '
                'Physique (exercice en classe) et Français (rédaction). '
                'Aucun retard constaté.',
          ),
          _RecapSection(
            icon: Icons.star_outline,
            color: Colors.amber,
            titre: 'Notes & Évaluations',
            resume: 'Interrogation surprise en Philosophie : 12/20. '
                'Devoir maison de SVT rendu : 15/20. Bonne semaine au global.',
          ),
          _RecapSection(
            icon: Icons.people_outline,
            color: const Color(0xFF2596be),
            titre: 'Comportement',
            resume: 'Aucun incident signalé. '
                'Note de conduite hebdomadaire : 14/20 — comportement satisfaisant.',
          ),
        ];
      case 2:
        sections = [
          _RecapSection(
            icon: Icons.event_busy,
            color: Colors.red,
            titre: 'Présence',
            resume: '2 absences injustifiées : lundi et mardi. '
                'Le professeur principal a tenté de contacter les parents le mercredi.',
          ),
          _RecapSection(
            icon: Icons.book_outlined,
            color: Colors.blue,
            titre: 'Devoirs rendus',
            resume: '1 devoir non rendu (Mathématiques). '
                'Les devoirs de Français et d\'Histoire ont été soumis mais en retard.',
          ),
          _RecapSection(
            icon: Icons.trending_down,
            color: Colors.orange,
            titre: 'Notes & Évaluations',
            resume: 'Contrôle de Mathématiques : 7/20 — en dessous de la moyenne. '
                'Des difficultés observées sur les fonctions du second degré. '
                'Un soutien est recommandé.',
          ),
          _RecapSection(
            icon: Icons.warning_amber_outlined,
            color: Colors.orange,
            titre: 'Comportement',
            resume: '1 incident signalé le jeudi : bavardage répété en cours de Physique. '
                'Note de conduite hebdomadaire : 9/20.',
          ),
        ];
      case 3:
        sections = [
          _RecapSection(
            icon: Icons.check_circle_outline,
            color: Colors.green,
            titre: 'Présence',
            resume: 'Semaine complète : 5/5 jours présent(e). '
                'Aucune absence ni retard enregistré.',
          ),
          _RecapSection(
            icon: Icons.assignment_turned_in_outlined,
            color: Colors.blue,
            titre: 'Devoirs rendus',
            resume: 'Tous les devoirs rendus à temps. '
                'Devoir de SVT noté 16/20 — excellent résultat. '
                'Exercice d\'Anglais complété.',
          ),
          _RecapSection(
            icon: Icons.emoji_events_outlined,
            color: Colors.amber,
            titre: 'Notes & Évaluations',
            resume: 'Meilleure semaine du mois : Anglais 17/20, Maths 14/20, SVT 16/20. '
                'Félicitations du professeur principal notées.',
          ),
          _RecapSection(
            icon: Icons.people_outline,
            color: const Color(0xFF2596be),
            titre: 'Comportement',
            resume: 'Excellent comportement signalé par 3 professeurs. '
                'Note de conduite : 16/20 — semaine exemplaire.',
          ),
        ];
      default: // w == 4
        sections = [
          _RecapSection(
            icon: Icons.watch_later_outlined,
            color: Colors.orange,
            titre: 'Présence',
            resume: '4 jours présent(e). 1 retard de 25 min le lundi — '
                'raison indiquée : problème de transport.',
          ),
          _RecapSection(
            icon: Icons.book_outlined,
            color: Colors.blue,
            titre: 'Devoirs rendus',
            resume: '2 devoirs rendus, 1 en retard (Philosophie). '
                'Exercice de grammaire corrigé en classe avec 11/20.',
          ),
          _RecapSection(
            icon: Icons.bar_chart_outlined,
            color: Colors.purple,
            titre: 'Notes & Évaluations',
            resume: 'Semaine calme : Maths 13/20, Français 10/20. '
                'Pas d\'évaluation majeure cette semaine. '
                'Révision des examens du trimestre en cours.',
          ),
          _RecapSection(
            icon: Icons.people_outline,
            color: const Color(0xFF2596be),
            titre: 'Comportement',
            resume: 'Comportement correct. '
                'Note de conduite : 12/20. '
                'Attention signalée en cours de Physique-Chimie.',
          ),
        ];
    }
    recaps.add(_WeekRecap(
      label: label,
      startDate: monday,
      endDate: friday,
      sections: sections,
    ));
  }
  return recaps;
}

// ─── EXTENSION ───────────────────────────────────────────────────────────────
extension HistoriqueViewExtension on _ChildDetailsViewState {
  Widget _buildHistoriqueTab() {
    final String childName =
        (widget.child['prenom'] ?? widget.child['name']?.split(' ')?.first ?? 'L\'élève').toString();
    final List<_WeekRecap> recaps = _generateWeekRecaps(childName);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: [
        // ── Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2596be), Color(0xFF1a7a9e)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.history_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Récap hebdomadaire',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                      'Résumé des 4 dernières semaines de $childName',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── Liste des semaines
        ...recaps.asMap().entries.map((entry) {
          final int i = entry.key;
          final _WeekRecap recap = entry.value;
          return _buildWeekCard(recap, i == 0);
        }),
      ],
    );
  }

  Widget _buildWeekCard(_WeekRecap recap, bool isMostRecent) {
    return StatefulBuilder(
      builder: (context, setCardState) {
        bool isExpanded = isMostRecent; // La semaine la plus récente ouverte par défaut

        return StatefulBuilder(
          builder: (ctx, setExpandState) {
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isMostRecent
                      ? const Color(0xFF2596be).withOpacity(0.3)
                      : Colors.grey[100]!,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // ── En-tête cliquable
                  InkWell(
                    onTap: () => setExpandState(() => isExpanded = !isExpanded),
                    borderRadius: BorderRadius.circular(18),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isMostRecent
                                  ? const Color(0xFF2596be).withOpacity(0.12)
                                  : Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.calendar_view_week_rounded,
                              color: isMostRecent
                                  ? const Color(0xFF2596be)
                                  : Colors.grey[500],
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isMostRecent)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 4),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2596be),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text('Semaine passée',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                Text(
                                  recap.label,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isMostRecent
                                        ? Colors.black87
                                        : Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${recap.sections.length} sections • Appuyer pour voir',
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey[400]),
                                ),
                              ],
                            ),
                          ),
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Contenu déroulant
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 250),
                    crossFadeState: isExpanded
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        children: [
                          const Divider(height: 1),
                          const SizedBox(height: 14),
                          ...recap.sections.map((section) =>
                              _buildRecapSection(section)),
                        ],
                      ),
                    ),
                    secondChild: const SizedBox(width: double.infinity),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRecapSection(_RecapSection section) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: section.color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: section.color.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: section.color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(section.icon, color: section.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(section.titre,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: section.color,
                    )),
                const SizedBox(height: 4),
                Text(
                  section.resume,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
