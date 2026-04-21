import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/ticket_model.dart';
import '../providers/ticket_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'ticket_detail_screen.dart';
import 'create_ticket_screen.dart';

class TicketListScreen extends StatefulWidget {
  const TicketListScreen({super.key});

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final role = context.read<AuthProvider>().role ?? "user";
      context.read<TicketProvider>().loadTickets(role: role);
    });
  }

  Widget statusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case "Open":
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFE65100);
        break;
      case "Closed":
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        break;
      case "Pending":
        bgColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1565C0);
        break;
      default:
        bgColor = const Color(0xFFF5F5F5);
        textColor = const Color(0xFF616161);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ticketProvider = context.watch<TicketProvider>();
    final authProvider = context.watch<AuthProvider>();
    final role = authProvider.role ?? "user";
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F1117) : const Color(0xFFF4F6FA),

      appBar: AppBar(
        title: const Text("Ticket List"),
      ),

      floatingActionButton: role == "user"
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateTicketScreen(),
                  ),
                );

                context.read<TicketProvider>().loadTickets(role: role);
              },
              child: const Icon(Icons.add),
            )
          : null,

      body: ticketProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ticketProvider.tickets.isEmpty
              ? const Center(child: Text("No tickets"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: ticketProvider.tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = ticketProvider.tickets[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(ticket.title),
                        subtitle: Text(ticket.description),
                        trailing: statusBadge(ticket.status),

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  TicketDetailScreen(ticket: ticket),
                            ),
                          );
                        },

                      
                        
                      ),
                    );
                  },
                ),
    );
  }
}