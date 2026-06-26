import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/models/notification_model.dart';
import '../widgets/in_app_notification_toast.dart';

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
  bool hasInitialData = false;

  Stream<List<NotificationModel>>? notificationStream;

  Future<void> initNotifications(String userId) async {
    hasInitialData = false;
    await _subscription?.cancel();
    final profile = await _repository.getUserProfile(userId);
    final role = profile['role'] ?? 'user';
    notificationStream = _repository.getNotifications(userId, role);
    
    _subscription = notificationStream!.listen((list) {
      if (hasInitialData) {
        final oldIds = _cachedNotifications.map((n) => n.id).toSet();
        final newUnread = list.where((n) => !oldIds.contains(n.id) && !n.isRead).toList();
        for (final notif in newUnread) {
          InAppNotificationToast.show(
            title: notif.title,
            message: notif.message,
            ticketId: notif.ticketId,
          );
        }
      }
      _cachedNotifications = list;
      hasInitialData = true;
      notifyListeners();
    });
    
    notifyListeners();
  }

  void clear() {
    _subscription?.cancel();
    _subscription = null;
    notificationStream = null;
    notifications = [];
    _cachedNotifications = [];
    hasInitialData = false;
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
      // Optimistic update
      final index = _cachedNotifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        final old = _cachedNotifications[index];
        _cachedNotifications[index] = NotificationModel(
          id: old.id,
          userId: old.userId,
          title: old.title,
          message: old.message,
          isRead: true,
          createdAt: old.createdAt,
          ticketId: old.ticketId,
        );
        notifyListeners();
      }
      await _repository.markAsRead(id);
    } catch (e) {
      debugPrint("Error marking notification as read: $e");
    }
  }

  Future<void> markAllAsRead(List<String> ids) async {
    try {
      // Optimistic update
      bool updated = false;
      for (var i = 0; i < _cachedNotifications.length; i++) {
        if (ids.contains(_cachedNotifications[i].id)) {
          final old = _cachedNotifications[i];
          _cachedNotifications[i] = NotificationModel(
            id: old.id,
            userId: old.userId,
            title: old.title,
            message: old.message,
            isRead: true,
            createdAt: old.createdAt,
            ticketId: old.ticketId,
          );
          updated = true;
        }
      }
      if (updated) {
        notifyListeners();
      }
      await _repository.markAllAsRead(ids);
    } catch (e) {
      debugPrint("Error marking all notifications as read: $e");
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      // Optimistic update
      _cachedNotifications.removeWhere((n) => n.id == id);
      notifyListeners();
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
