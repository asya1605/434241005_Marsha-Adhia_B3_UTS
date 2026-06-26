import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/comment_model.dart';
import '../../../notification/data/repositories/notification_repository.dart';

class CommentRepository {
  final supabase = Supabase.instance.client;

  // GET COMMENTS BY TICKET
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

  // ADD COMMENT
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