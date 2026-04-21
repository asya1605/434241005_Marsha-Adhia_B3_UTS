import '../../../ticket/data/repositories/ticket_repository.dart';
import '../../../ticket/data/models/ticket_model.dart';
class DashboardRepository {

  final TicketRepository ticketRepository = TicketRepository();

  Future<Map<String, int>> getDashboardStats() async {

    List<TicketModel> tickets = await ticketRepository.getTickets();

    int open = tickets.where((t) => t.status == "Open").length;
    int pending = tickets.where((t) => t.status == "Pending").length;
    int closed = tickets.where((t) => t.status == "Closed").length;

    return {
      "open": open,
      "pending": pending,
      "closed": closed,
      "total": tickets.length,
    };
  }

}