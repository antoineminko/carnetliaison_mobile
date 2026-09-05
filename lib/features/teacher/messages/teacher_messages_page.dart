import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/features/teacher/services/teacher_message_service.dart';
import 'package:app_mobile/features/communication/services/message_service.dart';
import 'package:app_mobile/features/auth/services/auth_service.dart';
import 'package:app_mobile/features/teacher/messages/chat_page.dart';
import 'package:intl/intl.dart';

class TeacherMessagesPage extends StatefulWidget {
  final VoidCallback? onRefresh;
  const TeacherMessagesPage({super.key, this.onRefresh});

  @override
  State<TeacherMessagesPage> createState() => _TeacherMessagesPageState();
}

class _TeacherMessagesPageState extends State<TeacherMessagesPage> {
  List<dynamic> _allConversations = [];
  List<dynamic> _parentConversations = [];
  List<dynamic> _adminConversations = [];
  List<dynamic> _callHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    try {
      final teacherId = await AuthService.getTeacherId();
      if (teacherId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final response = await TeacherMessageService.instance.getConversations(
        teacherId,
      );
      
      final callHistory = await MessageService().getCallHistory('enseignant', teacherId);

      if (response.data['success']) {
        final conversations = response.data['conversations'] as List<dynamic>;
        setState(() {
          _allConversations = conversations;
          _parentConversations = conversations.where((c) => c['parent_id'] != null).toList();
          _adminConversations = conversations.where((c) => c['parent_id'] == null).toList();
          _callHistory = callHistory;
          _isLoading = false;
        });
        widget.onRefresh?.call();
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      labelColor: AppTheme.seaBlue,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: AppTheme.seaBlue,
                      indicatorWeight: 3,
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      tabs: [
                        Tab(text: 'Tous'),
                        Tab(text: 'Parents'),
                        Tab(text: 'Administration'),
                        Tab(text: 'Appels'),
                      ],
                    ),
                  ],
                ),
              ),

              // CONVERSATION LIST
              Expanded(
                child: TabBarView(
                  children: [
                    _buildTabContent(_allConversations),
                    _buildTabContent(_parentConversations),
                    _buildTabContent(_adminConversations),
                    _buildCallHistoryTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(List<dynamic> list) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (list.isEmpty) {
      return const Center(
        child: Text(
          "Aucune conversation.",
          style: TextStyle(color: AppTheme.textGrey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchConversations,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final chat = list[index];
          return _buildConversationTile(chat);
        },
      ),
    );
  }

  Widget _buildConversationTile(dynamic chat) {
    final String nom = chat['parent_nom'] ?? '';
    final String prenom = chat['parent_prenom'] ?? '';
    final String adminName = chat['admin_name'] ?? 'Administration';
    final bool isAdmin = chat['parent_id'] == null;
    
    final String fullName = isAdmin ? adminName : '$prenom $nom'.trim();
    final String initials = isAdmin 
        ? 'AD' 
        : ((prenom.isNotEmpty ? prenom[0] : '') + (nom.isNotEmpty ? nom[0] : ''));

    // Contexte de l'élève
    final String eleveNom = chat['eleve_nom'] ?? '';
    final String elevePrenom = chat['eleve_prenom'] ?? '';
    final String classeNom = chat['classe_nom'] ?? '';
    final String eleveContext = isAdmin 
        ? 'Administration' 
        : (elevePrenom.isNotEmpty
            ? 'Parent de $elevePrenom $eleveNom — $classeNom'
            : (chat['subject'] ?? 'Discussion'));

    final String subtitle = eleveContext;
    final String lastMessage = chat['last_message'] ?? 'Aucun message';
    final String time = chat['last_message_time'] ?? '';
    final Color color = AppTheme.seaBlue;
    final bool isPending = chat['status'] == 'pending';
    
    // Check if unread
    final unreadCount = chat['unread_count'];
    final bool hasUnread = unreadCount != null && 
        (unreadCount is int ? unreadCount > 0 : (int.tryParse(unreadCount.toString()) ?? 0) > 0);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              conversation: {
                'conversation_id': chat['conversation_id'],
                'parent_id': chat['parent_id'],
                'parent_name': fullName,
                'subject': subtitle,
              },
            ),
          ),
        ).then((_) => _fetchConversations());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: color.withOpacity(0.14),
              child: Text(
                initials.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
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
                        fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isPending
                                ? AppTheme.textDark
                                : Colors.grey[500],
                            fontSize: 13,
                            fontWeight: isPending
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (hasUnread)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (isPending)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.orange[200]!),
                          ),
                          child: const Text(
                            'En attente',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
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

  Widget _buildCallHistoryTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_callHistory.isEmpty) {
      return const Center(
        child: Text(
          "Aucun appel.",
          style: TextStyle(color: AppTheme.textGrey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchConversations,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _callHistory.length,
        itemBuilder: (context, index) {
          final call = _callHistory[index];
          return _buildCallHistoryTile(call);
        },
      ),
    );
  }

  Widget _buildCallHistoryTile(dynamic call) {
    final bool isIncoming = call['is_incoming'] ?? false;
    final String type = call['type'] ?? 'audio';
    final String status = call['status'] ?? 'completed';
    final String otherName = call['other_name'] ?? 'Utilisateur';
    
    // Parse time
    final String rawDate = call['created_at'] ?? '';
    String timeStr = '';
    if (rawDate.isNotEmpty) {
      try {
        final date = DateTime.parse(rawDate).toLocal();
        timeStr = DateFormat('dd/MM HH:mm').format(date);
      } catch (e) {
        debugPrint('Error parsing date: $e');
      }
    }

    IconData callIcon = Icons.call;
    Color iconColor = Colors.grey;
    String statusText = 'Appel';

    if (status == 'missed') {
      callIcon = isIncoming ? Icons.call_missed : Icons.call_made;
      iconColor = Colors.red;
      statusText = 'Appel manqué';
    } else if (status == 'rejected') {
      callIcon = isIncoming ? Icons.call_received : Icons.call_made;
      iconColor = Colors.red;
      statusText = 'Appel refusé';
    } else if (status == 'unavailable') {
      callIcon = Icons.call_end;
      iconColor = Colors.orange;
      statusText = 'Indisponible';
    } else {
      callIcon = isIncoming ? Icons.call_received : Icons.call_made;
      iconColor = Colors.green;
      statusText = isIncoming ? 'Appel entrant' : 'Appel sortant';
    }

    if (type == 'video') {
      callIcon = Icons.videocam;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: iconColor.withOpacity(0.14),
            child: Icon(callIcon, color: iconColor, size: 20),
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
                      otherName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppTheme.textDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      timeStr,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
