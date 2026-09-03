import 'package:flutter/material.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';

void showMessageComposerDialog({
  required BuildContext context,
  required Function(String, String) onSend,
}) {
  showDialog(
    context: context,
    builder: (context) => _MessageComposerDialogContent(onSend: onSend),
  );
}

class _MessageComposerDialogContent extends StatefulWidget {
  final Function(String, String) onSend;

  const _MessageComposerDialogContent({required this.onSend});

  @override
  State<_MessageComposerDialogContent> createState() => _MessageComposerDialogContentState();
}

class _MessageComposerDialogContentState extends State<_MessageComposerDialogContent> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submit() async {
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();

    if (subject.isEmpty || message.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    try {
      await widget.onSend(subject, message);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message envoyé à tous les parents !'),
            backgroundColor: AppTheme.forestGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'envoi : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Envoyer un message', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.seaBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.seaBlue, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Ce message sera envoyé à tous les représentants légaux de l\'élève.',
                      style: TextStyle(fontSize: 12, color: AppTheme.textDark),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: 'Sujet',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _messageController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Votre message',
                alignLabelWithHint: true,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSending ? null : () => Navigator.pop(context),
          child: const Text('Annuler', style: TextStyle(color: AppTheme.textGrey)),
        ),
        ElevatedButton(
          onPressed: _isSending ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.seaBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: _isSending
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text('Envoyer'),
        ),
      ],
    );
  }
}
