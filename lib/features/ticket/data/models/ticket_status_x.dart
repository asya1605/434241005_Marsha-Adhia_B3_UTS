import 'ticket_model.dart';

extension TicketStatusX on TicketModel {
  String get statusCategory {
    final s = status.toLowerCase();
    if (s == 'open') return 'open';
    if (['process', 'pending', 'in_progress', 'diproses'].contains(s)) return 'inProgress';
    if (['closed', 'done', 'resolved'].contains(s)) return 'closed';
    return 'other';
  }
}
