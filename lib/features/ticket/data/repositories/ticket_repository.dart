import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/ticket_model.dart';
import '../models/ticket_history_model.dart';
import './ticket_history_repository.dart';
import '../../../notification/data/repositories/notification_repository.dart';

class TicketRepository {
  final _supabase = Supabase.instance.client;

  ///  GET TICKETS 
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

  ///  CREATE TICKET 
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



  Future<String?> uploadImageBytes(Uint8List bytes) async {
    try {
      final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
      final path = "tickets/$fileName";

      // upload ke Supabase
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

  /// DELETE TICKET
  Future<void> deleteTicket(String id) async {
    await _supabase.from('tickets').delete().eq('id', id);
  }


  /// GET HELPDESK USERS
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
      return role == 'helpdesk';
    }).toList();

    return helpdesk.map((e) {
      final name = (e['display_name'] ?? e['name'] ?? e['email'] ?? 'Helpdesk').toString();
      return {
        'id': e['id'],
        'name': name,
      };
    }).toList();
  }

  ///  ASSIGN TICKET
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

  ///  UPDATE STATUS
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

  /// GET TICKET BY ID
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
