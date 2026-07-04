import 'ticket_model.dart';

extension TicketStatusX on TicketModel {
  String get statusCategory {
    final s = status.toLowerCase();
    if (['open', 'assign'].contains(s)) return 'open';
    if (['process', 'pending', 'in_progress', 'diproses', 'on progress', 'on_progress', 'in progress'].contains(s)) return 'inProgress';
    if (['closed', 'done', 'resolved', 'close'].contains(s)) return 'closed';
    return 'other';
  }
}
