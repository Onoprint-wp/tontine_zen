class Tontine {
  final String id;
  final String name;
  final double amount;
  final String frequency; // 'daily', 'weekly', 'monthly'
  final int maxMembers;
  final String status; // 'pending_signatures', 'active', 'completed'
  final String creatorId;
  final DateTime createdAt;

  Tontine({
    required this.id,
    required this.name,
    required this.amount,
    required this.frequency,
    required this.maxMembers,
    required this.status,
    required this.creatorId,
    required this.createdAt,
  });

  factory Tontine.fromMap(Map<String, dynamic> map) {
    return Tontine(
      id: map['id'] as String,
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      frequency: map['frequency'] as String? ?? 'weekly',
      maxMembers: map['max_members'] as int? ?? 10,
      status: map['status'] as String? ?? 'pending_signatures',
      creatorId: map['creator_id'] as String,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'frequency': frequency,
      'max_members': maxMembers,
      'status': status,
      'creator_id': creatorId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
