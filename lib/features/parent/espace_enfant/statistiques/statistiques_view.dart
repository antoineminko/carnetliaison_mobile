part of '../apercu/child_details_view.dart';

// ─── DONNÉES SIMULÉES RÉELLES ────────────────────────────────────────────────
class _TrimestreData {
  final String label;
  final double moyenne;
  final double totalAbsencesH;
  final double noteCoduite;
  final int rang;
  final int totalEleves;
  final bool enCours;
  final List<_MatiereNote> matieres;
  final String commentaire;

  const _TrimestreData({
    required this.label,
    required this.moyenne,
    required this.totalAbsencesH,
    required this.noteCoduite,
    required this.rang,
    required this.totalEleves,
    required this.enCours,
    required this.matieres,
    required this.commentaire,
  });
}

class _MatiereNote {
  final String matiere;
  final double t1;
  final double t2;

  const _MatiereNote({
    required this.matiere,
    required this.t1,
    required this.t2,
  });
}

// Données simulées de Yannick Nguema — Terminale C
const List<_MatiereNote> _matieres = [
  _MatiereNote(matiere: 'Mathématiques', t1: 14.0, t2: 8.0),
  _MatiereNote(matiere: 'Physique-Chimie', t1: 15.5, t2: 11.0),
  _MatiereNote(matiere: 'Français', t1: 12.0, t2: 10.5),
  _MatiereNote(matiere: 'Philosophie', t1: 13.0, t2: 9.0),
  _MatiereNote(matiere: 'Anglais', t1: 16.0, t2: 13.5),
  _MatiereNote(matiere: 'Sciences de la Vie', t1: 14.5, t2: 8.5),
  _MatiereNote(matiere: 'Histoire-Géographie', t1: 11.0, t2: 7.5),
  _MatiereNote(matiere: 'Éducation Physique', t1: 15.0, t2: 14.0),
];

const List<_TrimestreData> _trimestres = [
  _TrimestreData(
    label: '1er Trimestre',
    moyenne: 13.50,
    totalAbsencesH: 10.0,
    noteCoduite: 12.0,
    rang: 3,
    totalEleves: 45,
    enCours: false,
    matieres: _matieres,
    commentaire:
        'Yannick affiche des résultats satisfaisants pour ce premier trimestre. '
        'Son point fort reste l\'Anglais (16/20) et la Physique (15,5/20). '
        'Il doit cependant renforcer ses efforts en Histoire-Géographie (11/20). '
        'Son rang 3e/45 est encourageant, nous espérons le voir progresser.',
  ),
  _TrimestreData(
    label: '2e Trimestre',
    moyenne: 9.00,
    totalAbsencesH: 22.5,
    noteCoduite: 9.0,
    rang: 18,
    totalEleves: 45,
    enCours: false,
    matieres: _matieres,
    commentaire:
        'Une baisse significative est observée ce trimestre. La moyenne chute de 13,5 à 9/20, '
        'soit -4,5 points. Les absences ont presque doublé (22h vs 10h au T1), ce qui impacte '
        'directement les résultats. Les Mathématiques passent de 14 à 8/20 (-6 pts) et les '
        'Sciences de la Vie de 14,5 à 8,5 (-6 pts). Une attention particulière est requise.',
  ),
  _TrimestreData(
    label: '3e Trimestre',
    moyenne: 0,
    totalAbsencesH: 0,
    noteCoduite: 0,
    rang: 0,
    totalEleves: 45,
    enCours: true,
    matieres: _matieres,
    commentaire: '',
  ),
];

