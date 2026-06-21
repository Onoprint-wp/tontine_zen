class Payment {
  final String id;
  final String roundId;
  final String payerId;
  final String status; // 'pending', 'paid', 'late'
  final DateTime? confirmedAt;
  final String? confirmedBy;

  Payment({
    required this.id,
    required this.roundId,
    required this.payerId,
    required this.status,
    this.confirmedAt,
    this.confirmedBy,
  });

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] as String,
      roundId: map['round_id'] as String,
      payerId: map['payer_id'] as String,
      status: map['status'] as String? ?? 'pending',
      confirmedAt: map['confirmed_at'] != null
          ? DateTime.parse(map['confirmed_at'] as String)
          : null,
      confirmedBy: map['confirmed_by'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'round_id': roundId,
      'payer_id': payerId,
      'status': status,
      'confirmed_at': confirmedAt?.toIso8601String(),
      'confirmed_by': confirmedBy,
    };
  }
}
