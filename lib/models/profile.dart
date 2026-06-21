class Profile {
  final String id;
  final String phone;
  final String fullName;
  final String? avatarUrl;
  final int trustScore;
  final DateTime createdAt;

  Profile({
    required this.id,
    required this.phone,
    required this.fullName,
    this.avatarUrl,
    required this.trustScore,
    required this.createdAt,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      phone: map['phone'] as String,
      fullName: map['full_name'] as String? ?? 'Utilisateur anonyme',
      avatarUrl: map['avatar_url'] as String?,
      trustScore: map['trust_score'] as int? ?? 70,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'phone': phone,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'trust_score': trustScore,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
