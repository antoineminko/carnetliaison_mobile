import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_mobile/features/communication/services/message_service.dart';
import 'package:app_mobile/features/communication/models/message.dart';
import 'package:app_mobile/features/auth/services/auth_service.dart';
import 'package:app_mobile/shared/config/api_client.dart';
import 'package:file_picker/file_picker.dart' as fp;

class TeacherChatViewModel extends ChangeNotifier {
  final MessageService _messageService = MessageService();
  
  List<Message> messages = [];
  bool isLoading = true;
  int? conversationId;
  String conversationStatus = 'pending';
  bool isOnline = false;
  int myId = 0;
  bool isUploading = false;
  
  Timer? _pollingTimer;
  int _lastMessageCount = 0;
  
  final Map<String, dynamic> initialConversation;
  
  TeacherChatViewModel({required this.initialConversation}) {
    conversationId = initialConversation['conversation_id'];
    _loadMessages().then((_) => startPolling());
  }
  
  bool get isReceiver {
    if (messages.isEmpty) return false;
    return messages.first.senderType != 'enseignant';
  }

  Future<void> _loadMessages() async {
    try {
      final teacherId = await AuthService.getTeacherId();
      if (teacherId == null) return;
      myId = teacherId;
      final parentId = initialConversation['parent_id'];
      final data = await _messageService.getConversation(parentId, teacherId);
      
      messages = data['messages'] ?? [];
      conversationId = data['conversation_id'];
      isOnline = data['is_online'] ?? false;
      conversationStatus = data['status'] ?? initialConversation['status'] ?? 'pending';
      _lastMessageCount = messages.length;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      notifyListeners();
      debugPrint('Error loading messages: $e');
    }
  }

  void startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (conversationId != null) {
        _pollNewMessages();
      }
    });
  }

  Future<void> _pollNewMessages() async {
    try {
      final parentId = initialConversation['parent_id'];
      final data = await _messageService.getConversation(parentId, myId);
      final newMessages = data['messages'] as List<Message>? ?? [];
      if (newMessages.length != _lastMessageCount) {
        messages = newMessages;
        _lastMessageCount = newMessages.length;
        isOnline = data['is_online'] ?? isOnline;
        if (data['status'] != null) conversationStatus = data['status'];
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error polling new messages: $e');
    }
  }

  Future<void> notifyPresence(bool online) async {
    try {
      final teacherId = await AuthService.getTeacherId();
      if (teacherId != null) {
        await ApiClient.instance.put('/users/presence', data: {'is_online': online});
      }
    } catch (e) {
      debugPrint('Error notifying presence: $e');
    }
  }

  Future<void> updateStatus(String status) async {
    if (conversationId == null) return;
    try {
      await ApiClient.instance.put(
        '/messages/conversation/$conversationId/status',
        data: {'status': status},
      );
      conversationStatus = status;
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur lors de la mise à jour: $e");
    }
  }

  Future<bool> sendMessage(String text, fp.PlatformFile? attachedFile) async {
    final teacherId = await AuthService.getTeacherId();
    if (teacherId == null) return false;
    
    isUploading = true;
    notifyListeners();
    
    final pendingId = -DateTime.now().millisecondsSinceEpoch;
    final pendingMessage = Message(
      id: pendingId,
      conversationId: conversationId ?? 0,
      senderType: 'enseignant',
      senderId: teacherId,
      content: text,
      isRead: false,
      status: 'pending',
      createdAt: DateTime.now(),
    );
    
    messages.add(pendingMessage);
    notifyListeners();

    try {
      if (conversationId == null) {
        final parentId = initialConversation['parent_id'];
        final data = await _messageService.initiateConversation(
          parentId: parentId,
          enseignantId: teacherId,
          initialMessage: text,
          subject: initialConversation['subject'] ?? 'Discussion',
        );
        conversationId = data['conversation']['id'];
        final idx = messages.indexWhere((m) => m.id == pendingId);
        if (idx != -1) messages[idx] = Message.fromJson(data['message']);
        
        isUploading = false;
        notifyListeners();
        return true;
      }
      
      final newMessage = await _messageService.sendMessage(
        conversationId: conversationId!,
        senderType: 'enseignant',
        senderId: teacherId,
        content: text,
        filePath: attachedFile?.path,
        fileName: attachedFile?.name,
      );
      
      final idx = messages.indexWhere((m) => m.id == pendingId);
      if (idx != -1) {
        messages[idx] = newMessage;
      } else {
        messages.add(newMessage);
      }
      isUploading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error sending message: $e');
      isUploading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
