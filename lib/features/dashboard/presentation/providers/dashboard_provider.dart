import 'package:flutter/material.dart';

class DashboardProvider extends ChangeNotifier {

  int open = 0;
  int pending = 0;
  int closed = 0;
  int total = 0;

  bool isLoading = false;

  void loadDashboard(List tickets) {

    isLoading = true;

    total = tickets.length;

    open = tickets.where((t) => t.status == "Open").length;
    pending = tickets.where((t) => t.status == "Pending").length;
    closed = tickets.where((t) => t.status == "Closed").length;

    isLoading = false;

    notifyListeners();
  }

}