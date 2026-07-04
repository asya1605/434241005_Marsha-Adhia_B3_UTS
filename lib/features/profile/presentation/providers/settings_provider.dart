import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _ticketStatusAlerts = true;
  bool _commentAlerts = true;
  String _language = 'id'; // 'id' for Indonesian, 'en' for English
  bool _biometricsEnabled = false;

  bool get pushNotifications => _pushNotifications;
  bool get emailNotifications => _emailNotifications;
  bool get ticketStatusAlerts => _ticketStatusAlerts;
  bool get commentAlerts => _commentAlerts;
  String get language => _language;
  bool get biometricsEnabled => _biometricsEnabled;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _pushNotifications = prefs.getBool('push_notifications') ?? true;
      _emailNotifications = prefs.getBool('email_notifications') ?? true;
      _ticketStatusAlerts = prefs.getBool('ticket_status_alerts') ?? true;
      _commentAlerts = prefs.getBool('comment_alerts') ?? true;
      _language = prefs.getString('language') ?? 'id';
      _biometricsEnabled = prefs.getBool('biometrics_enabled') ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading settings: $e");
    }
  }

  Future<void> setPushNotifications(bool value) async {
    _pushNotifications = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('push_notifications', value);
    } catch (e) {
      debugPrint("Error saving push notifications setting: $e");
    }
  }

  Future<void> setEmailNotifications(bool value) async {
    _emailNotifications = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('email_notifications', value);
    } catch (e) {
      debugPrint("Error saving email notifications setting: $e");
    }
  }

  Future<void> setTicketStatusAlerts(bool value) async {
    _ticketStatusAlerts = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('ticket_status_alerts', value);
    } catch (e) {
      debugPrint("Error saving ticket status alerts setting: $e");
    }
  }

  Future<void> setCommentAlerts(bool value) async {
    _commentAlerts = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('comment_alerts', value);
    } catch (e) {
      debugPrint("Error saving comment alerts setting: $e");
    }
  }

  Future<void> setLanguage(String value) async {
    _language = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', value);
    } catch (e) {
      debugPrint("Error saving language setting: $e");
    }
  }

  Future<void> setBiometricsEnabled(bool value) async {
    _biometricsEnabled = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('biometrics_enabled', value);
    } catch (e) {
      debugPrint("Error saving biometrics setting: $e");
    }
  }
}
