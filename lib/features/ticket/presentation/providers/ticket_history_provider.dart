import 'package:flutter/material.dart';
import '../../data/models/ticket_history_model.dart';
import '../../data/repositories/ticket_history_repository.dart';

class TicketHistoryProvider extends ChangeNotifier {
  final TicketHistoryRepository _repository = TicketHistoryRepository();

  List<TicketHistoryModel> history = [];
  bool isLoading = false;

  Future<void> loadHistory(String ticketId) async {
    history = [];
    isLoading = true;
    notifyListeners();

    try {
      history = await _repository.getHistoryByTicket(ticketId);
      debugPrint("=== AUDIT LOG: Provider history length after loading: ${history.length} ===");
    } catch (e) {
      debugPrint("Error loading history: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addHistory({
    required String ticketId,
    required String action,
    String? oldValue,
    String? newValue,
    String? changedBy,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final item = TicketHistoryModel(
        ticketId: ticketId,
        action: action,
        oldValue: oldValue,
        newValue: newValue,
        changedBy: changedBy,
      );
      await _repository.insertHistory(item);
      history = await _repository.getHistoryByTicket(ticketId);
      debugPrint("=== AUDIT LOG: Provider history length after addHistory: ${history.length} ===");
    } catch (e) {
      debugPrint("Error adding history: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    debugPrint("=== AUDIT LOG: TicketHistoryProvider.clear() called. Previous history length: ${history.length} ===");
    history = [];
    isLoading = false;
    notifyListeners();
  }
}
