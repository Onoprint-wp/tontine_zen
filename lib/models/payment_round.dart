class PaymentRound {
  final String id;
  final String tontineId;
  final int roundNumber;
  final String beneficiaryId;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'open', 'closed'

  PaymentRound({
    required this.id,
    required this.tontineId,
    required this.roundNumber,
    required this.beneficiaryId,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory PaymentRound.fromMap(Map<String, dynamic> map) {
    return PaymentRound(
      id: map['id'] as String,
      tontineId: map['tontine_id'] as String,
      roundNumber: map['round_number'] as int? ?? 1,
      beneficiaryId: map['beneficiary_id'] as String,
      startDate: map['start_date'] != null
          ? DateTime.parse(map['start_date'] as String)
          : DateTime.now(),
      endDate: map['end_date'] != null
          ? DateTime.parse(map['end_date'] as String)
          : DateTime.now().add(const Duration(days: 7)),
      status: map['status'] as String? ?? 'open',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tontine_id': tontineId,
      'round_number': roundNumber,
      'beneficiary_id': beneficiaryId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': status,
    };
  }
}
