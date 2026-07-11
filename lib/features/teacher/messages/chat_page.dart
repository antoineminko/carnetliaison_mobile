import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/features/communication/services/message_service.dart';
import 'package:app_mobile/features/communication/models/message.dart';
import 'package:app_mobile/features/auth/services/auth_service.dart';

class ChatPage extends StatefulWidget {
  final Map<String, dynamic> conversation;

  const ChatPage({super.key, required this.conversation});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final MessageService _messageService = MessageService();
  List<Message> _messages = [];
  bool _isLoading = true;
  int? _conversationId;

  @override
  void initState() {
    super.initState();
    _conversationId = widget.conversation['conversation_id'];
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final teacherId = await AuthService.getTeacherId();
      if (teacherId == null) return;

      final parentId = widget.conversation['parent_id'];
      if (parentId == null) return;

      final data = await _messageService.getConversation(parentId, teacherId);
      setState(() {
        _messages = data['messages'] ?? [];
        _conversationId = data['conversation_id'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error loading messages: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _conversationId == null)
      return;

    final teacherId = await AuthService.getTeacherId();
    if (teacherId == null) return;

    final content = _messageController.text.trim();
    _messageController.clear();

    try {
      final newMessage = await _messageService.sendMessage(
        conversationId: _conversationId!,
        senderType: 'teacher',
        senderId: teacherId,
        content: content,
      );

      setState(() {
        _messages.add(newMessage);
      });
    } catch (e) {
      debugPrint('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'envoi du message')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.conversation['parent_name'] ?? 'Chat'),
            Text(
              widget.conversation['subject'] ?? '',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textDark,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    reverse: false,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isMe = message.senderType == 'teacher';
                      return _buildMessageBubble(message, isMe);
                    },
                  ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.seaBlue : Colors.grey[200],
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: isMe
                ? const Radius.circular(0)
                : const Radius.circular(20),
            bottomLeft: isMe
                ? const Radius.circular(20)
                : const Radius.circular(0),
          ),
        ),
        child: Text(
          message.content,
          style: TextStyle(color: isMe ? Colors.white : AppTheme.textDark),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Écrivez votre message...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: AppTheme.seaBlue),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
