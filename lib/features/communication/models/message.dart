class Message {
  final int id;
  final int conversationId;
  final String senderType;
  final int senderId;
  final String content;
  final bool isRead;
  final String status;
  final String? attachmentUrl;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderType,
    required this.senderId,
    required this.content,
    required this.isRead,
    this.status = 'sent',
    this.attachmentUrl,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? 0,
      conversationId: json['conversation_id'] ?? 0,
      senderType: json['sender_type'] ?? '',
      senderId: json['sender_id'] ?? 0,
      content: json['content'] ?? '',
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      status: json['status'] ?? ((json['is_read'] == 1 || json['is_read'] == true) ? 'read' : 'sent'),
      attachmentUrl: json['attachment_url'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }
}
