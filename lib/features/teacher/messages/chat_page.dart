import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/features/auth/services/auth_service.dart';
import 'package:app_mobile/shared/config/api_client.dart';
import 'package:app_mobile/features/calls/pages/call_page.dart';
import 'package:app_mobile/features/teacher/messages/widgets/message_bubble.dart';

import 'viewmodels/teacher_chat_viewmodel.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/chat_report_dialog.dart';

class ChatPage extends StatefulWidget {
  final Map<String, dynamic> conversation;
  static int? activeConversationId;
  const ChatPage({super.key, required this.conversation});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  late TeacherChatViewModel _viewModel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _viewModel = TeacherChatViewModel(initialConversation: widget.conversation);
    ChatPage.activeConversationId = widget.conversation['conversation_id'];
    _viewModel.notifyPresence(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _viewModel.notifyPresence(false);
    ChatPage.activeConversationId = null;
    _scrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _viewModel.notifyPresence(true);
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _viewModel.notifyPresence(false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _initiateCall(String type) async {
    if (_viewModel.conversationId == null) return;
    final teacherId = await AuthService.getTeacherId();
    if (teacherId == null) return;
    try {
      final response = await ApiClient.instance.post(
        '/calls/initiate',
        data: {
          'conversation_id': _viewModel.conversationId,
          'type': type,
          'caller_type': 'enseignant',
          'caller_id': teacherId,
        },
      );
      if (response.data['success'] == true && response.data['call'] != null) {
        final int callId = int.parse(response.data['call']['id'].toString());
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CallPage(
                callId: callId,
                callType: type,
                callerName: widget.conversation['parent_name'] ?? 'Parent',
                isIncoming: false,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'appel: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showReportDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ChatReportDialog(
          conversationId: _viewModel.conversationId,
          reporterId: _viewModel.myId,
          reportedId: widget.conversation['parent_id'],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TeacherChatViewModel>.value(
      value: _viewModel,
      child: Consumer<TeacherChatViewModel>(
        builder: (context, viewModel, child) {
          // If message count changes and we should scroll
          if (viewModel.messages.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients && 
                  _scrollController.position.maxScrollExtent - _scrollController.position.pixels < 150) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });
          }

          return Scaffold(
            backgroundColor: AppTheme.background,
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.conversation['parent_name'] ?? 'Chat',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (viewModel.isOnline) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
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
              actions: [
                if (viewModel.conversationStatus == 'accepted')
                  IconButton(
                    icon: const Icon(Icons.phone, color: AppTheme.seaBlue),
                    onPressed: () => _initiateCall('audio'),
                    tooltip: 'Appel vocal',
                  ),
                if (viewModel.conversationStatus == 'accepted')
                  IconButton(
                    icon: const Icon(Icons.videocam, color: AppTheme.seaBlue),
                    onPressed: () => _initiateCall('video'),
                    tooltip: 'Appel vidéo',
                  ),
                if (viewModel.conversationStatus == 'accepted')
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (_) => _showReportDialog(),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'report',
                        child: Row(
                          children: [
                            Icon(Icons.flag, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text('Signaler', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            body: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: Colors.amber.withOpacity(0.1),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock, size: 14, color: Colors.amber),
                      SizedBox(width: 6),
                      Text(
                        'Conversation chiffrée de bout en bout',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: viewModel.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          controller: _scrollController,
                          reverse: false,
                          padding: const EdgeInsets.all(16),
                          itemCount: viewModel.messages.length,
                          itemBuilder: (context, index) {
                            final message = viewModel.messages[index];
                            final isMe = message.senderType == 'enseignant';
                            return MessageBubble(message: message, isMe: isMe);
                          },
                        ),
                ),
                if (viewModel.conversationStatus == 'pending' && viewModel.isReceiver)
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Column(
                      children: [
                        const Text('Demande de discussion entrante', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[50],
                                foregroundColor: Colors.red,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                              onPressed: () async {
                                await viewModel.updateStatus('rejected');
                                if (mounted) Navigator.pop(context);
                              },
                              child: const Text('Refuser'),
                            ),
                            ElevatedButton(
                              style: AppTheme.primaryButtonStyle.copyWith(
                                padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                              ),
                              onPressed: () => viewModel.updateStatus('accepted'),
                              child: const Text('Accepter'),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                else if (viewModel.conversationStatus == 'rejected')
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.red[50],
                    alignment: Alignment.center,
                    child: const Text('Discussion refusée.', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  )
                else if (viewModel.conversationId != null && viewModel.conversationStatus == 'pending' && !viewModel.isReceiver)
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: AppTheme.background,
                    alignment: Alignment.center,
                    child: const Text("En attente d'acceptation...", style: TextStyle(color: AppTheme.textGrey, fontStyle: FontStyle.italic)),
                  )
                else
                  ChatInputBar(onMessageSent: _scrollToBottom),
              ],
            ),
          );
        },
      ),
    );
  }
}
