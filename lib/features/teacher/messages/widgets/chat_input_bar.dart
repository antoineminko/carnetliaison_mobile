import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:provider/provider.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import '../viewmodels/teacher_chat_viewmodel.dart';
import 'package:app_mobile/shared/services/connectivity_service.dart';

class ChatInputBar extends StatefulWidget {
  final VoidCallback onMessageSent;
  const ChatInputBar({super.key, required this.onMessageSent});

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _messageController = TextEditingController();
  fp.PlatformFile? _attachedFile;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _handleSend() async {
    final text = _messageController.text.trim();
    if (text.isEmpty && _attachedFile == null) return;
    
    final connectivity = Provider.of<ConnectivityService>(context, listen: false);
    if (!connectivity.isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hors ligne. Le message est en attente.')),
      );
      return;
    }

    final viewModel = context.read<TeacherChatViewModel>();
    final success = await viewModel.sendMessage(text, _attachedFile);
    if (success) {
      _messageController.clear();
      setState(() {
        _attachedFile = null;
      });
      widget.onMessageSent();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'envoi du message')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TeacherChatViewModel>();
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
                      maxLength: 500,
                      decoration: const InputDecoration(
                        hintText: 'Écrire un message...',
                        hintStyle: TextStyle(color: AppTheme.textGrey),
                        counterText: '',
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                viewModel.isUploading
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : GestureDetector(
                        onTap: _handleSend,
                        child: const CircleAvatar(
                          backgroundColor: AppTheme.seaBlue,
                          radius: 24,
                          child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
