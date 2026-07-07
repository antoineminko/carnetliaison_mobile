import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:app_mobile/shared/config/api_client.dart';
import 'package:app_mobile/shared/config/api_endpoints.dart';
import 'package:app_mobile/features/auth/services/auth_service.dart';
import 'package:app_mobile/features/calls/pages/call_page.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatPage extends StatefulWidget {
  final Map<String, dynamic> conversation;

  const ChatPage({super.key, required this.conversation});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  String? _conversationStatus;
  int? _conversationId;
  String _myRole = '';
  int _myId = 0;

  // Options de signalement
  final List<Map<String, dynamic>> _reportReasons = [
    {'value': 'harassment', 'label': 'Harcèlement', 'icon': Icons.warning},
    {'value': 'inappropriate_content', 'label': 'Propos inappropriés', 'icon': Icons.block},
    {'value': 'spam', 'label': 'Spam', 'icon': Icons.report},
    {'value': 'fake_account', 'label': 'Faux compte', 'icon': Icons.person_off},
    {'value': 'other', 'label': 'Autre', 'icon': Icons.help_outline},
  ];

  @override
  void initState() {
    super.initState();
    _initRolesAndFetch();
  }

  Dio get _dio {
    final prefix = widget.conversation['_school_prefix']?.toString();
    if (prefix != null && ApiClient.schoolServers.containsKey(prefix)) {
      return ApiClient.getInstanceForUrl(ApiClient.schoolServers[prefix]!);
    }
    return ApiClient.instance;
  }

  Future<void> _initRolesAndFetch() async {
    final prefix = widget.conversation['_school_prefix']?.toString();
    final parentId = await AuthService.getParentIdForSchool(prefix);
    final teacherId = await AuthService.getTeacherId();
    
    if (parentId != null) {
      _myRole = 'parent';
      _myId = parentId;
    } else if (teacherId != null) {
      _myRole = 'enseignant';
      _myId = teacherId;
    }

    // Initialiser depuis les paramètres si disponibles
    _conversationStatus = widget.conversation['status'] ?? widget.conversation['conversation_status'];
    _conversationId = widget.conversation['conversation_id'] ?? widget.conversation['id'];

    await _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    try {
      final enseignantId = widget.conversation['enseignant_id'] ?? (_myRole == 'enseignant' ? _myId : 0);
      final parentId = widget.conversation['parent_id'] ?? (_myRole == 'parent' ? _myId : 0);
      final convId = widget.conversation['conversation_id'] ?? widget.conversation['id'];

      final queryParams = <String, dynamic>{
        'enseignant_id': enseignantId,
        'parent_id': parentId,
        'viewer_type': _myRole,
      };
      if (convId != null) {
        queryParams['conversation_id'] = convId;
      }

      final response = await _dio.get(
        ApiEndpoints.getConversation,
        queryParameters: queryParams,
      );

      if (response.data != null && response.data['conversation_id'] != null) {
        if (mounted) {
          setState(() {
            _conversationId = response.data['conversation_id'];
            _conversationStatus = response.data['status'];
            if (response.data['messages'] != null) {
              _messages = List<Map<String, dynamic>>.from(response.data['messages']);
            }
            _isLoading = false;
          });
          _scrollToBottom();
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      // 404 means no conversation yet, which is fine
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String status) async {
    if (_conversationId == null) return;
    try {
      await _dio.put(
        '/messages/conversation/$_conversationId/status',
        data: {'status': status},
      );
      if (mounted) {
        setState(() {
          _conversationStatus = status;
        });
      }
      if (status == 'rejected') {
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de la mise à jour")),
      );
    }
  }

  bool get _isReceiver {
    if (_messages.isEmpty) return false;
    return _messages.first['sender_type'] != _myRole;
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    // Optimistic UI update
    setState(() {
      _messages.add({
        'sender_type': _myRole,
        'content': text,
        'created_at': DateTime.now().toIso8601String(),
      });
    });
    _scrollToBottom();

    try {
      if (_conversationId == null) {
        // Initier la conversation
        final enseignantId = widget.conversation['enseignant_id'] ?? (_myRole == 'enseignant' ? _myId : 0);
        final targetParentId = widget.conversation['parent_id'] ?? (_myRole == 'parent' ? _myId : 0);

        final response = await _dio.post('/messages/conversation/initiate', data: {
          'enseignant_id': enseignantId,
          'parent_id': targetParentId,
          'subject': widget.conversation['subject'] ?? 'Discussion',
          'initial_message': text,
          'sender_type': _myRole,
        });

        if (response.data['success']) {
           setState(() {
              _conversationId = response.data['conversation']['id'];
              _conversationStatus = response.data['conversation']['status'];
           });
        }
      } else {
        // Envoyer message existant
        await _dio.post(
          ApiEndpoints.sendMessage,
          data: {
            'conversation_id': _conversationId,
            'sender_type': _myRole,
            'sender_id': _myId,
            'content': text,
          },
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de l'envoi du message")),
      );
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

  @override
  Widget build(BuildContext context) {
    final String title = widget.conversation['enseignant_nom'] != null 
        ? '${widget.conversation['enseignant_prenom']} ${widget.conversation['enseignant_nom']}'
        : (widget.conversation['parent_name'] ?? widget.conversation['admin_name'] ?? 'Discussion');

    final bool isAdmin = widget.conversation['enseignant_id'] == null;
    final Color primaryColor = isAdmin ? AppTheme.forestGreen : AppTheme.seaBlue;

    return Scaffold(
      backgroundColor: AppTheme.background, // Modern background
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
        titleSpacing: 0,
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
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: primaryColor.withOpacity(0.1),
              child: Icon(isAdmin ? Icons.account_balance : Icons.person, color: primaryColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    widget.conversation['subject'] ?? (isAdmin ? 'Administration' : 'Enseignant'),
                    style: const TextStyle(fontSize: 12, color: AppTheme.textGrey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final bool isMe = msg['sender_type'] == 'parent';
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isMe ? AppTheme.primaryBlue : Colors.white,
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
                                msg['content'] ?? '',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: isMe ? Colors.white : AppTheme.textDark,
                                ),
                              ),
                              if (msg['fichier_url'] != null) ...[
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () async {
                                    final url = Uri.parse(msg['fichier_url']);
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url, mode: LaunchMode.externalApplication);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isMe ? Colors.white.withOpacity(0.2) : AppTheme.background,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.attach_file, size: 16, color: isMe ? Colors.white : AppTheme.primaryBlue),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Ouvrir la pièce jointe',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: isMe ? Colors.white : AppTheme.primaryBlue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 6),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  msg['created_at'] != null 
                                      ? msg['created_at'].toString().substring(11, 16) 
                                      : '',
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
          else if (_conversationStatus == 'pending' && !_isReceiver)
            Container(
              padding: const EdgeInsets.all(16),
              color: AppTheme.background,
              alignment: Alignment.center,
              child: const Text("En attente d'acceptation...", style: TextStyle(color: AppTheme.textGrey, fontStyle: FontStyle.italic)),
            )
          else
            Container(
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
                child: Row(
                  children: [
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
                    GestureDetector(
                      onTap: _sendMessage,
                      child: CircleAvatar(
                        backgroundColor: AppTheme.primaryBlue,
                        radius: 24,
                        child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// Initier un appel (audio ou vidéo)
  Future<void> _initiateCall(String type) async {
    if (_conversationId == null) return;

    try {
      final response = await _dio.post('/calls', data: {
        'conversation_id': _conversationId,
        'caller_id': _myId,
        'caller_type': _myRole,
        'type': type,
      });

      if (response.data != null && response.data['call'] != null) {
        final callId = response.data['call']['id'];
        final callerName = _myRole == 'parent'
            ? '${widget.conversation['enseignant_prenom'] ?? ''} ${widget.conversation['enseignant_nom'] ?? 'Enseignant'}'
            : '${widget.conversation['parent_prenom'] ?? ''} ${widget.conversation['parent_nom'] ?? 'Parent'}';

        // Naviguer vers la page d'appel
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CallPage(
                callId: callId,
                callType: type,
                callerName: callerName,
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

  /// Afficher le dialog pour signaler la conversation
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
                    // Header
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
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Description
                    Text(
                      'Pourquoi signalez-vous cette conversation ?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Options de signalement
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
                                Icon(
                                  reason['icon'] as IconData,
                                  color: isSelected ? Colors.red : Colors.grey[600],
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    reason['label'] as String,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? Colors.red : Colors.black87,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check_circle, color: Colors.red),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 20),

                    // Description optionnelle
                    Text(
                      'Description (optionnel)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Décrivez la situation en détail...',
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Bouton de confirmation
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: selectedReason == null
                            ? null
                            : () async {
                                Navigator.pop(context);
                                await _submitReport(
                                  selectedReason!,
                                  descriptionController.text,
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Envoyer le signalement',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Note de confidentialité
                    Center(
                      child: Text(
                        'Votre signalement sera traité dans les plus brefs délais.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
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

  /// Soumettre le signalement
  Future<void> _submitReport(String reason, String description) async {
    if (_conversationId == null) return;

    try {
      // Déterminer l'autre partie comme étant signalée
      int? reportedId;
      String? reportedType;

      if (_myRole == 'parent') {
        reportedId = widget.conversation['enseignant_id'];
        reportedType = 'enseignant';
      } else {
        reportedId = widget.conversation['parent_id'] ?? widget.conversation['id'];
        reportedType = 'parent';
      }

      await _dio.post('/reports', data: {
        'conversation_id': _conversationId,
        'reporter_id': _myId,
        'reporter_type': _myRole,
        'reported_id': reportedId,
        'reported_type': reportedType,
        'reason': reason,
        'description': description,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Signalement envoyé avec succès'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du signalement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

