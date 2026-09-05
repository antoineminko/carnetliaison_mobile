import 'package:flutter/material.dart';
import 'package:app_mobile/shared/config/api_client.dart';

class ChatReportDialog extends StatefulWidget {
  final int? conversationId;
  final int reporterId;
  final int reportedId;

  const ChatReportDialog({
    super.key,
    required this.conversationId,
    required this.reporterId,
    required this.reportedId,
  });

  @override
  State<ChatReportDialog> createState() => _ChatReportDialogState();
}

class _ChatReportDialogState extends State<ChatReportDialog> {
  String? selectedReason;
  final descriptionController = TextEditingController();

  final List<Map<String, dynamic>> _reportReasons = [
    {'value': 'harassment', 'label': 'Harcèlement', 'icon': Icons.warning},
    {'value': 'inappropriate_content', 'label': 'Propos inappropriés', 'icon': Icons.block},
    {'value': 'spam', 'label': 'Spam', 'icon': Icons.report},
    {'value': 'fake_account', 'label': 'Faux compte', 'icon': Icons.person_off},
    {'value': 'other', 'label': 'Autre', 'icon': Icons.help_outline},
  ];

  Future<void> _submitReport() async {
    if (widget.conversationId == null) return;
    try {
      await ApiClient.instance.post('/reports', data: {
        'conversation_id': widget.conversationId,
        'reporter_id': widget.reporterId,
        'reporter_type': 'enseignant',
        'reported_id': widget.reportedId,
        'reported_type': 'parent',
        'reason': selectedReason,
        'description': descriptionController.text,
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

  @override
  Widget build(BuildContext context) {
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
                    setState(() {
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
                        await _submitReport();
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
  }
}
