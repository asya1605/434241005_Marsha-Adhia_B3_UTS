import 'package:flutter/material.dart';
import '../../../profile/data/models/user_profile_model.dart';
import '../../../profile/data/repositories/profile_repository.dart';

class UserManagementProvider extends ChangeNotifier {
  final ProfileRepository _repository = ProfileRepository();

  List<UserProfileModel> _users = [];
  bool isLoading = false;
  String _searchQuery = '';

  List<UserProfileModel> get users => _users;
  String get searchQuery => _searchQuery;

  List<UserProfileModel> get filteredUsers {
    if (_searchQuery.isEmpty) {
      return _users;
    }
    final query = _searchQuery.toLowerCase();
    return _users.where((user) {
      final nameMatch = user.name.toLowerCase().contains(query);
      final roleMatch = user.role.toLowerCase().contains(query);
      return nameMatch || roleMatch;
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadUsers() async {
    isLoading = true;
    notifyListeners();

    try {
      final rawUsers = await _repository.getAllUserProfiles();
      
      // Sort users: Admin first, Helpdesk second, User third
      rawUsers.sort((a, b) {
        final rolePriority = {
          'admin': 1,
          'helpdesk': 2,
          'user': 3,
        };
        final pA = rolePriority[a.role.toLowerCase()] ?? 4;
        final pB = rolePriority[b.role.toLowerCase()] ?? 4;
        if (pA != pB) {
          return pA.compareTo(pB);
        }
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      _users = rawUsers;
    } catch (e) {
      debugPrint("Error loading user profiles: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateRole(String userId, String role) async {
    try {
      isLoading = true;
      notifyListeners();

      final user = _users.firstWhere((u) => u.id == userId);
      if (user.role.toLowerCase() == 'admin' && role.toLowerCase() != 'admin') {
        final activeAdmins = _users.where((u) => u.role.toLowerCase() == 'admin' && u.isActive).toList();
        if (activeAdmins.length <= 1 && activeAdmins.any((u) => u.id == userId)) {
          throw Exception("Tidak dapat mengubah peran karena user ini adalah satu-satunya Admin aktif yang tersisa.");
        }
      }

      await _repository.updateRole(userId, role);
      await loadUsers();
    } catch (e) {
      debugPrint("Error updating role: $e");
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateActiveStatus(String userId, bool isActive) async {
    try {
      isLoading = true;
      notifyListeners();

      if (!isActive) {
        final user = _users.firstWhere((u) => u.id == userId);
        if (user.role.toLowerCase() == 'admin') {
          final activeAdmins = _users.where((u) => u.role.toLowerCase() == 'admin' && u.isActive).toList();
          if (activeAdmins.length <= 1 && activeAdmins.any((u) => u.id == userId)) {
            throw Exception("Tidak dapat menonaktifkan akun karena user ini adalah satu-satunya Admin aktif yang tersisa.");
          }
        }
      }

      await _repository.updateActiveStatus(userId, isActive);
      await loadUsers();
    } catch (e) {
      debugPrint("Error updating active status: $e");
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
