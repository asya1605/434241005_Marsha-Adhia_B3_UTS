import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/comment_model.dart';

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
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
  throw Exception("User not logged in");
}

    await supabase.from('comments').insert({
      'ticket_id': ticketId,
      'user_id': user.id,
      'message': message,
      'role': 'user', 
    });
  }
}