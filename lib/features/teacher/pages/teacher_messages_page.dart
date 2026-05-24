import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';

class TeacherMessagesPage extends StatefulWidget {
  const TeacherMessagesPage({super.key});

  @override
  State<TeacherMessagesPage> createState() => _TeacherMessagesPageState();
}

class _TeacherMessagesPageState extends State<TeacherMessagesPage> {
  String _selectedFilter = 'Parents';
  final List<String> _filters = ['Parents', 'Administration'];

  // Conversations avec parents
  final List<Map<String, dynamic>> _conversations = [
    {
      'name': 'M. Ewosso D-Gall',
      'subtitle': 'Parent de Junior Nguema — 3ème B',
      'category': 'Parents',
      'lastMessage': 'Je serai présent pour le RDV de demain.',
      'time': '14:20',
      'unreadCount': 1,
      'isOnline': true,
      'avatarColor': AppTheme.seaBlue,
      'initials': 'ED',
      'chatMessages': [
        {'sender': 'parent', 'text': 'Bonjour M. Obiang, j\'ai reçu votre message concernant Junior.', 'time': '13:45'},
        {'sender': 'prof', 'text': 'Bonjour M. Ewosso. Oui, Junior accumule les retards et a raté le devoir de Français.', 'time': '13:50'},
        {'sender': 'prof', 'text': 'Une rencontre est nécessaire pour trouver une solution ensemble.', 'time': '13:51'},
        {'sender': 'parent', 'text': 'Je comprends. Quand pouvez-vous me recevoir ?', 'time': '14:10'},
        {'sender': 'prof', 'text': 'Demain à 15h30 en visioconférence. Est-ce que ça vous convient ?', 'time': '14:15'},
        {'sender': 'parent', 'text': 'Je serai présent pour le RDV de demain.', 'time': '14:20'},
      ],
    },
    {
      'name': 'Mme Nguema',
      'subtitle': 'Mère de Yannick Nguema — Terminale C',
      'category': 'Parents',
      'lastMessage': 'Je vais lui parler ce soir. Merci Professeur.',
      'time': '11:05',
      'unreadCount': 0,
      'isOnline': false,
      'avatarColor': Colors.purple,
      'initials': 'NG',
      'chatMessages': [
        {'sender': 'prof', 'text': 'Bonjour Mme Nguema. Je vous contacte au sujet de la note de Yannick en Mathématiques.', 'time': '10:30'},
        {'sender': 'prof', 'text': 'Il a obtenu 14/20 au dernier contrôle, mais j\'ai remarqué qu\'il se déconcentre souvent en classe.', 'time': '10:31'},
        {'sender': 'parent', 'text': 'Bonjour M. Obiang. Merci pour l\'information. Qu\'est-ce qui se passe avec lui ?', 'time': '10:50'},
        {'sender': 'prof', 'text': 'Il parle beaucoup avec ses camarades. En Terminale C, cela peut vite impacter ses résultats au BAC.', 'time': '10:55'},
        {'sender': 'parent', 'text': 'Je vais lui parler ce soir. Merci Professeur.', 'time': '11:05'},
      ],
    },
    {
      'name': 'Administration',
      'subtitle': 'Direction — Notre Dame de Quaben',
      'category': 'Administration',
      'lastMessage': 'Les notes du T2 doivent être saisies avant le 20 Mars.',
      'time': '09:00',
      'unreadCount': 2,
      'isOnline': true,
      'avatarColor': AppTheme.forestGreen,
      'initials': 'AD',
      'chatMessages': [
        {'sender': 'parent', 'text': 'M. Obiang, veuillez noter que le conseil de classe de 3ème B est fixé au 22 Mars à 17h00.', 'time': '08:30'},
        {'sender': 'parent', 'text': 'Votre présence est obligatoire. Merci de confirmer.', 'time': '08:31'},
        {'sender': 'prof', 'text': 'Bien reçu. Je serai présent.', 'time': '08:45'},
        {'sender': 'parent', 'text': 'Les notes du T2 doivent être saisies avant le 20 Mars.', 'time': '09:00'},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Messagerie',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 15),
                  // SEARCH
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Rechercher une conversation...',
                        hintStyle: TextStyle(color: Color(0xFFA0AEC0), fontSize: 14),
                        icon: Icon(Icons.search, color: Color(0xFFA0AEC0), size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // FILTER CHIPS
                  Row(
                    children: _filters.map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedFilter = filter),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.seaBlue : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? AppTheme.seaBlue : Colors.grey[300]!,
                              ),
                            ),
                            child: Text(
                              filter,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey[600],
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),

            // CONVERSATION LIST
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _conversations.length,
                itemBuilder: (context, index) {
                  final chat = _conversations[index];
                  if (chat['category'] != _selectedFilter) return const SizedBox.shrink();
                  return _buildConversationTile(chat);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationTile(Map<String, dynamic> chat) {
    final Color color = chat['avatarColor'] as Color;
    final int unread = chat['unreadCount'] as int;

    return GestureDetector(
      onTap: () => _openChat(chat),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: color.withOpacity(0.14),
                  child: Text(chat['initials'], style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                if (chat['isOnline'] == true)
                  Positioned(
                    right: 1, bottom: 1,
                    child: Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(color: const Color(0xFF48C774), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                    ),
                  ),
                if (unread > 0)
                  Positioned(
                    right: 0, top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
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
                      Text(chat['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark)),
                      Text(chat['time'], style: TextStyle(color: Colors.grey[400], fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(chat['subtitle'], style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(
                    chat['lastMessage'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: unread > 0 ? AppTheme.textDark : Colors.grey[500],
                      fontSize: 13,
                      fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  void _openChat(Map<String, dynamic> chat) {
    final Color color = chat['avatarColor'] as Color;
    final chatMessages = chat['chatMessages'] as List<Map<String, dynamic>>;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: const Color(0xFFECF2FD),
          appBar: AppBar(
            backgroundColor: AppTheme.seaBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(chat['initials'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(chat['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(chat['subtitle'], style: const TextStyle(fontSize: 10, color: Colors.white70), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: chatMessages.length,
                  itemBuilder: (ctx, i) {
                    final msg = chatMessages[i];
                    // 'prof' = M. Obiang (aligné à droite), 'parent' = autre côté
                    final isMe = msg['sender'] == 'prof';
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(ctx).size.width * 0.72),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isMe ? AppTheme.seaBlue : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(18),
                            topRight: const Radius.circular(18),
                            bottomLeft: isMe ? const Radius.circular(18) : Radius.zero,
                            bottomRight: isMe ? Radius.zero : const Radius.circular(18),
                          ),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
                        ),
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg['text'],
                              style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 14, height: 1.4),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              msg['time'],
                              style: TextStyle(color: isMe ? Colors.white70 : Colors.grey[400], fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Input bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: const BoxDecoration(color: Colors.white),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(25)),
                        child: const Text('Écrire un message...', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppTheme.seaBlue, shape: BoxShape.circle),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
