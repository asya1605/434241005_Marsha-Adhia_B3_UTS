import 'package:flutter/material.dart';
import '../../../ticket/data/models/ticket_model.dart';

class AdminTicketCard extends StatelessWidget {

  final TicketModel ticket;

  const AdminTicketCard({
    super.key,
    required this.ticket,
  });

  Color statusColor(String status) {

    switch (status) {
      case "Open":
        return Colors.orange;
      case "Pending":
        return Colors.blue;
      case "Closed":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),

      child: ListTile(
        title: Text(
          ticket.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        subtitle: Text(ticket.description),

        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: statusColor(ticket.status),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            ticket.status,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}