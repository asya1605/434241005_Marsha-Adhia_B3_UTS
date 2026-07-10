import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile_model.dart';

// PROFILE REPOSITORY:
// Mengelola data profil pengguna dan status keaktifan user.
class ProfileRepository {
  // Instance client Supabase untuk melakukan query database
  final _supabase = Supabase.instance.client;

  // 1. FUNGSI AMBIL SEMUA PROFIL USER (GET ALL USER PROFILES):
  // Cara nembak API: Memanggil `_supabase.from('user_profiles').select()` untuk mengambil semua baris data dari tabel `user_profiles`.
  Future<List<UserProfileModel>> getAllUserProfiles() async {
    try {
      final response = await _supabase
          .from('user_profiles')
          .select();
      
      return (response as List)
          .map((e) => UserProfileModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // 2. FUNGSI UPDATE ROLE USER (UPDATE ROLE):
  // Cara nembak API: Memanggil `_supabase.from('user_profiles').update({'role': role}).eq('id', userId)` untuk memperbarui field role dari user terpilih.
  Future<void> updateRole(String userId, String role) async {
    try {
      await _supabase
          .from('user_profiles')
          .update({'role': role})
          .eq('id', userId);
    } catch (e) {
      rethrow;
    }
  }

  // 3. FUNGSI UPDATE STATUS KEAKTIFAN USER (UPDATE ACTIVE STATUS):
  // Cara nembak API: Memanggil `_supabase.from('user_profiles').update({'is_active': isActive}).eq('id', userId)` untuk mengganti status keaktifan user (is_active: true/false).
  Future<void> updateActiveStatus(String userId, bool isActive) async {
    try {
      await _supabase
          .from('user_profiles')
          .update({'is_active': isActive})
          .eq('id', userId);
    } catch (e) {
      rethrow;
    }
  }
}
