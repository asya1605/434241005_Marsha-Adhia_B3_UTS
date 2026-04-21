import 'package:flutter/material.dart';
import '../../data/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  bool isLoading = false;
  bool isLoggedIn = false;

  /// USER DATA
  String? role;
  String? email;
  String? name;
  String? userId; 

  /// LOGIN
  Future<bool> login(String email, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      // Memanggil repository (sekarang return AuthResponse)
      final res = await _repository.login(email, password);

      final user = res.user;

      if (user != null) {
        ///  SIMPAN DATA USER
        this.email = email;
        userId = user.id;

        /// ROLE 
        if (email == "admin@mail.com") {
          role = "admin";
          name = "Admin";
        } else if (email == "helpdesk@mail.com") {
          role = "helpdesk";
          name = "Helpdesk";
        } else {
          role = "user";
          name = "User";
        }

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

      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      isLoading = false;
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

  /// AUTO LOGIN
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();

    isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
    role = prefs.getString("role");
    email = prefs.getString("email");
    name = prefs.getString("name");
    userId = prefs.getString("userId");

    notifyListeners();
  }

  /// LOGOUT
  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();

    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();

    isLoggedIn = false;
    role = null;
    email = null;
    name = null;
    userId = null;

    notifyListeners();
  }
}