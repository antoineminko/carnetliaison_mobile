import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/features/communication/services/message_service.dart';
import 'package:app_mobile/features/communication/models/message.dart';
import 'package:app_mobile/features/auth/services/auth_service.dart';
import 'package:app_mobile/shared/config/api_client.dart';
import 'package:app_mobile/shared/widgets/background_wrapper.dart';
import 'package:app_mobile/features/calls/pages/call_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_picker/file_picker.dart' as fp;

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
  String _conversationStatus = 'pending';
  bool _isOnline = false;
  int _myId = 0;

  // ── Polling temps réel ────────────────────────────────────────────────────
  Timer? _pollingTimer;
  int _lastMessageCount = 0;
  final ScrollController _scrollController = ScrollController();

  // Options de signalement
  final List<Map<String, dynamic>> _reportReasons = [
    {'value': 'harassment', 'label': 'Harcèlement', 'icon': Icons.warning},
    {'value': 'inappropriate_content', 'label': 'Propos inappropriés', 'icon': Icons.block},
    {'value': 'spam', 'label': 'Spam', 'icon': Icons.report},
    {'value': 'fake_account', 'label': 'Faux compte', 'icon': Icons.person_off},
    {'value': 'other', 'label': 'Autre', 'icon': Icons.help_outline},
  ];

  PlatformFile? _attachedFile;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _conversationId = widget.conversation['conversation_id'];
    // Fetch initial, puis démarrage du polling une fois la conversation chargée
    _loadMessages().then((_) => _startPolling());
  }

  Future<void> _loadMessages() async {
    try {
      final teacherId = await AuthService.getTeacherId();
      if (teacherId == null) return;
      _myId = teacherId;

      final parentId = widget.conversation['parent_id'];

      final data = await _messageService.getConversation(parentId, teacherId);
      if (mounted) {
        setState(() {
          _messages = data['messages'] ?? [];
          _conversationId = data['conversation_id'];
          _isOnline = data['is_online'] ?? false;
          _conversationStatus = data['status'] ?? widget.conversation['status'] ?? 'pending';
          _lastMessageCount = _messages.length; // Référence pour le polling
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint('Error loading messages: $e');
    }
  }

  // ── Polling temps réel ────────────────────────────────────────────────────

  /// Démarre le timer de polling (toutes les 3 secondes).
  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted && _conversationId != null) {
        _pollNewMessages();
      }
    });
  }

  /// Interroge l'API silencieusement.
  /// Ne déclenche setState que si de nouveaux messages sont détectés.
  Future<void> _pollNewMessages() async {
    try {
      final parentId = widget.conversation['parent_id'];
      final data = await _messageService.getConversation(parentId, _myId);

      final newMessages = data['messages'] as List<Message>? ?? [];

      if (newMessages.length != _lastMessageCount && mounted) {
        final bool hadNewMessages = newMessages.length > _lastMessageCount;
        setState(() {
          _messages = newMessages;
          _lastMessageCount = newMessages.length;
          _isOnline = data['is_online'] ?? _isOnline;
          // Mettre à jour le statut si la conversation a été acceptée entre-temps
          if (data['status'] != null) _conversationStatus = data['status'];
        });
        if (hadNewMessages) _scrollToBottomIfNearEnd();
      }
    } catch (_) {
      // Polling silencieux — erreurs réseau transitoires ignorées
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

  /// Scroll vers le bas uniquement si l'utilisateur est dans les 150px de la fin.
  void _scrollToBottomIfNearEnd() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.maxScrollExtent - pos.pixels < 150) {
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty && _attachedFile == null) return;

    final teacherId = await AuthService.getTeacherId();
    if (teacherId == null) return;

    _messageController.clear();
    setState(() {
      _isUploading = true;
    });

    try {
      if (_conversationId == null) {
        final parentId = widget.conversation['parent_id'];
        final data = await _messageService.initiateConversation(
          parentId: parentId,
          enseignantId: teacherId,
          initialMessage: text,
          subject: widget.conversation['subject'] ?? 'Discussion',
        );
        setState(() {
          _conversationId = data['conversation']['id'];
          _messages.add(Message.fromJson(data['message']));
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demande de conversation envoyée au parent.')),
        );
        return;
      }
      final newMessage = await _messageService.sendMessage(
        conversationId: _conversationId!,
        senderType: 'enseignant',
        senderId: teacherId,
        content: text,
        filePath: _attachedFile?.path,
        fileName: _attachedFile?.name,
      );

      setState(() {
        _messages.add(newMessage);
      });
    } catch (e) {
      debugPrint('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'envoi du message')),
      );
    } finally {
      setState(() {
        _attachedFile = null;
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                if (_isOnline) ...[
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
          // Bouton Appel vocal
          if (_conversationStatus == 'accepted')
            IconButton(
              icon: const Icon(Icons.phone, color: AppTheme.seaBlue),
              onPressed: () => _initiateCall('audio'),
              tooltip: 'Appel vocal',
            ),
          // Bouton Appel vidéo
          if (_conversationStatus == 'accepted')
            IconButton(
              icon: const Icon(Icons.videocam, color: AppTheme.seaBlue),
              onPressed: () => _initiateCall('video'),
              tooltip: 'Appel vidéo',
            ),
          // Bouton Signalement
          if (_conversationStatus == 'accepted')
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
      body: BackgroundWrapper(
        child: Column(
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    reverse: false,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isMe = message.senderType == 'enseignant';
                      return _buildMessageBubble(message, isMe);
                    },
                  ),
          ),
          if (_conversationStatus == 'pending' && _isReceiver)
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
                        onPressed: () => _updateStatus('rejected'),
                        child: const Text('Refuser'),
                      ),
                      ElevatedButton(
                        style: AppTheme.primaryButtonStyle.copyWith(
                          padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                        ),
                        onPressed: () => _updateStatus('accepted'),
                        child: const Text('Accepter'),
                      ),
                    ],
                  )
                ],
              ),
            )
          else if (_conversationStatus == 'rejected')
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.red[50],
              alignment: Alignment.center,
              child: const Text('Discussion refusée.', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            )
          else if (_conversationId != null && _conversationStatus == 'pending' && !_isReceiver)
            Container(
              padding: const EdgeInsets.all(16),
              color: AppTheme.background,
              alignment: Alignment.center,
              child: const Text("En attente d'acceptation...", style: TextStyle(color: AppTheme.textGrey, fontStyle: FontStyle.italic)),
            )
          else
            _buildMessageInput(),
        ],
      ),
      ),
    );
  }

  bool get _isReceiver {
    if (_messages.isEmpty) return false;
    return _messages.first.senderType != 'enseignant';
  }

  Future<void> _updateStatus(String status) async {
    if (_conversationId == null) return;
    try {
      await ApiClient.instance.put(
        '/messages/conversation/$_conversationId/status',
        data: {'status': status},
      );
      if (mounted) {
        setState(() {
          _conversationStatus = status;
        });
        if (status == 'rejected') {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de la mise à jour")),
        );
      }
    }
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.seaBlue : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                fontSize: 15,
                color: isMe ? Colors.white : AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                message.createdAt.toString().substring(11, 16),
                style: TextStyle(
                  fontSize: 10,
                  color: isMe ? Colors.white70 : AppTheme.textGrey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 10,
            color: Colors.black.withOpacity(0.03),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            if (_attachedFile != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.attach_file, size: 20, color: AppTheme.seaBlue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _attachedFile!.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => setState(() => _attachedFile = null),
                    )
                  ],
                ),
              ),
            Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    final result = await fp.FilePicker.pickFiles();
                    if (result != null) {
                      setState(() {
                        _attachedFile = result.files.first;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.attach_file, color: AppTheme.textGrey),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Écrire un message...',
                        hintStyle: TextStyle(color: AppTheme.textGrey),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _isUploading
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : GestureDetector(
                        onTap: _sendMessage,
                        child: CircleAvatar(
                          backgroundColor: AppTheme.seaBlue,
                          radius: 24,
                          child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initiateCall(String type) async {
    if (_conversationId == null) return;
    final teacherId = await AuthService.getTeacherId();
    if (teacherId == null) return;

    try {
      final response = await ApiClient.instance.post(
        '/calls/initiate',
        data: {
          'conversation_id': _conversationId,
          'type': type,
          'caller_type': 'enseignant',
          'caller_id': teacherId,
        },
      );

      if (response.data['success'] == true && response.data['call'] != null) {
        final int callId = int.parse(response.data['call']['id'].toString());
        final String callerName = 'Moi'; // The receiver will see teacher's name

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
    String? selectedReason;
    final descriptionController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.flag, color: Colors.red),
                        ),
                        const SizedBox(width: 15),
                        const Expanded(
                          child: Text(
                            'Signaler cette conversation',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Pourquoi signalez-vous cette conversation ?',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 15),
                    ..._reportReasons.map((reason) {
                      final isSelected = selectedReason == reason['value'];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () {
                            setModalState(() {
                              selectedReason = reason['value'];
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.red.withOpacity(0.1) : Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? Colors.red : Colors.grey[200]!,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(reason['icon'] as IconData, color: isSelected ? Colors.red : Colors.grey[600], size: 24),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    reason['label'] as String,
                                    style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.red : Colors.black87),
                                  ),
                                ),
                                if (isSelected) const Icon(Icons.check_circle, color: Colors.red),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 20),
                    Text('Description (optionnel)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700])),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Décrivez la situation en détail...',
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: selectedReason == null
                            ? null
                            : () async {
                                Navigator.pop(context);
                                await _submitReport(selectedReason!, descriptionController.text);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Envoyer le signalement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submitReport(String reason, String description) async {
    if (_conversationId == null) return;
    try {
      await ApiClient.instance.post('/reports', data: {
        'conversation_id': _conversationId,
        'reporter_id': _myId,
        'reporter_type': 'enseignant',
        'reported_id': widget.conversation['parent_id'],
        'reported_type': 'parent',
        'reason': reason,
        'description': description,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signalement envoyé avec succès'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du signalement: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
