import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ticket_history_model.dart';

// TICKET HISTORY REPOSITORY:
// Digunakan untuk mencatat setiap log perubahan pada tiket (audit log), seperti perubahan status tiket atau pengalihan tugas staff (assignment).
class TicketHistoryRepository {
  // Instance client Supabase untuk melakukan query database
  final _supabase = Supabase.instance.client;

  // 1. FUNGSI MEMASUKKAN RIWAYAT TIKET (INSERT HISTORY):
  // Cara nembak API:
  // - Memanggil `_supabase.from('ticket_history').insert(data)` untuk menyisipkan baris log perubahan baru.
  // - Data yang disimpan berupa ticketId, aksi (CREATED, STATUS_CHANGED, ASSIGNED), status/assignedTo lama (oldValue), status/assignedTo baru (newValue), dan pengubah (changed_by).
  Future<void> insertHistory(TicketHistoryModel history) async {
    final user = _supabase.auth.currentUser;
    final data = history.toMap();
    if (history.id == null || history.id!.isEmpty) {
      data.remove('id');
    }
    
    // Selalu pastikan changed_by diisi dengan ID pengguna yang terautentikasi (jika ada)
    // agar memenuhi kebijakan Row Level Security (RLS) di Supabase.
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

  // 2. FUNGSI AMBIL RIWAYAT TIKET BERDASARKAN TIKET ID (GET HISTORY BY TICKET):
  // Cara nembak API:
  // - Memanggil `_supabase.from('ticket_history').select().eq('ticket_id', ticketId)` untuk mengambil log audit log berdasarkan id tiket.
  // - Mengurutkan log dari yang terbaru hingga terlama menggunakan `.order('created_at', ascending: false)`.
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
