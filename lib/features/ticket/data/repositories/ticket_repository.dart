import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/ticket_model.dart';
import '../models/ticket_history_model.dart';
import './ticket_history_repository.dart';
import '../../../notification/data/repositories/notification_repository.dart';

// TICKET REPOSITORY:
// Tempat mengelola data Tiket (ambil data, buat tiket baru, upload gambar, ganti status, assign staf, hapus tiket) ke database Supabase.
class TicketRepository {
  // Instance client Supabase untuk melakukan operasi query ke database (tabel-tabel di Supabase).
  final _supabase = Supabase.instance.client;

  // 1. FUNGSI AMBIL TIKET (GET TICKETS):
  // Cara nembak API:
  // - Mengambil data user yang sedang login dari local session auth.
  // - Nembak ke tabel `user_profiles` menggunakan `.select('role').eq('id', user.id)` untuk mengecek role user (admin, helpdesk, atau user biasa).
  // - Jika Admin / Helpdesk: Nembak ke tabel `tickets` mengambil semua baris tiket.
  // - Jika User biasa: Nembak ke tabel `tickets` dan memfilter dengan `.eq('user_id', user.id)` agar hanya tiket miliknya yang diambil.
  // - Melakukan join tabel secara otomatis dengan tabel `user_profiles` (assigned_to) untuk menampilkan nama staff helpdesk yang menangani tiket tersebut.
  // - Mengurutkan dengan `.order('created_at', ascending: false)` agar tiket terbaru muncul paling atas.
  Future<List<TicketModel>> getTickets() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    /// ambil role dari DB
    final profile = await _supabase
        .from('user_profiles')
        .select('role')
        .eq('id', user.id)
        .single();

    final role = profile['role'];

    final query = (role == 'admin' || role == 'helpdesk')
        ? _supabase.from('tickets').select('*, helpdesk:user_profiles!assigned_to(display_name)')
        : _supabase.from('tickets')
            .select('*, helpdesk:user_profiles!assigned_to(display_name)')
            .eq('user_id', user.id);


    final response = await query.order('created_at', ascending: false);
    final listResponse = response as List;

    if (listResponse.isEmpty) return [];

    // Fetch creator names map
    final creatorIds = listResponse
        .map((e) => e['user_id']?.toString())
        .whereType<String>()
        .where((id) => id.trim().isNotEmpty)
        .toSet()
        .toList();
    Map<String, String> userNames = {};
    if (creatorIds.isNotEmpty) {
      try {
        final usersResponse = await _supabase
            .from('user_profiles')
            .select('id, display_name')
            .inFilter('id', creatorIds);
        
        for (var row in usersResponse as List) {
          final id = row['id']?.toString();
          final name = (row['display_name'] ?? row['name'])?.toString();
          if (id != null && name != null) {
            userNames[id] = name;
          }
        }
      } catch (e) {
        debugPrint("Failed to fetch creator names: $e");
      }
    }

