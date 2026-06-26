import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ticket_history_model.dart';

class TicketHistoryRepository {
  final _supabase = Supabase.instance.client;

  Future<void> insertHistory(TicketHistoryModel history) async {
    final user = _supabase.auth.currentUser;
    final data = history.toMap();
    if (history.id == null || history.id!.isEmpty) {
      data.remove('id');
    }
    
    // Always ensure changed_by is set to the currently authenticated user's ID
    // if available, to satisfy RLS policies checking auth.uid() = changed_by.
    if (user != null) {
      data['changed_by'] = user.id;
    } else if (history.changedBy == null) {
      data.remove('changed_by');
    }

    debugPrint("Supabase currentUser.id: ${_supabase.auth.currentUser?.id}");
    debugPrint("Supabase currentSession: ${_supabase.auth.currentSession}");
    debugPrint("history.changedBy: ${history.changedBy}");
    debugPrint("history.ticketId: ${history.ticketId}");
    debugPrint("Complete payload (data): $data");

    try {
      debugPrint("BEFORE INSERT");
      await _supabase.from('ticket_history').insert(data);
      debugPrint("AFTER INSERT");
    } catch (e, st) {
      debugPrint("INSERT FAILED");
      debugPrint(e.toString());
      debugPrintStack(stackTrace: st);
      rethrow;
    }
  }

  Future<List<TicketHistoryModel>> getHistoryByTicket(String ticketId) async {
    debugPrint("=== AUDIT LOG: TicketHistoryRepository.getHistoryByTicket called ===");
    debugPrint("=== AUDIT LOG: Ticket ID sent to repository: $ticketId ===");
    try {
      final response = await _supabase
          .from('ticket_history')
          .select()
          .eq('ticket_id', ticketId)
          .order('created_at', ascending: false);

      debugPrint("=== AUDIT LOG: Number of history records returned from DB: ${(response as List).length} ===");
      return response
          .map((e) => TicketHistoryModel.fromMap(e))
          .toList();
    } catch (e, st) {
      debugPrint("=== AUDIT LOG: Error in getHistoryByTicket: $e ===");
      debugPrintStack(stackTrace: st);
      rethrow;
    }
  }
}
