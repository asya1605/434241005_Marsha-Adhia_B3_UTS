import 'package:flutter/material.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {

  final NotificationRepository _repository = NotificationRepository();

  List<NotificationModel> notifications = [];
  List<NotificationModel> cachedNotifications = [];
  bool isLoading = false;

  Stream<List<NotificationModel>>? notificationStream;

  Future<void> initNotifications(String userId) async {
    final profile = await _repository.getUserProfile(userId);
    final role = profile['role'] ?? 'user';
    notificationStream = _repository.getNotifications(userId, role);
    notifyListeners();
  }

  Future<void> loadNotifications() async {
    isLoading = true;
    notifyListeners();    
    isLoading = false;
    notifyListeners();
  }
}
