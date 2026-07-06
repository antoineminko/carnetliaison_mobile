part of 'child_details_view.dart';

extension OverviewTabExtension on _ChildDetailsViewState {
  Widget _buildOverviewTab() {
    String rawStatus =
        widget.child['attendance_status']?.toString().toLowerCase() ?? '';
    String status;

    if (rawStatus == 'present') {
      status = 'Présent';
    } else if (rawStatus == 'absent') {
      status = 'Absent';
    } else if (rawStatus == 'late') {
      status = 'En retard';
    } else {
      status = 'En attente';
    }

    String arrivalTime = '--:--';
    String dateAffichee = '';
    String jour = '';

    final String? arrivalRaw =
        widget.child['arrival_time']?.toString() ??
        widget.child['arrivalTime']?.toString();

    if (arrivalRaw != null && arrivalRaw.isNotEmpty) {
      try {
        final dt = DateTime.parse(arrivalRaw);
        arrivalTime = DateFormat('HH:mm', 'fr_FR').format(dt);
        dateAffichee = DateFormat('d MMM yyyy', 'fr_FR').format(dt);
        jour = DateFormat('EEEE', 'fr_FR').format(dt);
        jour = '${jour[0].toUpperCase()}${jour.substring(1)}';
        print(
          '[DEBUG] Parsed OK: arrivalTime=$arrivalTime, dateAffichee=$dateAffichee',
        );
      } catch (e) {
        print('[DEBUG] Parse error: $e');
        // Fallback: extraire manuellement HH:mm et date
        if (arrivalRaw.length >= 16) {
          arrivalTime = arrivalRaw.substring(11, 16); // HH:mm
          final datePart = arrivalRaw.substring(0, 10); // YYYY-MM-DD
          try {
            final dt = DateTime.parse(datePart);
            dateAffichee = DateFormat('d MMM yyyy', 'fr_FR').format(dt);
            jour = DateFormat('EEEE', 'fr_FR').format(dt);
            jour = '${jour[0].toUpperCase()}${jour.substring(1)}';
            print('[DEBUG] Fallback OK: dateAffichee=$dateAffichee');
          } catch (_) {}
        }
      }
    } else {
      print('[DEBUG] arrivalRaw is null or empty');
    }

    Map<String, dynamic>? attendance;
    if (_dashboardData != null && _dashboardData!['attendance'] is Map) {
      attendance = Map<String, dynamic>.from(
        _dashboardData!['attendance'] as Map,
      );
    }

    String matiere = '';
    String enseignant = '';
    if (attendance != null) {
      final String? dashStatus = attendance['statut']?.toString();
      if (dashStatus != null && dashStatus.isNotEmpty) {
        status = dashStatus;
      }

      final dynamic heureRaw = attendance['heure_arrivee'];
      if (heureRaw != null && heureRaw.toString().isNotEmpty) {
        arrivalTime = heureRaw.toString();
      }

      final String? dateRaw = attendance['date']?.toString();
      if (dateRaw != null && dateRaw.isNotEmpty) {
        try {
          final date = DateTime.parse(dateRaw);
          dateAffichee = DateFormat('d MMMM yyyy', 'fr_FR').format(date);
          jour = DateFormat('EEEE', 'fr_FR').format(date);
          jour = '${jour[0].toUpperCase()}${jour.substring(1)}';
        } catch (_) {}
      }

      matiere = attendance['matiere']?.toString() ?? '';
      enseignant = attendance['enseignant_nom']?.toString() ?? '';
    }

    final bool isAbsent = status == 'Absente' || status == 'Absent';
    final bool isPresent = status == 'Présent';
    final bool isLate = status == 'En retard';
    final bool isWaiting = status == 'En attente';

    Color boxBgColor;
    Color boxBorderColor;
    Color accentColor;
    Color box2BgColor;
    Color box2BorderColor;
    Color box2AccentColor;

    if (isPresent) {
      boxBgColor = Colors.green.withOpacity(0.08);
      boxBorderColor = Colors.green.withOpacity(0.3);
      accentColor = Colors.green[700]!;
      box2BgColor = Colors.green.withOpacity(0.06);
      box2BorderColor = Colors.green.withOpacity(0.2);
      box2AccentColor = Colors.green[700]!;
    } else if (isAbsent) {
      boxBgColor = Colors.red.withOpacity(0.07);
      boxBorderColor = Colors.red.withOpacity(0.25);
      accentColor = Colors.red[700]!;
      box2BgColor = Colors.red.withOpacity(0.05);
      box2BorderColor = Colors.red.withOpacity(0.2);
      box2AccentColor = Colors.red[700]!;
    } else if (isLate) {
      boxBgColor = Colors.orange.withOpacity(0.08);
      boxBorderColor = Colors.orange.withOpacity(0.3);
      accentColor = Colors.orange[800]!;
      box2BgColor = Colors.orange.withOpacity(0.06);
      box2BorderColor = Colors.orange.withOpacity(0.2);
      box2AccentColor = Colors.orange[800]!;
    } else {
      // En attente
      boxBgColor = Colors.grey.withOpacity(0.08);
      boxBorderColor = Colors.grey.withOpacity(0.2);
      accentColor = Colors.grey[600]!;
      box2BgColor = Colors.grey.withOpacity(0.06);
      box2BorderColor = Colors.grey.withOpacity(0.15);
      box2AccentColor = Colors.grey[600]!;
    }

    // Icône statut
    IconData statusIcon;
    if (isPresent)
      statusIcon = Icons.check_circle;
    else if (isAbsent)
      statusIcon = Icons.cancel;
    else if (isLate)
      statusIcon = Icons.watch_later;
    else
      statusIcon = Icons.hourglass_empty_rounded;

    return RefreshIndicator(
      onRefresh: _fetchDashboard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPriorityNotifications(),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Présence du jour',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (isAbsent)
                  TextButton.icon(
                    onPressed: () => _showAbsenceModal(),
                    icon: const Icon(
                      Icons.edit_document,
                      size: 16,
                      color: AppTheme.sunYellow,
                    ),
                    label: const Text(
                      'Justifier',
                      style: TextStyle(
                        color: AppTheme.seaBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 15),
            // BOX 1: Statut + Arrivée
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: boxBgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: boxBorderColor),
              ),
              child: Row(
                children: [
                  // Icône et statut
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(statusIcon, color: accentColor, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Statut',
                              style: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Séparateur
                  Container(
                    width: 1,
                    height: 50,
                    color: accentColor.withOpacity(0.2),
                  ),
                  const SizedBox(width: 16),
                  // Heure et date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_filled,
                              color: isWaiting ? Colors.grey : accentColor,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Arrivée',
                              style: TextStyle(
                                color: isWaiting ? Colors.grey : accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (isAbsent || isWaiting) ? '--:--' : arrivalTime,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isWaiting ? Colors.grey[600] : accentColor,
                          ),
                        ),
                        if (dateAffichee.isNotEmpty)
                          Text(
                            dateAffichee,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            // BOX 2: Matière + Jour
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: box2BgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: box2BorderColor),
              ),
              child: Row(
                children: [
                  // Matière et prof
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Matière',
                          style: TextStyle(
                            fontSize: 13,
                            color: box2AccentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          matiere.isNotEmpty ? matiere : 'À venir',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isWaiting
                                ? Colors.grey[700]
                                : box2AccentColor,
                          ),
                        ),
                        if (enseignant.isNotEmpty)
                          Text(
                            enseignant,
                            style: TextStyle(
                              fontSize: 12,
                              color: box2AccentColor.withOpacity(0.7),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  // Séparateur
                  Container(
                    width: 1,
                    height: 50,
                    color: box2AccentColor.withOpacity(0.2),
                  ),
                  const SizedBox(width: 16),
                  // Jour
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jour',
                          style: TextStyle(
                            fontSize: 13,
                            color: box2AccentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          jour.isNotEmpty
                              ? jour
                              : DateFormat(
                                  'EEEE',
                                  'fr_FR',
                                ).format(DateTime.now()),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isWaiting
                                ? Colors.grey[700]
                                : box2AccentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => Container(
                      height: MediaQuery.of(context).size.height * 0.8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
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
                          const SizedBox(height: 20),
                          const Text(
                            'Emploi du Temps de la Semaine',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: InteractiveViewer(
                                child: Image.asset(
                                  'assets/emploie/emploie.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.picture_as_pdf,
                  color: Color(0xFF37474F),
                ), // Dark slate grey
                label: const Text(
                  'VOIR L\'EMPLOI DU TEMPS DE L\'ENFANT',
                  style: TextStyle(
                    color: Color(0xFF37474F),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFECEFF1), // Light grey/white
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Colors.blueGrey.withOpacity(0.1)),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Devoirs à venir',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: widget.onGoToCalendar,
                  child: const Text(
                    'Voir Calendrier',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.seaBlue,
                    ),
                  ),
                ),
              ],
            ),

            _buildHomeworkSummary(),

            const SizedBox(height: 30),
            // ACTUALITÉS RÉSUMÉ (Aperçu)
            Builder(
              builder: (context) {
                final actualites =
                    _dashboardData?['actualites'] as List<dynamic>? ?? [];

                // DEBUG: Afficher les actualités reçues
                print(
                  '[DEBUG ACTUALITES Aperçu] actualites count: ${actualites.length}',
                );
                print('[DEBUG ACTUALITES Aperçu] actualites data: $actualites');
                print(
                  '[DEBUG ACTUALITES Aperçu] _dashboardData keys: ${_dashboardData?.keys.toList()}',
                );

                if (actualites.isEmpty) {
                  print(
                    '[DEBUG ACTUALITES Aperçu] Aucune actualité à afficher',
                  );
                  return const SizedBox.shrink();
                }

                // Afficher seulement la première actualité en résumé
                final actu = actualites.first;

                // DEBUG: Afficher les détails de l'actualité
                print('[DEBUG ACTUALITES Aperçu] titre: ${actu['titre']}');
                print('[DEBUG ACTUALITES Aperçu] contenu: ${actu['contenu']}');
                print('[DEBUG ACTUALITES Aperçu] type: ${actu['type']}');
                print(
                  '[DEBUG ACTUALITES Aperçu] image_url: ${actu['image_url']}',
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Actualités',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () => _tabController.animateTo(
                            1,
                          ), // Aller à l'onglet Actualités
                          child: const Text(
                            'Voir tout',
                            style: TextStyle(
                              color: AppTheme.seaBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    GestureDetector(
                      onTap: () => _tabController.animateTo(1),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image avec overlay gradient
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                  child: Image.network(
                                    actu['image_url'] ??
                                        'https://i.pinimg.com/736x/51/b1/a7/51b1a798455b0af03492963412bf1689.jpg',
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              height: 180,
                                              color: Colors.grey[300],
                                              child: const Icon(
                                                Icons.image,
                                                color: Colors.grey,
                                                size: 50,
                                              ),
                                            ),
                                  ),
                                ),
                                // Badge type en haut à gauche
                                Positioned(
                                  top: 12,
                                  left: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getNewsTypeColor(actu['type']),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _getNewsTypeIcon(actu['type']),
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          (actu['type'] ?? 'ANNONCE')
                                              .toString()
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
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
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10),
                                  // Description
                                  Text(
                                    actu['contenu'] ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      height: 1.4,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 12),
                                  // Date et heure si présentes
                                  if (actu['date'] != null ||
                                      actu['heure'] != null)
                                    Row(
                                      children: [
                                        if (actu['date'] != null) ...[
                                          Icon(
                                            Icons.calendar_today,
                                            size: 14,
                                            color: Colors.grey[500],
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            _formatNewsDate(actu['date']),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[500],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                        if (actu['heure'] != null) ...[
                                          const SizedBox(width: 16),
                                          Icon(
                                            Icons.access_time,
                                            size: 14,
                                            color: Colors.grey[500],
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            actu['heure'].toString(),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[500],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
