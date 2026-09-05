import 'package:flutter/material.dart';
import 'package:app_mobile/features/communication/models/message.dart';
import 'package:app_mobile/shared/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageBubble extends StatefulWidget {
  final Message message;
  final bool isMe;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
  }) : super(key: key);

  @override
  _MessageBubbleState createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _isExpanded = false;

  void _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir le lien')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: widget.isMe ? Colors.green.shade600 : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: widget.isMe ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: widget.isMe ? const Radius.circular(4) : const Radius.circular(16),
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
            if (widget.message.attachmentUrl != null)
              GestureDetector(
                onTap: () => _launchURL(widget.message.attachmentUrl!),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.attach_file, color: AppTheme.primaryBlue, size: 20),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          "Pièce jointe",
                          style: const TextStyle(
                            color: AppTheme.primaryBlue,
                            decoration: TextDecoration.underline,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Text(
              widget.message.content,
              maxLines: _isExpanded ? null : 4,
              overflow: _isExpanded ? null : TextOverflow.fade,
              style: TextStyle(
                fontSize: 15,
                color: widget.isMe ? Colors.white : AppTheme.textDark,
              ),
            ),
            if (widget.message.content.length > 200) // Rough approximation for 4 lines
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    _isExpanded ? "Voir moins" : "Lire la suite...",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: widget.isMe ? Colors.white70 : AppTheme.primaryBlue,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.message.createdAt.toString().substring(11, 16),
                    style: TextStyle(
                      fontSize: 10,
                      color: widget.isMe ? Colors.white70 : AppTheme.textGrey,
                    ),
                  ),
                  if (widget.isMe) ...[
                    const SizedBox(width: 4),
                    _buildStatusIcon(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    if (widget.message.status == 'pending') {
      return const Icon(Icons.access_time, size: 14, color: Colors.white70);
    } else if (widget.message.status == 'read') {
      return const Icon(Icons.done_all, size: 16, color: Colors.lightBlueAccent);
    } else {
      // sent / delivered
      return const Icon(Icons.check, size: 16, color: Colors.white70);
    }
  }
}
