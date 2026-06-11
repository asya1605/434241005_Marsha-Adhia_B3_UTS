import 'package:flutter/material.dart';
import '../../data/models/comment_model.dart';
import '../../data/repositories/comment_repository.dart';

class CommentProvider extends ChangeNotifier {
  final CommentRepository _repository = CommentRepository();
  
  List<Comment> comments = [];
  bool isLoading = false;

  Future<void> loadComments(String ticketId) async {
    isLoading = true;
    notifyListeners();

    try {
      comments = await _repository.getComments(ticketId);
    } catch (e) {
      debugPrint("Error loading comments: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendComment(String ticketId, String message, String role) async {
    try {
      await _repository.addComment(
        ticketId: ticketId,
        message: message,
        role: role,
      );
      // Reload comments after sending
      await loadComments(ticketId);
    } catch (e) {
      debugPrint("Error sending comment: $e");
    }
  }
}