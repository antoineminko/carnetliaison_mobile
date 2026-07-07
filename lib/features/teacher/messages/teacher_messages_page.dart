import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/features/teacher/services/teacher_message_service.dart';
import 'package:app_mobile/features/auth/services/auth_service.dart';
import 'package:app_mobile/features/parent/messages/chat_page.dart';

class TeacherMessagesPage extends StatefulWidget {
  const TeacherMessagesPage({super.key});

  @override
  State<TeacherMessagesPage> createState() => _TeacherMessagesPageState();
}

class _TeacherMessagesPageState extends State<TeacherMessagesPage> {
  List<dynamic> _conversations = [];
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
      
      final response = await TeacherMessageService.instance.getConversations(teacherId);

      if (response.data['success']) {
        setState(() {
          _conversations = response.data['conversations'];
          _isLoading = false;
        });
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
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
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
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 15),
                    const TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      labelColor: AppTheme.seaBlue,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: AppTheme.seaBlue,
                      indicatorWeight: 3,
                      labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      tabs: [
                        Tab(text: 'Parents'),
                        Tab(text: 'Administration'),
                      ],
                    ),
                  ],
                ),
              ),

              // CONVERSATION LIST
              Expanded(
                child: TabBarView(
                  children: [
                    _buildParentsTab(),
                    _buildAdminTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParentsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_conversations.isEmpty) {
      return const Center(child: Text("Aucune conversation.", style: TextStyle(color: AppTheme.textGrey)));
    }

    return RefreshIndicator(
      onRefresh: _fetchConversations,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _conversations.length,
        itemBuilder: (context, index) {
          final chat = _conversations[index];
          return _buildConversationTile(chat);
        },
      ),
    );
  }

  Widget _buildAdminTab() {
    return const Center(
      child: Text(
        'Aucun message de l\'administration',
        style: TextStyle(color: AppTheme.textGrey),
      ),
    );
  }

  Widget _buildConversationTile(dynamic chat) {
    final String nom = chat['parent_nom'] ?? '';
    final String prenom = chat['parent_prenom'] ?? '';
    final String fullName = '$prenom $nom'.trim();
    final String initials = (prenom.isNotEmpty ? prenom[0] : '') + (nom.isNotEmpty ? nom[0] : '');
    
    // Contexte de l'élève
    final String eleveNom = chat['eleve_nom'] ?? '';
    final String elevePrenom = chat['eleve_prenom'] ?? '';
    final String classeNom = chat['classe_nom'] ?? '';
    final String eleveContext = elevePrenom.isNotEmpty ? 'Parent de $elevePrenom $eleveNom — $classeNom' : (chat['subject'] ?? 'Discussion');

    final String subtitle = eleveContext;
    final String lastMessage = chat['last_message'] ?? 'Aucun message';
    final String time = chat['last_message_time'] ?? '';
    final Color color = AppTheme.seaBlue;
    final bool isPending = chat['status'] == 'pending';

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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: color.withOpacity(0.14),
              child: Text(initials.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark)),
                      Text(time, style: TextStyle(color: Colors.grey[400], fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isPending ? AppTheme.textDark : Colors.grey[500],
                            fontSize: 13,
                            fontWeight: isPending ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (isPending)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.orange[200]!),
                          ),
                          child: const Text('En attente', style: TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
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
}

