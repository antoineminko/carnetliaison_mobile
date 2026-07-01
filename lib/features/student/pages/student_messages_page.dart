import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/features/auth/parent/services/parent_auth_service.dart';
import 'package:app_mobile/features/communication/services/message_service.dart';
import 'package:app_mobile/features/communication/models/conversation.dart';
import 'student_details_pages.dart';

class StudentMessagesPage extends StatefulWidget {
  const StudentMessagesPage({super.key});

  @override
  State<StudentMessagesPage> createState() => _StudentMessagesPageState();
}

class _StudentMessagesPageState extends State<StudentMessagesPage> {
  final MessageService _messageService = MessageService();
  bool _isLoading = true;
  List<Conversation> _conversations = [];
  int? _parentId;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final parentId = await AuthService.getParentId();
    if (parentId != null) {
      final conversations = await _messageService.getConversationsForParent(parentId);
      if (mounted) {
        setState(() {
          _parentId = parentId;
          _conversations = conversations;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Messagerie', style: TextStyle(color: AppTheme.seaBlue, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : RefreshIndicator(
            onRefresh: _loadConversations,
            child: Column(
              children: [
                _buildCategoryFilter(context),
                Expanded(
                  child: _conversations.isEmpty
                      ? const Center(child: Text("Aucune conversation trouvée.", style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _conversations.length,
                          itemBuilder: (context, index) {
                            final conv = _conversations[index];
                            final isAdministration = conv.enseignantId == null;
                            
                            final name = isAdministration 
                                ? (conv.adminName ?? "Administration") 
                                : "${conv.enseignantNom} ${conv.enseignantPrenom}";
                            
                            final color = isAdministration ? AppTheme.forestGreen : Colors.purple;

                            return _buildChatTile(
                              context,
                              name: name,
                              lastMsg: "Nouvelle conversation...",
                              time: "Maintenant",
                              count: 0,
                              isGroup: false,
                              color: color,
                              conversationId: conv.id,
                              enseignantId: conv.enseignantId,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadConversations,
        backgroundColor: AppTheme.seaBlue,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            _buildFilterChip('Tous', true),
            _buildFilterChip('Enseignants', false),
            _buildFilterChip('Administration', false),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.seaBlue : Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: isSelected ? AppTheme.seaBlue : Colors.grey[200]!),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[600],
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildChatTile(
    BuildContext context, {
    required String name,
    required String lastMsg,
    required String time,
    required int count,
    required bool isGroup,
    required Color color,
    required int conversationId,
    int? enseignantId,
  }) {
    return InkWell(
      onTap: () {
        if (_parentId != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => ChatDetailPage(
            name: name, 
            color: color, 
            isGroup: isGroup, 
            parentId: _parentId!, 
            enseignantId: enseignantId,
            conversationId: conversationId,
          )));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(isGroup ? Icons.groups : Icons.person, color: color, size: 30),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name, 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark, overflow: TextOverflow.ellipsis),
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(time, style: TextStyle(color: Colors.grey[400], fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    lastMsg,
                    style: TextStyle(color: count > 0 ? AppTheme.textDark : Colors.grey[600], fontSize: 13, fontWeight: count > 0 ? FontWeight.w600 : FontWeight.normal),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (count > 0)
              Container(
                margin: const EdgeInsets.only(left: 10),
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: Text(count.toString(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}
