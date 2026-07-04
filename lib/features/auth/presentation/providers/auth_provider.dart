import 'package:flutter/material.dart';
import '../../data/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  bool isLoading = false;
  bool isLoggedIn = false;
  bool isRecoveringPassword = false;

  void setRecoveringPassword(bool value) {
    isRecoveringPassword = value;
    notifyListeners();
  }
  String? loginError;

  /// USER DATA
  String? role;
  String? email;
  String? name;
  String? userId; 

  /// LOGIN
  Future<bool> login(String email, String password) async {
    try {
      isLoading = true;
      loginError = null;
      notifyListeners();

      // Memanggil repository (sekarang return AuthResponse)
      final res = await _repository.login(email, password);

      final user = res.user;

      if (user != null) {
        /// ROLE & ACTIVE STATUS
        final profile = await Supabase.instance.client
            .from('user_profiles')
            .select()
            .eq('id', user.id)
            .single();

        final isActive = profile['is_active'] as bool? ?? true;
        if (!isActive) {
          // Immediately sign out
          try {
            await Supabase.instance.client.auth.signOut();
          } catch (e) {
            debugPrint("Deactivated account sign out error: $e");
          }
          loginError = "Account has been deactivated. Please contact administrator.";
          isLoading = false;
          notifyListeners();
          return false;
        }

        ///  SIMPAN DATA USER
        this.email = email;
        userId = user.id;
        role = (profile['role'] as String?) ?? 'user';
        name = (profile['display_name'] as String?) ?? (profile['name'] as String?) ?? 'User';

        final prefs = await SharedPreferences.getInstance();

        await prefs.setBool("isLoggedIn", true);
        await prefs.setString("role", role!);
        await prefs.setString("email", this.email!);
        await prefs.setString("name", name!);
        await prefs.setString("userId", userId!); 

        isLoggedIn = true;
        isLoading = false;
        notifyListeners();

        return true;
      }

      loginError = "Login gagal";
      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      isLoading = false;
      final errorStr = e.toString();
      if (errorStr.contains("Invalid login credentials")) {
        loginError = "Email atau password salah";
      } else {
        loginError = "Login gagal: ${errorStr.replaceAll('Exception:', '').trim()}";
      }
      notifyListeners();
      debugPrint("Login error: $e");
      return false;
    }
  }

  /// REGISTER
  Future<bool> register(String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      final res = await _repository.register(email, password);

      isLoading = false;
      notifyListeners();

      return res.user != null;
    } on AuthException catch (e) {
      isLoading = false;
      notifyListeners();
      debugPrint("Auth Error register: ${e.message}");
      rethrow;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      debugPrint("Register error: $e");
      rethrow;
    }
  }

  /// RESET PASSWORD
  Future<void> resetPassword(String email) async {
    await _repository.resetPassword(email);
  }

  /// UPDATE PASSWORD
  Future<String?> updatePassword(String newPassword) async {
    try {
      isLoading = true;
      notifyListeners();

      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          password: newPassword,
        ),
      );

      isRecoveringPassword = false;
      isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return e.toString();
    }
  }

  /// AUTO LOGIN
  Future<void> checkLoginStatus() async {
    if (isRecoveringPassword) {
      isLoggedIn = false;
      notifyListeners();
      return;
    }
    final session = Supabase.instance.client.auth.currentSession;
    final prefs = await SharedPreferences.getInstance();

    if (session != null) {
      try {
        final profile = await Supabase.instance.client
            .from('user_profiles')
            .select()
            .eq('id', session.user.id)
            .single();

        final isActive = profile['is_active'] as bool? ?? true;
        if (!isActive) {
          try {
            await Supabase.instance.client.auth.signOut();
          } catch (e) {
            debugPrint("Deactivated account sign out error: $e");
          }
          await prefs.clear();
          isLoggedIn = false;
          userId = null;
          email = null;
          role = null;
          name = null;
          notifyListeners();
          return;
        }

        isLoggedIn = true;
        userId = session.user.id;
        email = session.user.email;
        role = (profile['role'] as String?) ?? 'user';
        name = (profile['display_name'] as String?) ?? (profile['name'] as String?) ?? 'User';

        await prefs.setString("role", role!);
        await prefs.setString("name", name!);
        await prefs.setString("userId", userId!);
      } catch (e) {
        debugPrint("Auto-login error loading profile: $e");
        // Fallback to local session details if database call fails
        isLoggedIn = true;
        userId = session.user.id;
        email = session.user.email;
        role = prefs.getString("role") ?? 'user';
        name = prefs.getString("name") ?? 'User';
      }
    } else {
      await prefs.clear();
      isLoggedIn = false;
      userId = null;
      email = null;
      role = null;
      name = null;
    }

    notifyListeners();
  }

  /// LOGOUT
  Future<void> logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      debugPrint("Logout sign out error: $e");
    }

    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();

    isLoggedIn = false;
    isRecoveringPassword = false;
    role = null;
    email = null;
    name = null;
    userId = null;

    notifyListeners();
  }
}