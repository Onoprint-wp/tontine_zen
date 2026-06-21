class Membership {
  final String id;
  final String tontineId;
  final String profileId;
  final String role; // 'treasurer', 'member'
  final DateTime joinedAt;
  final DateTime? signedContractAt;

  Membership({
    required this.id,
    required this.tontineId,
    required this.profileId,
    required this.role,
    required this.joinedAt,
    this.signedContractAt,
  });

  factory Membership.fromMap(Map<String, dynamic> map) {
    return Membership(
      id: map['id'] as String,
      tontineId: map['tontine_id'] as String,
      profileId: map['profile_id'] as String,
      role: map['role'] as String? ?? 'member',
      joinedAt: map['joined_at'] != null 
          ? DateTime.parse(map['joined_at'] as String) 
          : DateTime.now(),
      signedContractAt: map['signed_contract_at'] != null
          ? DateTime.parse(map['signed_contract_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tontine_id': tontineId,
      'profile_id': profileId,
      'role': role,
      'joined_at': joinedAt.toIso8601String(),
      'signed_contract_at': signedContractAt?.toIso8601String(),
    };
  }
}
