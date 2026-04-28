// lib/core/services/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  Stream<AuthState> get authStateChanges =>
      _supabase.auth.onAuthStateChange;

  Future<ProfileModel> login(String email, String password) async {
    final res = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (res.user == null) throw Exception('Login gagal');
    return await getProfile(res.user!.id);
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? unitName,
  }) async {
    await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': role,
        'unit_name': unitName,
      },
    );
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  Future<ProfileModel> getProfile(String userId) async {
    final data = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return ProfileModel.fromMap(data);
  }

  Future<ProfileModel?> getCurrentProfile() async {
    if (currentUser == null) return null;
    return await getProfile(currentUser!.id);
  }
}
