part of '../accueil/dashboard/parent_home_page.dart';

extension MessagesViewExtension on _ParentHomePageState {
  Widget _buildMessagesTab() {
    return DefaultTabController(
      length: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text(
              'Messagerie',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
          ),
          const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppTheme.seaBlue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.seaBlue,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: [
              Tab(text: 'Tous'),
              Tab(text: 'Enseignants'),
              Tab(text: 'Administration'),
              Tab(text: 'Favoris'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildMessageList('Tous'),
                _buildMessageList('Enseignants'),
                _buildMessageList('Administration'),
                _buildMessageList('Favoris'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(String filter) {
    List<Widget> tiles = [];
    if (filter == 'Tous' || filter == 'Enseignants') {
      for (final conv in _teacherConversationsAll) {
        final enseignantNom = '${conv['enseignant_prenom'] ?? ''} ${conv['enseignant_nom'] ?? ''}'.trim();
        final initials = (conv['enseignant_nom'] ?? 'E').isNotEmpty
            ? (conv['enseignant_nom'] as String)[0].toUpperCase()
            : 'E';
        final unreadVal = conv['unread_count'];
        final unread = (unreadVal is int) ? unreadVal : (int.tryParse(unreadVal.toString()) ?? 0);
        tiles.add(
          _buildMessageTile(
            name: enseignantNom.isNotEmpty ? enseignantNom : 'Enseignant',
            role: conv['subject'] ?? 'Discussion',
            initials: initials,
            color: AppTheme.seaBlue,
            school: conv['admin_name'] ?? '',
            childName: '${conv['eleve_prenom'] ?? ''} ${conv['eleve_nom'] ?? ''}'.trim(),
            lastMsg: conv['subject'] ?? '',
            time: '',
            unreadCount: unread,
            conversationId: conv['conversation_id'],
            conversationData: Map<String, dynamic>.from(conv),
          ),
        );
      }
    }

    // CONVERSATIONS ADMINISTRATION (données réelles)
    if (filter == 'Tous' || filter == 'Administration') {
      for (final conv in _adminConversations) {
        final adminName = conv['admin_name'] ?? 'Administration';
        final unreadVal = conv['unread_count'];
        final unread = (unreadVal is int) ? unreadVal : (int.tryParse(unreadVal.toString()) ?? 0);
        tiles.add(
          _buildMessageTile(
            name: adminName,
            role: conv['subject'] ?? 'Message de l\'Administration',
            initials: 'AD',
            color: AppTheme.forestGreen,
            school: adminName,
            childName: '${conv['eleve_prenom'] ?? ''} ${conv['eleve_nom'] ?? ''}'.trim(),
            lastMsg: conv['subject'] ?? 'Nouveau message',
            time: '',
            unreadCount: unread,
            conversationId: conv['conversation_id'],
            conversationData: Map<String, dynamic>.from(conv),
          ),
        );
      }
    }

    if (tiles.isEmpty) {
      return const Center(
        child: Text(
          'Aucun message récent',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView(padding: const EdgeInsets.all(20), children: tiles);
  }

  Widget _buildMessageTile({
    required String name,
    required String role,
    required String initials,
    required Color color,
    required String school,
    required String childName,
    required String lastMsg,
    required String time,
    required int unreadCount,
    int? conversationId,
    Map<String, dynamic>? conversationData,
  }) {
    return GestureDetector(
      onTap: () {
        if (conversationId != null) {
          // Mettre à jour immédiatement les compteurs non lus côté UI
          setState(() {
            for (final conv in _teacherConversationsAll) {
              if (conv['conversation_id'] == conversationId) {
                conv['unread_count'] = 0;
              }
            }
            for (final conv in _adminConversations) {
              if (conv['conversation_id'] == conversationId) {
                conv['unread_count'] = 0;
              }
            }
          });

          // Naviguer vers la vraie page de chat
          final conv = conversationData ?? {};
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatPage(conversation: {
                ...conv,
                'conversation_id': conversationId,
                'status': 'accepted',
              }),
            ),
          ).then((_) => _fetchConversations());
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: color.withOpacity(0.15),
                  child: Text(
                    initials,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(color: Colors.grey[400], fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$childName • $school',
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMsg,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: unreadCount > 0
                          ? AppTheme.textDark
                          : Colors.grey[500],
                      fontSize: 13,
                      fontWeight: unreadCount > 0
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

}
