import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

// NOTIFICATION REPOSITORY:
// Tempat mengelola notifikasi pengguna secara Realtime (mengambil notifikasi secara streaming, menambah notifikasi baru, menandai notifikasi dibaca/mark as read, dan menghapusnya).
class NotificationRepository {
  // Instance client Supabase untuk melakukan operasi query ke database.
  final _supabase = Supabase.instance.client;

  // 1. FUNGSI AMBIL PROFIL USER (GET USER PROFILE):
  // Cara nembak API: Memanggil `_supabase.from('user_profiles').select().eq('id', userId).single()` untuk mengambil profil user berdasarkan ID.
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    return await _supabase
        .from('user_profiles')
        .select()
        .eq('id', userId)
        .single();
  }

  // 2. FUNGSI STREAMING NOTIFIKASI REALTIME (GET NOTIFICATIONS):
  // Cara nembak API:
  // - Memanggil `_supabase.from('notifications').stream(primaryKey: ['id'])` untuk membuka koneksi Realtime (Websocket) ke tabel `notifications`.
  // - Setiap kali ada notifikasi baru dimasukkan ke database, Supabase akan mendorong data terbaru ke aplikasi secara realtime.
  // - Kita melakukan filtering notifikasi di sisi aplikasi berdasarkan role user:
  //   * Admin: Melihat semua notifikasi yang ada.
  //   * Helpdesk: Melihat notifikasi yang ditujukan untuknya (`user_id == userId`).
  //   * User: Hanya melihat notifikasi miliknya sendiri, dan menyaring agar notifikasi bertema penugasan staff ('Ticket Assigned') tidak ditampilkan ke mereka.
  Stream<List<NotificationModel>> getNotifications(String userId, String role) {
    
    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) {

          List filtered = [];

          if (role == 'admin') {
            // admin lihat semua
            filtered = data;
          } else if (role == 'helpdesk') {
            // helpdesk melihat semua notifikasi miliknya (assigned, comment, dll)
            filtered = data.where((e) => e['user_id'] == userId).toList();
          } else {
            // user biasa tidak lihat assigned notif
            filtered = data.where((e) => 
               e['user_id'] == userId && e['title'] != 'Ticket Assigned'
            ).toList();
          }


          return filtered
              .map((map) => NotificationModel.fromMap(map))
              .toList();
        })
        .handleError((error) {
          debugPrint("REALTIME ERROR: $error");
        });
  }

  // 3. FUNGSI BUAT NOTIFIKASI BARU (INSERT NOTIFICATION):
  // Cara nembak API: Memanggil `_supabase.from('notifications').insert({...})` untuk menyisipkan baris notifikasi baru.
  Future<void> insertNotification({
    required String userId,
    required String title,
    required String message,
    String? ticketId,
  }) async {
    await _supabase.from('notifications').insert({
      'user_id': userId,
      'title': title,
      'message': message,
      'is_read': false,
      'ticket_id': ticketId,
    });
  }

  // 4. FUNGSI TANDAI NOTIFIKASI SUDAH DIBACA (MARK AS READ):
  // Cara nembak API: Memanggil `_supabase.from('notifications').update({'is_read': true}).eq('id', id)` untuk mengganti status baca notifikasi.
  Future<void> markAsRead(String id) async {
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', id);
  }

  // 5. FUNGSI TANDAI SEMUA NOTIFIKASI DIBACA (MARK ALL AS READ):
  // Cara nembak API: Memanggil `_supabase.from('notifications').update({'is_read': true}).inFilter('id', ids)` untuk memperbarui beberapa baris notifikasi sekaligus.
  Future<void> markAllAsRead(List<String> ids) async {
    if (ids.isEmpty) return;
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .inFilter('id', ids);
  }

  // 6. FUNGSI HAPUS NOTIFIKASI (DELETE NOTIFICATION):
  // Cara nembak API: Memanggil `_supabase.from('notifications').delete().eq('id', id)` untuk menghapus baris notifikasi tertentu.
  Future<void> deleteNotification(String id) async {
    await _supabase
        .from('notifications')
        .delete()
        .eq('id', id);
  }
}