    return listResponse.map((e) {
      final ticket = TicketModel.fromJson(e);
      final creatorId = e['user_id']?.toString();
      if (creatorId != null && userNames.containsKey(creatorId)) {
        return ticket.copyWith(creatorName: userNames[creatorId]);
      }
      return ticket;
    }).toList();
  }

  // 2. FUNGSI BUAT TIKET BARU (CREATE TICKET):
  // Cara nembak API:
  // - Memanggil `_supabase.from('tickets').insert({...})` dengan mengirim payload berupa Map JSON (title, description, category, priority, status 'Open', dll).
  // - Menambahkan history/log baru ke tabel `ticket_history` bahwa tiket telah dibuat.
  // - Mencari admin-admin aktif lewat tabel `user_profiles` dengan filter `.eq('role', 'admin').eq('is_active', true)`.
  // - Mengirim notifikasi baru ke tabel `notifications` untuk setiap admin agar admin tahu ada tiket baru masuk.
  Future<void> createTicket({
    required String title,
    required String description,
    required String userId,
    required String category,
    required String priority,
    String? imageUrl,
  }) async {
    try {
      final response = await _supabase.from('tickets').insert({
        'title': title,
        'description': description,
        'category': category,
        'priority': priority,
        'status': 'Open',
        'user_id': userId,
        'image_url': imageUrl,
      }).select().single();

      final ticketId = response['id']?.toString();
      if (ticketId != null) {
        final historyRepo = TicketHistoryRepository();
        await historyRepo.insertHistory(TicketHistoryModel(
          ticketId: ticketId,
          action: 'CREATED',
          oldValue: null,
          newValue: 'Open',
          changedBy: userId,
        ));

        // Create notification for active Admins
        try {
          final adminsResponse = await _supabase
              .from('user_profiles')
              .select('id')
              .eq('role', 'admin')
              .eq('is_active', true);
          
          final List admins = adminsResponse as List;
          final notifRepo = NotificationRepository();
          for (var admin in admins) {
            final adminId = admin['id']?.toString();
            if (adminId != null) {
              await notifRepo.insertNotification(
                userId: adminId,
                title: 'Ticket Created',
                message: 'Ticket baru telah dibuat oleh pengguna.',
                ticketId: ticketId,
              );
            }
          }
        } catch (e) {
          debugPrint("Failed to create admin notifications: $e");
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // 3. FUNGSI UPLOAD GAMBAR LAMPIRAN (UPLOAD IMAGE):
  // Cara nembak API:
  // - Menyimpan gambar ke Supabase Storage (Bucket khusus bernama 'ticket-files').
  // - Memanggil `_supabase.storage.from('ticket-files').uploadBinary(path, bytes)` untuk mengirim file dalam bentuk binary bytes.
  // - Setelah berhasil ter-upload, kita meminta URL publik gambar tersebut menggunakan `.getPublicUrl(path)` untuk disimpan ke field `image_url` di tabel `tickets`.
  Future<String?> uploadImageBytes(Uint8List bytes) async {
    try {
      final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
      final path = "tickets/$fileName";

      // upload ke Supabase Storage
      await _supabase.storage
          .from('ticket-files')
          .uploadBinary(path, bytes);

      // ambil URL PUBLIC
      final publicUrl = _supabase.storage
          .from('ticket-files')
          .getPublicUrl(path);


      return publicUrl;
    } catch (e) {
      return null;
    }
  }

  // 4. FUNGSI HAPUS TIKET (DELETE TICKET):
  // Cara nembak API: Memanggil `_supabase.from('tickets').delete().eq('id', id)` untuk menghapus baris data tiket dengan id tertentu.
  Future<void> deleteTicket(String id) async {
    await _supabase.from('tickets').delete().eq('id', id);
  }

  // 5. FUNGSI AMBIL USER HELPDESK & ADMIN (GET HELPDESK USERS):
  // Cara nembak API:
  // - Mengambil semua profil user dari tabel `user_profiles` dengan limit 100.
  // - Menyaring (filtering) di sisi aplikasi untuk mengambil user yang memiliki `role` 'helpdesk' atau 'admin' guna kebutuhan assign (penugasan) tiket.
  Future<List<Map<String, dynamic>>> getHelpdeskUsers() async {
    final response = await _supabase
        .from('user_profiles')
        .select('*')
        .limit(100);

    final List data = response as List;

    for (var row in data) {
      final displayName = row['display_name'] ?? row['name'] ?? row['email'] ?? 'Helpdesk';
      print("ROW -> id: ${row['id']}, name: $displayName, role: ${row['role']}");
    }

    final helpdesk = data.where((e) {
      final role = (e['role'] ?? '').toString().toLowerCase().trim();
      return role == 'helpdesk' || role == 'admin';
    }).toList();

    return helpdesk.map((e) {
      final name = (e['display_name'] ?? e['name'] ?? e['email'] ?? 'Helpdesk').toString();
      return {
        'id': e['id'],
        'name': name,
      };
    }).toList();
  }

  // 6. FUNGSI TUGASKAN TIKET (ASSIGN TICKET):
  // Cara nembak API:
  // - Memanggil `_supabase.from('tickets').update({'assigned_to': helpdeskId}).eq('id', ticketId)` untuk mengganti staff helpdesk yang ditugaskan menangani tiket ini.
  // - Menyimpan riwayat perubahan status penugasan ke tabel `ticket_history` menggunakan TicketHistoryRepository.
  Future<void> assignTicket(String ticketId, String? helpdeskId) async {
    try {
      final currentTicket = await getTicketById(ticketId);
      final previousAssignedTo = currentTicket?.assignedTo;

      await _supabase
          .from('tickets')
          .update({'assigned_to': helpdeskId})
          .eq('id', ticketId);

      final historyRepo = TicketHistoryRepository();
      await historyRepo.insertHistory(TicketHistoryModel(
        ticketId: ticketId,
        action: 'ASSIGNED',
        oldValue: previousAssignedTo,
        newValue: helpdeskId,
      ));


    } catch (e) {
      rethrow;
    }
  }

  // 7. FUNGSI UPDATE STATUS TIKET (UPDATE STATUS):
  // Cara nembak API:
  // - Memanggil `_supabase.from('tickets').update({'status': status}).eq('id', ticketId)` untuk memperbarui status tiket (misal: dari Open -> Pending -> Closed).
  // - Menambahkan catatan di tabel `ticket_history` bahwa status telah diubah.
  // - Mengirim notifikasi otomatis ke user pembuat tiket (`user_id`) melalui tabel `notifications` untuk memberi tahu bahwa status tiket mereka berubah.
  Future<void> updateStatus(String ticketId, String status) async {
    try {
      final currentTicket = await getTicketById(ticketId);
      final oldStatus = currentTicket?.status;

      await _supabase
          .from('tickets')
          .update({'status': status})
          .eq('id', ticketId);

      final historyRepo = TicketHistoryRepository();
      await historyRepo.insertHistory(TicketHistoryModel(
        ticketId: ticketId,
        action: 'STATUS_CHANGED',
        oldValue: oldStatus,
        newValue: status,
      ));



      if (currentTicket != null) {
        try {
          final notifRepo = NotificationRepository();
          await notifRepo.insertNotification(
            userId: currentTicket.userId,
            title: 'Status Updated',
            message: 'Status ticket Anda berubah menjadi $status.',
            ticketId: ticketId,
          );
        } catch (e) {
          debugPrint("Failed to create status change notification: $e");
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // 8. FUNGSI DETAIL TIKET BERDASARKAN ID (GET TICKET BY ID):
  // Cara nembak API:
  // - Memanggil `_supabase.from('tickets').select('*, ...').eq('id', ticketId).maybeSingle()` untuk mendapatkan satu baris data tiket spesifik.
  // - Melakukan query tambahan ke tabel `user_profiles` untuk menampilkan nama pembuat tiket (`creatorName`).
  Future<TicketModel?> getTicketById(String ticketId) async {
    try {
      final response = await _supabase
          .from('tickets')
          .select('*, helpdesk:user_profiles!assigned_to(display_name)')
          .eq('id', ticketId)
          .maybeSingle();
      if (response == null) return null;

      final ticket = TicketModel.fromJson(response);
      final creatorId = response['user_id']?.toString();
      if (creatorId != null) {
        try {
          final userProfile = await _supabase
              .from('user_profiles')
              .select('display_name')
              .eq('id', creatorId)
              .maybeSingle();
          if (userProfile != null) {
            return ticket.copyWith(creatorName: (userProfile['display_name'] ?? userProfile['name'])?.toString());
          }
        } catch (e) {
          debugPrint("Failed to fetch creator name for single ticket: $e");
        }
      }
      return ticket;
    } catch (e) {
      return null;
    }
  }
}
