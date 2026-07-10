import 'package:supabase_flutter/supabase_flutter.dart';

// AUTH REPOSITORY:
// Tempat untuk mengelola proses autentikasi (Login, Register, Reset Password) ke API Supabase Auth.
class AuthRepository {
  // Mengambil instance client dari Supabase untuk melakukan request (nembak API).
  final _supabase = Supabase.instance.client;

  // 1. FUNGSI LOGIN:
  // Cara nembak API: Memanggil `_supabase.auth.signInWithPassword` dengan parameter email & password.
  // Supabase akan memverifikasi kredensial user dan mengembalikan data user beserta session token jika berhasil.
  Future<AuthResponse> login(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // 2. FUNGSI REGISTER:
  // Cara nembak API: Memanggil `_supabase.auth.signUp` untuk mendaftarkan user baru dengan email & password.
  // Juga mengirim metadata tambahan seperti nama user melalui field `data`.
  Future<AuthResponse> register(String email, String password, String name) async {
    final res = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'display_name': name,
        'name': name,
      },
    );

    print("SIGNUP USER: ${res.user}");
    print("SIGNUP SESSION: ${res.session}");

    if (res.user == null) {
      throw Exception("Register gagal: user null");
    }

    return res;
  }

  // 3. FUNGSI RESET PASSWORD:
  // Cara nembak API: Memanggil `_supabase.auth.resetPasswordForEmail` untuk mengirimkan email link reset password.
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(
      email,
    );
  }
}