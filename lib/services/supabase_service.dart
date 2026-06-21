import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/constants.dart';
import '../models/profile.dart';
import '../models/tontine.dart';
import '../models/membership.dart';
import '../models/payment_round.dart';
import '../models/payment.dart';
import '../models/dispute.dart';

class SupabaseService {
  static final SupabaseService instance = SupabaseService._internal();
  SupabaseService._internal();

  final SupabaseClient client = Supabase.instance.client;

  // Initialize Supabase client
  static Future<void> init() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
  }

  // --- AUTHENTICATION ---

  // Request SMS OTP code
  Future<void> signInWithPhone(String phone) async {
    await client.auth.signInWithOtp(
      phone: phone,
    );
  }

  // Verify OTP code and establish session
  Future<AuthResponse> verifyOtp(String phone, String token) async {
    final response = await client.auth.verifyOTP(
      type: OtpType.sms,
      phone: phone,
      token: token,
    );
    return response;
  }

  // Sign out user
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // Check if user is logged in
  bool get isAuthenticated => client.auth.currentSession != null;

  // Get current user ID
  String? get currentUserId => client.auth.currentUser?.id;

  // --- PROFILES ---

  // Get current user profile
  Future<Profile?> getCurrentProfile() async {
    final userId = currentUserId;
    if (userId == null) return null;

    final response = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    
    return Profile.fromMap(response);
  }

  // Get profile by ID
  Future<Profile?> getProfileById(String id) async {
    final response = await client
        .from('profiles')
        .select()
        .eq('id', id)
        .single();
    
    return Profile.fromMap(response);
  }

  // Update profile details
  Future<void> updateProfile({required String fullName, String? avatarUrl}) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Utilisateur non connecté');

    await client.from('profiles').update({
      'full_name': fullName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    }).eq('id', userId);
  }

  // --- TONTINES ---

  // List tontines where the user is a member
  Future<List<Tontine>> getMyTontines() async {
    final userId = currentUserId;
    if (userId == null) return [];

    // Query memberships first to get tontine IDs
    final List<dynamic> memberships = await client
        .from('memberships')
        .select('tontine_id')
        .eq('profile_id', userId);

    if (memberships.isEmpty) return [];

    final tontineIds = memberships.map((m) => m['tontine_id'] as String).toList();

    final List<dynamic> response = await client
        .from('tontines')
        .select()
        .inFilter('id', tontineIds);

    return response.map((data) => Tontine.fromMap(data)).toList();
  }

  // Create a new tontine and automatically become the treasurer
  Future<Tontine> createTontine({
    required String name,
    required double amount,
    required String frequency,
    required int maxMembers,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Utilisateur non connecté');

    final tontineData = await client.from('tontines').insert({
      'name': name,
      'amount': amount,
      'frequency': frequency,
      'max_members': maxMembers,
      'creator_id': userId,
      'status': 'pending_signatures',
    }).select().single();

    final tontine = Tontine.fromMap(tontineData);

    // Auto-create membership as treasurer
    await client.from('memberships').insert({
      'tontine_id': tontine.id,
      'profile_id': userId,
      'role': 'treasurer',
    });

    return tontine;
  }

  // Join an existing tontine as a member
  Future<void> joinTontine(String tontineId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Utilisateur non connecté');

    // Check if membership already exists
    final existing = await client
        .from('memberships')
        .select()
        .eq('tontine_id', tontineId)
        .eq('profile_id', userId);

    if (existing.isNotEmpty) return;

    await client.from('memberships').insert({
      'tontine_id': tontineId,
      'profile_id': userId,
      'role': 'member',
    });
  }

  // Get members of a tontine
  Future<List<Map<String, dynamic>>> getTontineMembers(String tontineId) async {
    final List<dynamic> response = await client
        .from('memberships')
        .select('role, signed_contract_at, profiles(id, full_name, phone, trust_score, avatar_url)')
        .eq('tontine_id', tontineId);

    return response.map((data) {
      final profile = data['profiles'] as Map<String, dynamic>;
      return {
        'role': data['role'],
        'signed_contract_at': data['signed_contract_at'],
        'profile': Profile.fromMap(profile),
      };
    }).toList();
  }

  // Sign the OHADA agreement contract
  Future<void> signContract(String tontineId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Utilisateur non connecté');

    await client
        .from('memberships')
        .update({'signed_contract_at': DateTime.now().toIso8601String()})
        .eq('tontine_id', tontineId)
        .eq('profile_id', userId);
  }

  // --- PAYMENT ROUNDS ---

  // Get rounds for a tontine
  Future<List<PaymentRound>> getPaymentRounds(String tontineId) async {
    final List<dynamic> response = await client
        .from('payment_rounds')
        .select()
        .eq('tontine_id', tontineId)
        .order('round_number', ascending: true);

    return response.map((data) => PaymentRound.fromMap(data)).toList();
  }

  // --- PAYMENTS ---

  // Get payments for a specific round
  Future<List<Payment>> getPaymentsForRound(String roundId) async {
    final List<dynamic> response = await client
        .from('payments')
        .select()
        .eq('round_id', roundId);

    return response.map((data) => Payment.fromMap(data)).toList();
  }

  // Treasurer confirms receipt of a manual payment (Cash / Momo)
  Future<void> confirmPayment({
    required String paymentId,
    required String status, // 'paid' or 'late'
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Utilisateur non connecté');

    await client.from('payments').update({
      'status': status,
      'confirmed_at': DateTime.now().toIso8601String(),
      'confirmed_by': userId,
    }).eq('id', paymentId);
  }

  // --- DISPUTES ---

  // File a dispute
  Future<void> reportDispute({
    required String tontineId,
    required String accusedId,
    required String description,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Utilisateur non connecté');

    await client.from('disputes').insert({
      'tontine_id': tontineId,
      'reporter_id': userId,
      'accused_id': accusedId,
      'description': description,
      'status': 'open',
    });
  }

  // Get active disputes where the user is reporter or accused
  Future<List<Dispute>> getMyDisputes() async {
    final userId = currentUserId;
    if (userId == null) return [];

    final List<dynamic> response = await client
        .from('disputes')
        .select()
        .or('reporter_id.eq.$userId,accused_id.eq.$userId')
        .order('created_at', ascending: false);

    return response.map((data) => Dispute.fromMap(data)).toList();
  }
}
