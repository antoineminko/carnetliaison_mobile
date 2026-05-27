class Conversation {
  final int id;
  final int? ecoleId;
  final int? enseignantId;
  final int parentId;
  
  // These will be populated from the API join if needed, or we just rely on parent info
  final String? enseignantNom;
  final String? enseignantPrenom;
  final String? adminName;

  Conversation({
    required this.id,
    this.ecoleId,
    this.enseignantId,
    required this.parentId,
    this.enseignantNom,
    this.enseignantPrenom,
    this.adminName,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] ?? json['conversation_id'],
      ecoleId: json['ecole_id'],
      enseignantId: json['enseignant_id'],
      parentId: json['parent_id'] ?? 0,
      enseignantNom: json['enseignant_nom'],
      enseignantPrenom: json['enseignant_prenom'],
      adminName: json['admin_name'],
    );
  }
}