// ─── EXTENSION PRINCIPALE ────────────────────────────────────────────────────
extension StatistiquesViewExtension on _ChildDetailsViewState {
  Widget _buildStatsTab() {
    return StatefulBuilder(
      builder: (context, setLocalState) {
        int selectedTrimestre = 0;

        return StatefulBuilder(
          builder: (ctx, setTabState) {
            final t = _trimestres[selectedTrimestre];

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              children: [
                // ── SÉLECTEUR TRIMESTRES ──────────────────────────────────
                Row(
                  children: List.generate(_trimestres.length, (i) {
                    final tri = _trimestres[i];
                    final isSelected = i == selectedTrimestre;
                    Color bgColor;
                    Color textColor;

                    if (tri.enCours) {
                      bgColor = isSelected ? Colors.grey[300]! : Colors.grey[100]!;
                      textColor = Colors.grey[600]!;
                    } else if (tri.moyenne >= 12) {
                      bgColor = isSelected ? Colors.green : Colors.green[50]!;
                      textColor = isSelected ? Colors.white : Colors.green[700]!;
                    } else {
                      bgColor = isSelected ? Colors.orange : Colors.orange[50]!;
                      textColor = isSelected ? Colors.white : Colors.orange[700]!;
                    }

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setTabState(() => selectedTrimestre = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: isSelected
                                ? [BoxShadow(color: bgColor.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))]
                                : [],
                          ),
                          child: Column(
                            children: [
                              Text(
                                tri.enCours ? 'En cours' : '${tri.moyenne.toStringAsFixed(2)}/20',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: tri.enCours ? 12 : 16,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                tri.label,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 10, color: textColor.withOpacity(0.8)),
                              ),
                              if (!tri.enCours) ...[
                                const SizedBox(height: 3),
                                Text(
                                  'Rang ${tri.rang}/${tri.totalEleves}',
                                  style: TextStyle(fontSize: 9, color: textColor.withOpacity(0.7), fontWeight: FontWeight.w600),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 24),

                // ── CONTENU DU TRIMESTRE SÉLECTIONNÉ ─────────────────────
                if (t.enCours)
                  _buildEnCours()
                else ...[
                  _buildTrimestreHeader(t),
                  const SizedBox(height: 20),
                  if (selectedTrimestre == 1) ...[
                    _buildComparaisonT1T2(),
                    const SizedBox(height: 20),
                  ],
                  _buildPointsAttention(t),
                  const SizedBox(height: 20),
                  _buildCommentaireAlgo(t),
                ],
              ],
            );
          },
        );
      },
    );
  }

  // ── Bannière "En cours"
  Widget _buildEnCours() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.hourglass_top_rounded, size: 50, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('3ᵉ Trimestre en cours',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700])),
          const SizedBox(height: 8),
          Text(
            'Les résultats seront disponibles à la\nfin du trimestre.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── Header du trimestre (moyenne, absences, conduite, rang)
  Widget _buildTrimestreHeader(_TrimestreData t) {
    final bool isBon = t.moyenne >= 12;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isBon
              ? [const Color(0xFF2E7D32), const Color(0xFF388E3C)]
              : [const Color(0xFFE65100), const Color(0xFFF57C00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isBon ? Colors.green : Colors.orange).withOpacity(0.35),
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
                  Text(t.label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(
                    '${t.moyenne.toStringAsFixed(2)} / 20',
                    style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text('Rang', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    Text(
                      '${t.rang}/${t.totalEleves}',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStatWhite('Total Absences', '${t.totalAbsencesH}h', Icons.event_busy),
              Container(width: 1, height: 40, color: Colors.white24),
              _buildMiniStatWhite('Note Conduite', '${t.noteCoduite}/20', Icons.star_rounded),
              Container(width: 1, height: 40, color: Colors.white24),
              _buildMiniStatWhite('Statut', t.moyenne >= 12 ? 'Admis ✓' : 'Danger ⚠', Icons.assessment),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatWhite(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  // ── Comparaison T1 → T2 (Moyennes de la matière)
  Widget _buildComparaisonT1T2() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('MOYENNES PAR MATIÈRE',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 1.2)),
          const SizedBox(height: 14),
          ..._matieres.map((m) {
            final diff = m.t2 - m.t1;
            final isUp = diff >= 0;
            final color = isUp ? Colors.green[600]! : Colors.red[600]!;
            final icon = isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(m.matiere,
                        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                  ),
                  Text('${m.t1.toStringAsFixed(1)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  Icon(Icons.arrow_forward, size: 14, color: Colors.grey[400]),
                  Text('${m.t2.toStringAsFixed(1)}',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 11, color: color),
                        Text(
                          '${diff.abs().toStringAsFixed(1)}',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
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

  // ── Points marquants
  Widget _buildPointsAttention(_TrimestreData t) {
    final List<Map<String, dynamic>> points = [];

    if (t.totalAbsencesH >= 15) {
      points.add({
        'icon': Icons.event_busy,
        'color': Colors.red,
        'titre': 'Absences excessives',
        'detail': '${t.totalAbsencesH}h d\'absences — cela impacte directement les résultats.',
      });
    }

    for (final m in _matieres) {
      final note = t.label.contains('1') ? m.t1 : m.t2;
      if (note < 8) {
        points.add({
          'icon': Icons.priority_high_rounded,
          'color': Colors.red,
          'titre': '${m.matiere} en danger',
          'detail': 'Moyenne de ${note.toStringAsFixed(1)}/20 — un soutien scolaire est recommandé.',
        });
      } else if (note < 10) {
        points.add({
          'icon': Icons.warning_amber_rounded,
          'color': Colors.orange,
          'titre': '${m.matiere} à surveiller',
          'detail': 'Moyenne de ${note.toStringAsFixed(1)}/20 — des efforts supplémentaires sont nécessaires.',
        });
      }
    }

    if (t.noteCoduite < 10) {
      points.add({
        'icon': Icons.sentiment_dissatisfied,
        'color': Colors.orange,
        'titre': 'Note de conduite insuffisante',
        'detail': '${t.noteCoduite}/20 — le comportement doit être amélioré.',
      });
    }

    if (points.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green[100]!),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600], size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Excellent',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[800])),
                  const SizedBox(height: 4),
                  Text('Aucun point de vigilance particulier. Continuez sur cette lancée.',
                      style: TextStyle(color: Colors.green[700], fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('POINTS MARQUANTS',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          ...points.map((p) {
            final Color c = p['color'] as Color;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: c.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(p['icon'] as IconData, color: c, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p['titre'] as String,
                            style: TextStyle(fontWeight: FontWeight.bold, color: c, fontSize: 13)),
                        const SizedBox(height: 3),
                        Text(p['detail'] as String,
                            style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.3)),
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

  // ── Commentaire algorithmique
  Widget _buildCommentaireAlgo(_TrimestreData t) {
    final bool isBon = t.moyenne >= 12;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isBon
              ? [Colors.green[50]!, Colors.green[100]!]
              : [Colors.orange[50]!, Colors.orange[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isBon ? Colors.green[200]! : Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: isBon ? Colors.green[700] : Colors.orange[700], size: 18),
              const SizedBox(width: 8),
              Text(
                'Analyse algorithmique',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isBon ? Colors.green[800] : Colors.orange[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            t.commentaire,
            style: TextStyle(
              fontSize: 13,
              color: isBon ? Colors.green[900] : Colors.orange[900],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

}
