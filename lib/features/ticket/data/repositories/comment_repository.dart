import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/comment_model.dart';
import '../../../notification/data/repositories/notification_repository.dart';

// COMMENT REPOSITORY:
// Mengelola percakapan/komentar di dalam detail tiket (membaca komentar dan menambahkan komentar baru).
class CommentRepository {
  // Mengambil instance client dari Supabase untuk melakukan query database.
  final supabase = Supabase.instance.client;

  // 1. FUNGSI AMBIL KOMENTAR (GET COMMENTS BY TICKET):
  // Cara nembak API:
  // - Memanggil `supabase.from('comments').select().eq('ticket_id', ticketId)` untuk mengambil semua baris komentar yang berasosiasi dengan id tiket ini.
  // - Mengurutkan komentar dari yang terlama ke terbaru dengan `.order('created_at', ascending: true)`.
  Future<List<Comment>> getComments(String ticketId) async {
    final response = await supabase
        .from('comments')
        .select()
        .eq('ticket_id', ticketId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((e) => Comment.fromJson(e))
        .toList();
  }

  // 2. FUNGSI TAMBAH KOMENTAR BARU (ADD COMMENT):
  // Cara nembak API:
  // - Mengambil user ID saat ini dari Auth session.
  // - Memasukkan data komentar baru (ticket_id, user_id, message, role) ke tabel `comments` menggunakan `.insert({...})`.
  // - Opsional: Mengambil detail tiket untuk mengetahui siapa pembuat tiket (`user_id`) dan siapa yang ditugaskan (`assigned_to`).
  // - Jika pengirim adalah user biasa, maka sistem akan mengirim notifikasi baru ke staf yang ditugaskan (assignedTo) melalui tabel `notifications`.
  // - Jika pengirim adalah staf helpdesk/admin, maka sistem akan mengirim notifikasi baru ke user pembuat tiket (ownerId) melalui tabel `notifications`.
  Future<void> addComment({
    required String ticketId,
    required String message,
    required String role,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    await supabase.from('comments').insert({
      'ticket_id': ticketId,
      'user_id': user.id,
      'message': message,
      'role': role, 
    });

    // Send notifications to the opposite participant
    try {
      final ticketResponse = await supabase
          .from('tickets')
          .select('user_id, assigned_to')
          .eq('id', ticketId)
          .single();
      
      final ownerId = ticketResponse['user_id']?.toString();
      final assignedTo = ticketResponse['assigned_to']?.toString();

      final notifRepo = NotificationRepository();
      if (role == 'user') {
        if (assignedTo != null && assignedTo.isNotEmpty) {
          await notifRepo.insertNotification(
            userId: assignedTo,
            title: 'New Comment',
            message: 'Ada komentar baru dari pengguna pada tiket.',
            ticketId: ticketId,
          );
        }
      } else {
        if (ownerId != null && ownerId.isNotEmpty) {
          await notifRepo.insertNotification(
            userId: ownerId,
            title: 'New Comment',
            message: 'Ada komentar baru dari staff pada tiket Anda.',
            ticketId: ticketId,
          );
        }
      }
    } catch (e) {
      debugPrint("Failed to create comment notification: $e");
    }
  }
}