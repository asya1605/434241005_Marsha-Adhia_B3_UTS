import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {

  final NotificationRepository _repository = NotificationRepository();
  StreamSubscription<List<NotificationModel>>? _subscription;

  List<NotificationModel> notifications = [];
  List<NotificationModel> _cachedNotifications = [];
  
  List<NotificationModel> get cachedNotifications => _cachedNotifications;
  set cachedNotifications(List<NotificationModel> value) {
    _cachedNotifications = value;
    notifyListeners();
  }

  int get unreadCount => _cachedNotifications.where((n) => !n.isRead).length;

  bool isLoading = false;

  Stream<List<NotificationModel>>? notificationStream;

  Future<void> initNotifications(String userId) async {
    await _subscription?.cancel();
    final profile = await _repository.getUserProfile(userId);
    final role = profile['role'] ?? 'user';
    notificationStream = _repository.getNotifications(userId, role);
    
    _subscription = notificationStream!.listen((list) {
      _cachedNotifications = list;
      notifyListeners();
    });
    
    notifyListeners();
  }

  Future<void> loadNotifications() async {
    isLoading = true;
    notifyListeners();    
    isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    try {
      await _repository.markAsRead(id);
    } catch (e) {
      debugPrint("Error marking notification as read: $e");
    }
  }

  Future<void> markAllAsRead(List<String> ids) async {
    try {
      await _repository.markAllAsRead(ids);
    } catch (e) {
      debugPrint("Error marking all notifications as read: $e");
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _repository.deleteNotification(id);
    } catch (e) {
      debugPrint("Error deleting notification: $e");
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
