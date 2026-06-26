import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile_model.dart';

class ProfileRepository {
  final _supabase = Supabase.instance.client;

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
