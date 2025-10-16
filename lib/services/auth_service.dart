// services/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AuthService {
  final SupabaseClient _supabase = SupabaseService.client();

  Future<AuthResponse> signUp(String email, String password) async {
    final res = await _supabase.auth.signUp(email: email, password: password);
    return res;
  }

  Future<AuthResponse> signIn(String email, String password) async {
    final res = await _supabase.auth.signInWithPassword(email: email, password: password);
    return res;
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  User? get currentUser => _supabase.auth.currentUser;
}
