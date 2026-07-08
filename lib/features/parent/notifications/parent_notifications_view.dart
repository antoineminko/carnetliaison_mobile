part of '../accueil/dashboard/parent_home_page.dart';

extension ParentNotificationsViewExtension on _ParentHomePageState {
  void _showNotificationsModal({
    String? filterChildName,
    Map<String, dynamic>? incidentPayload,
  }) async {
    print(
      'ðŸ“¥ [ParentHomePage] _showNotificationsModal - incidentPayload: $incidentPayload',
    );
    final List<Map<String, dynamic>> allNotifications = [];

    // Charger les notifications locales (push notifications)
    final localNotifications = await NotificationStorage.getNotifications();
    for (var n in localNotifications) {
      String childName = n['data']?['child_name'] ?? '';
      String schoolName = '';
      final eleveIdRaw = n['data']?['eleve_id'];
      if (eleveIdRaw != null && childName.isEmpty) {
        final childIndex = _childrenData.indexWhere((c) => c['id'].toString() == eleveIdRaw.toString());
        if (childIndex != -1) {
          childName = _childrenData[childIndex]['name'] ?? '';
          schoolName = _childrenData[childIndex]['school'] ?? '';
        }
      }

      String dataType = n['data']?['type']?.toString() ?? '';
      String displayTitle = n['title'] ?? 'Notification';
      String displaySender = n['data']?['enseignant_nom'] ?? '';

      if (dataType == 'admin_info') {
        if (displayTitle.toLowerCase().contains('financiÃ¨re') || displayTitle.toLowerCase().contains('finance')) {
          displayTitle = 'Nouvelle information financiÃ¨re';
          displaySender = "ComptabilitÃ© de l'Ã©cole";
        } else {
          displayTitle = "Nouvelle information de l'administration";
          displaySender = "Administration";
        }
      } else if (dataType == 'admin_message') {
        displayTitle = "Nouveau message de l'administration";
        displaySender = "Administration";
      }

      allNotifications.add({
        'title': displayTitle,
        'type': dataType == 'incident' ? 'INCIDENT' : (dataType == 'teacher_message' || dataType == 'admin_message' ? 'MESSAGE' : 'INFO'),
        'child': childName,
        'school': schoolName,
        'sender': displaySender,
        'time': n['timestamp'] != null
            ? DateTime.parse(
                n['timestamp'],
              ).toString().substring(0, 16).replaceFirst('T', ' ')
            : 'RÃ©cemment',
        'color': n['data']?['type'] == 'incident' ? Colors.red : Colors.blue,
        'icon': n['data']?['type'] == 'incident'
            ? Icons.warning
            : Icons.notifications,
        'message': n['body'] ?? n['message'] ?? '',
        'source': 'local',
        'data': n['data'],
        'isLocal': true,
      });
    }

    for (var rdv in _appointments) {
      if (rdv['statut'] == 'en_attente') {
        allNotifications.add({
          'title': 'Demande de rendez-vous',
          'type': 'RDV',
          'child': '${rdv['eleve_prenom'] ?? ''} ${rdv['eleve_nom'] ?? ''}'
              .trim(),
          'school': '',
          'sender':
              '${rdv['enseignant_prenom'] ?? ''} ${rdv['enseignant_nom'] ?? ''}'
                  .trim(),
          'time': rdv['date_rdv'] ?? 'Ã€ dÃ©finir',
          'color': AppTheme.seaBlue,
          'icon': Icons.calendar_today,
          'isAppointmentRequest': true,
          'message': rdv['motif'] ?? '',
        });
      }
    }

    // _conversationRequests retirÃ©s des notifications selon la demande de l'utilisateur

    for (var n in _apiNotifications) {

      // Extraire les mÃ©tadonnÃ©es de la notification (type fonctionnel, classe, etc.)
      Map<String, dynamic>? dataMap;
      final dynamic rawData = n['data'];
      if (rawData is Map<String, dynamic>) {
        dataMap = rawData;
      }

      final String dataType = dataMap?['type']?.toString() ?? '';

      // IcÃ´ne et couleur par dÃ©faut
      IconData icon = Icons.notifications;
      Color color = n['is_read'] == true ? Colors.grey : Colors.blue;

      // Extraire le nom de l'enfant si disponible
      String childName = '';
      String schoolName = '';
      if (dataMap != null && dataMap['eleve_nom'] != null) {
        childName = dataMap['eleve_nom'].toString();
      }
      final eleveIdRaw = dataMap?['eleve_id'];
      if (eleveIdRaw != null && childName.isEmpty) {
        final childIndex = _childrenData.indexWhere((c) => c['id'].toString() == eleveIdRaw.toString());
        if (childIndex != -1) {
          childName = _childrenData[childIndex]['name'] ?? '';
          schoolName = _childrenData[childIndex]['school'] ?? '';
        }
      }

      String displayTitle = n['title'] ?? 'Notification';
      String displaySender = dataMap?['matiere'] ?? '';

      if (dataType == 'admin_info') {
        if (displayTitle.toLowerCase().contains('financiÃ¨re') || displayTitle.toLowerCase().contains('finance')) {
          displayTitle = 'Nouvelle information financiÃ¨re';
          displaySender = "ComptabilitÃ© de l'Ã©cole";
        } else {
          displayTitle = "Nouvelle information de l'administration";
          displaySender = "Administration";
        }
      } else if (dataType == 'admin_message') {
        displayTitle = "Nouveau message de l'administration";
        displaySender = "Administration";
      }

      // Style spÃ©cifique pour un nouveau devoir
      if (dataType == 'new_homework') {
        icon = Icons.menu_book;
        color = n['is_read'] == true ? Colors.grey : Colors.deepPurple;
      }

      if (dataType == 'teacher_message' || dataType == 'admin_message') {
        icon = Icons.message;
        color = n['is_read'] == true ? Colors.grey : AppTheme.seaBlue;
      }

      allNotifications.add({
        'title': displayTitle,
        'type': (dataType == 'teacher_message' || dataType == 'admin_message') ? 'MESSAGE' : 'INFO',
        'child': childName,
        'school': schoolName,
        'sender': displaySender,
        'time': n['created_at'] != null
            ? n['created_at'].toString().substring(0, 10)
            : 'RÃ©cemment',
        'color': color,
        'icon': icon,
        'message': n['message'] ?? '',
        'id': n['id'],
        'data': dataMap ?? n['data'],
        'notificationId': n['id'],
        'source': 'api',
      });
    }

    // Filtrer si nÃ©cessaire (on compare avec le prÃ©nom pour la dÃ©mo)
    final filteredNotifications = filterChildName == null
        ? allNotifications
        : allNotifications
              .where(
                (n) => (n['child'] as String).contains(
                  filterChildName.split(' ')[0],
                ),
              )
              .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
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
              'NOTIFICATIONS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.seaBlue,
              ),
            ),
            // BanniÃ¨re d'incident si prÃ©sente dans le payload
            if (incidentPayload != null) ...[
              const SizedBox(height: 15),
              if (incidentPayload['type'] == 'incident') ...[
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    final childName = incidentPayload['child_name'];
                    if (childName != null) {
                      _selectChildByName(childName, 5); // Onglet Infos (index 5)
                      // ignore: invalid_use_of_protected_member
                      setState(() {
                        _pendingHighlightIncidentId =
                            incidentPayload['incident_id']?.toString();
                      });
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.red, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
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
                              child: const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.red,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Incident signalé',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    incidentPayload['body'] ?? 'Nouvel incident',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.red,
                              size: 16,
                            ),
                          ],
                        ),
                        if (incidentPayload['enseignant_nom'] != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Par ${incidentPayload['enseignant_nom']}${incidentPayload['matiere'] != null ? ' - ' + incidentPayload['matiere'] : ''}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ] else if (incidentPayload['type'] == 'new_homework') ...[
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    final childName = incidentPayload['child_name'];
                    if (childName != null) {
                      _selectChildByName(childName, 2); // Onglet Devoirs (index 2)
                      // ignore: invalid_use_of_protected_member
                      setState(() {
                        _pendingHighlightHomeworkId =
                            incidentPayload['devoir_id']?.toString();
                      });
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.seaBlue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.seaBlue, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.seaBlue.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.seaBlue.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.menu_book,
                                color: AppTheme.seaBlue,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    incidentPayload['type_devoir'] ?? 'Nouveau Devoir',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppTheme.seaBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    incidentPayload['body'] ?? 'Une nouvelle évaluation a été publiée',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: AppTheme.seaBlue,
                              size: 16,
                            ),
                          ],
                        ),
                        if (incidentPayload['enseignant_nom'] != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Par ${incidentPayload['enseignant_nom']}${incidentPayload['matiere'] != null ? ' - ' + incidentPayload['matiere'] : ''}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ],
            const SizedBox(height: 10),
            Expanded(
              child: filteredNotifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 60,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            filterChildName != null
                                ? 'Aucune notification pour $filterChildName'
                                : 'Aucune notification',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: filteredNotifications.length,
                      itemBuilder: (context, index) {
                        final n = filteredNotifications[index];
                        return GestureDetector(
                          onTap: () {
                            final data = n['data'];
                            final notificationId = n['notificationId'];

                            // Navigation pour les notifications locales (incidents)
                            if (n['source'] == 'local' &&
                                data is Map<String, dynamic>) {
                              if (data['type'] == 'incident') {
                                final childName = data['child_name'];
                                if (childName != null) {
                                  Navigator.pop(context);
                                  _selectChildByName(
                                    childName,
                                    5,
                                    0,
                                  ); // Onglet Infos, Sous-onglet Signalements
                                  // ignore: invalid_use_of_protected_member
                                  setState(() {
                                    _pendingHighlightIncidentId =
                                        data['incident_id']?.toString();
                                  });
                                  return;
                                }
                              }
                            }

                            if (n['source'] == 'api' &&
                                data is Map<String, dynamic>) {
                              if ((data['type'] == 'admin_info' ||
                                      data['type'] == 'new_homework') &&
                                  data['eleve_id'] != null) {
                                final eleveId = int.tryParse(
                                  data['eleve_id'].toString(),
                                );
                                if (eleveId != null) {
                                  final childIndex = _childrenData.indexWhere((
                                    c,
                                  ) {
                                    if (c['fromApi'] == true) {
                                      final raw =
                                          c['raw'] as Map<String, dynamic>?;
                                      final cid = c['id'];
                                      if (cid is int && cid == eleveId) {
                                        return true;
                                      }
                                      if (raw != null &&
                                          raw['id'] != null &&
                                          int.tryParse(raw['id'].toString()) ==
                                              eleveId) {
                                        return true;
                                      }
                                    }
                                    return false;
                                  });

                                  if (childIndex != -1) {
                                    Navigator.pop(context);
                                    // ignore: invalid_use_of_protected_member
                                    setState(() {
                                      _childInitialTab =
                                          data['type'] == 'new_homework'
                                          ? 2
                                          : 5; // 2 = Devoirs, 5 = Infos
                                      if (data['type'] == 'admin_info') {
                                        _childInitialInfosSubTab = n['title']?.toString().toLowerCase().contains('financiÃ¨re') == true ? 0 : 1;
                                      }
                                      _currentIndex = 0;
                                      if (childIndex < _childrenData.length) {
                                        _childrenData[childIndex]['notif'] = 0;
                                      }
                                      if (data['type'] == 'new_homework' &&
                                          data['devoir_id'] != null) {
                                        _pendingHighlightHomeworkId =
                                            data['devoir_id']?.toString();
                                      }
                                    });
                                    _onChildSelected(childIndex);
                                  }

                                  if (notificationId != null) {
                                    ApiClient.instance.put(
                                      ApiEndpoints.markNotificationRead(
                                        notificationId,
                                      ),
                                    );
                                  }
                                  return;
                                }
                              }
                            }

                            if (n['type'] == 'MESSAGE') {
                              Navigator.pop(context);
                              // ignore: invalid_use_of_protected_member
                              setState(() {
                                _selectedChild = null;
                                _selectedChildIndex = null;
                                _childInitialTab = 0;
                                _currentIndex = 1; // 1 = Messages when selectedChild is null
                              });
                              return;
                            }

                            if (n['type'] == 'RDV' || (n['data'] != null && n['data']['type'] == 'evenement')) {
                              Navigator.pop(context);
                              // ignore: invalid_use_of_protected_member
                              setState(() {
                                _selectedChild = null;
                                _selectedChildIndex = null;
                                _childInitialTab = 0;
                                _currentIndex = 2; // 2 = Ã‰vÃ©nements when selectedChild is null
                              });
                              return;
                            }

                            if (n['type'] == 'INFO' ||
                                n['type'] == 'ABSENCE') {
                              int childIndex = -1;
                              final eleveId = n['data']?['eleve_id'];
                              if (eleveId != null) {
                                childIndex = _childrenData.indexWhere(
                                  (c) => c['id'].toString() == eleveId.toString(),
                                );
                              } else {
                                final childName = n['child']?.toString().split(' ')[0];
                                if (childName != null && childName.isNotEmpty) {
                                  childIndex = _childrenData.indexWhere(
                                    (c) => (c['name'] as String).contains(childName),
                                  );
                                }
                              }

                              if (childIndex != -1) {
                                  Navigator.pop(context);
                                  // ignore: invalid_use_of_protected_member
                                  setState(() {
                                    _childInitialTab = 5;
                                    _childInitialInfosSubTab = n['title']?.toString().toLowerCase().contains('financiÃ¨re') == true ? 0 : 1;
                                    _currentIndex = 0;
                                  });
                                  _onChildSelected(childIndex);
                                }
                              }
                            },
                            child: _buildNotificationItem(
                            title: n['title'],
                            type: n['type'] ?? 'INFO',
                            child: n['child'],
                            school: n['school'],
                            sender: n['sender'],
                            time: n['time'],
                            color: n['isAlert'] == true
                                ? Colors.red
                                : n['color'],
                            icon: n['icon'],
                            showJustify: n['showJustify'] ?? false,
                            isAppointmentRequest:
                                n['isAppointmentRequest'] ?? false,
                            message: n['message'],
                            isAlert: n['isAlert'] ?? false,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String type,
    required String child,
    required String school,
    required String sender,
    required String time,
    required Color color,
    required IconData icon,
    bool showJustify = false,
    bool isAppointmentRequest = false,
    String? message,
    bool isAlert = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAlert ? Colors.red.withOpacity(0.02) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isAlert ? Border.all(color: Colors.red.withOpacity(0.1)) : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isAlert
                                ? Colors.red
                                : color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            type,
                            style: TextStyle(
                              color: isAlert ? Colors.white : color,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        Text(
                          time,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    if (message != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                        child: Text(
                          message,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            color: isAlert
                                ? Colors.red[900]
                                : AppTheme.textDark,
                          ),
                        ),
                      ),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 12,
                        ),
                        children: [
                          const TextSpan(text: 'AdressÃ© au parent de : '),
                          TextSpan(
                            text: child,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.seaBlue,
                            ),
                          ),
                          TextSpan(
                            text: ' â€¢ $school',
                            style: const TextStyle(color: AppTheme.textGrey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ã‰metteur: $sender',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isAppointmentRequest) ...[
            const SizedBox(height: 15),
            Row(
              children: [
                const SizedBox(width: 49),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: const [
                              Icon(Icons.check_circle, color: Colors.white),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'RDV acceptÃ© ! Il a Ã©tÃ© ajoutÃ© Ã  vos Ã©vÃ©nements.',
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.seaBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'ACCEPTER',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.seaBlue,
                      side: const BorderSide(color: AppTheme.seaBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'REPORTER',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (showJustify) ...[
            const SizedBox(height: 15),
            Row(
              children: [
                const SizedBox(width: 49),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // On simule l'ouverture du modal d'absence dÃ©jÃ  existant dans ChildDetailsView
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Ouverture du formulaire de justification...',
                          ),
                          backgroundColor: AppTheme.seaBlue,
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: color.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Justifier l\'absence',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
