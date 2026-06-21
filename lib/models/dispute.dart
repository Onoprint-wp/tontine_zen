class Dispute {
  final String id;
  final String tontineId;
  final String reporterId;
  final String accusedId;
  final String description;
  final String status; // 'open', 'under_review', 'resolved'
  final DateTime createdAt;

  Dispute({
    required this.id,
    required this.tontineId,
    required this.reporterId,
    required this.accusedId,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  factory Dispute.fromMap(Map<String, dynamic> map) {
    return Dispute(
      id: map['id'] as String,
      tontineId: map['tontine_id'] as String,
      reporterId: map['reporter_id'] as String,
      accusedId: map['accused_id'] as String,
      description: map['description'] as String? ?? '',
      status: map['status'] as String? ?? 'open',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tontine_id': tontineId,
      'reporter_id': reporterId,
      'accused_id': accusedId,
      'description': description,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
