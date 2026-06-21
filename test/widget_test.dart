import 'package:flutter_test/flutter_test.dart';
import 'package:tontine_zen/models/profile.dart';
import 'package:tontine_zen/models/tontine.dart';

void main() {
  group('Tests des Modèles de Données', () {
    test('Désérialisation du modèle Profile', () {
      final Map<String, dynamic> mockJson = {
        'id': 'user-uuid-1234',
        'phone': '+237600000001',
        'full_name': 'Ariel Kamga',
        'avatar_url': 'http://image.jpg',
        'trust_score': 72,
        'created_at': '2026-06-21T12:00:00.000Z'
      };

      final profile = Profile.fromMap(mockJson);

      expect(profile.id, 'user-uuid-1234');
      expect(profile.phone, '+237600000001');
      expect(profile.fullName, 'Ariel Kamga');
      expect(profile.avatarUrl, 'http://image.jpg');
      expect(profile.trustScore, 72);
      expect(profile.createdAt.year, 2026);
    });

    test('Désérialisation du modèle Tontine', () {
      final Map<String, dynamic> mockJson = {
        'id': 'tontine-uuid-5678',
        'name': 'Mboa Epargne',
        'amount': 25000.0,
        'frequency': 'weekly',
        'max_members': 12,
        'status': 'active',
        'creator_id': 'user-uuid-1234',
        'created_at': '2026-06-21T12:00:00.000Z'
      };

      final tontine = Tontine.fromMap(mockJson);

      expect(tontine.id, 'tontine-uuid-5678');
      expect(tontine.name, 'Mboa Epargne');
      expect(tontine.amount, 25000.0);
      expect(tontine.frequency, 'weekly');
      expect(tontine.maxMembers, 12);
      expect(tontine.status, 'active');
      expect(tontine.creatorId, 'user-uuid-1234');
    });
  });
}
