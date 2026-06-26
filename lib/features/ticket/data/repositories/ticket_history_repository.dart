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
    if (history.changedBy == null && user != null) {
      data['changed_by'] = user.id;
    }
    await _supabase.from('ticket_history').insert(data);
  }

  Future<List<TicketHistoryModel>> getHistoryByTicket(String ticketId) async {
    final response = await _supabase
        .from('ticket_history')
        .select()
        .eq('ticket_id', ticketId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => TicketHistoryModel.fromMap(e))
        .toList();
  }
}
