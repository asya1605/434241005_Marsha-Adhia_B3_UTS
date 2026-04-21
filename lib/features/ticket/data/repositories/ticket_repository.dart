import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ticket_model.dart';
import 'dart:typed_data';

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

    ///  query berdasarkan role
    final query = (role == 'admin' || role == 'helpdesk')
        ? _supabase.from('tickets').select('*, helpdesk:user_profiles(name)')
        : _supabase.from('tickets')
            .select('*, helpdesk:user_profiles(name)')
            .eq('user_id', user.id);


    final response = await query.order('created_at', ascending: false);

    return (response as List)
        .map((e) => TicketModel.fromJson(e))
        .toList();
  }

  ///  CREATE TICKET 
  Future<void> createTicket({
    required String title,
    required String description,
    required String userId,
    String? imageUrl,
  }) async {
    try {
      await _supabase.from('tickets').insert({
        'title': title,
        'description': description,
        'status': 'Open',
        'user_id': userId,
        'image_url': imageUrl,
      });
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
      print("ROW -> id: ${row['id']}, name: ${row['name']}, role: ${row['role']}");
    }

    final helpdesk = data.where((e) {
      final role = (e['role'] ?? '').toString().toLowerCase().trim();
      return role == 'helpdesk';
    }).toList();


    return helpdesk.map((e) => {
      'id': e['id'],
      'name': e['name'],
    }).toList();
  }

  ///  ASSIGN TICKET
  Future<void> assignTicket(String ticketId, String helpdeskId) async {
    await _supabase
        .from('tickets')
        .update({'assigned_to': helpdeskId})
        .eq('id', ticketId);
  }

  ///  UPDATE STATUS
  Future<void> updateStatus(String ticketId, String status) async {
    await _supabase
        .from('tickets')
        .update({'status': status})
        .eq('id', ticketId);
  }
}
