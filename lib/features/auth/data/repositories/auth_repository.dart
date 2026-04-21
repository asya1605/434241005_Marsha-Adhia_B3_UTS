import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final _supabase = Supabase.instance.client;

  Future<AuthResponse> login(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> register(String email, String password) async {
    final res = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    print("SIGNUP USER: ${res.user}");
    print("SIGNUP SESSION: ${res.session}");

    if (res.user == null) {
      throw Exception("Register gagal: user null");
    }

    return res;
  }

  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(
      email,
    );
  }
}