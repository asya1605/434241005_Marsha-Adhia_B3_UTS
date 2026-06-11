import 'package:flutter/material.dart';
import '../../data/repositories/ticket_repository.dart';
import '../../data/models/ticket_model.dart';

import 'dart:typed_data';

class TicketProvider extends ChangeNotifier {
  final TicketRepository _repository = TicketRepository();

  List<TicketModel> tickets = [];

  bool isLoading = false;

  /// simpan role terakhir
  String currentRole = "user";

  /// LOAD TICKETS
  Future<void> loadTickets({String role = "user"}) async {
    currentRole = role;

    isLoading = true;
    notifyListeners();

    final allTickets = await _repository.getTickets();

    /// belum pakai user_email dinamis dari Supabase
    tickets = allTickets;

    isLoading = false;
    notifyListeners();
  }

  /// CREATE TICKET
  Future<void> createTicket(TicketModel ticket, {String? imageUrl}) async {
    isLoading = true;
    notifyListeners();

    await _repository.createTicket(
      title: ticket.title,
      description: ticket.description,
      userId: ticket.userId,
      imageUrl: imageUrl,
    );


    /// reload dari database
    await loadTickets(role: currentRole);
  }



  Future<String?> uploadImageBytes(Uint8List bytes) async {
    return await _repository.uploadImageBytes(bytes);
  }

  /// DELETE TICKET
  Future<void> deleteTicket(String id) async {
    isLoading = true;
    notifyListeners();

    await _repository.deleteTicket(id);

    await loadTickets(role: currentRole);
  }

  /// GET TICKET BY ID
  Future<TicketModel?> getTicketById(String id) async {
    return await _repository.getTicketById(id);
  }
}