import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/dashboard_widgets.dart';
import '../widgets/dashboard_shimmer.dart';
import '../../../ticket/presentation/providers/ticket_provider.dart';
import '../../../ticket/presentation/pages/ticket_detail_screen.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notification/presentation/providers/notification_provider.dart';
import '../../../notification/presentation/pages/notification_screen.dart';

class HelpdeskDashboard extends StatefulWidget {
  const HelpdeskDashboard({super.key});

  @override
  State<HelpdeskDashboard> createState() => _HelpdeskDashboardState();
}

class _HelpdeskDashboardState extends State<HelpdeskDashboard> {
  String _activeTab = 'Open';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<TicketProvider>().loadTickets(role: 'helpdesk');
      }
    });
  }

  Future<void> _onRefresh() async {
    await context.read<TicketProvider>().loadTickets(role: 'helpdesk');
  }

  @override
  Widget build(BuildContext context) {
    final ticketProvider = context.watch<TicketProvider>();
    final authProvider = context.watch<AuthProvider>();
    final notificationProvider = context.watch<NotificationProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final name = authProvider.name ?? 'Helpdesk';
    final agentId = authProvider.userId;
    const currentRole = 'helpdesk';

    // Filter tickets assigned to current helpdesk agent dynamically
    final myAssignedTickets = ticketProvider.tickets
        .where((t) => t.assignedTo == agentId)
        .toList();

    // Filter by the selected status tab category
    final filteredTickets = myAssignedTickets.where((t) {
      final s = t.status.toLowerCase();
      if (_activeTab == 'Open') return s == 'open';
      if (_activeTab == 'Assign') return s == 'assign';
      if (_activeTab == 'On Progress') {
        return ['process', 'pending', 'in_progress', 'diproses', 'on progress', 'on_progress', 'in progress'].contains(s);
      }
      if (_activeTab == 'Closed') {
        return ['closed', 'done', 'resolved', 'close'].contains(s);
      }
      return true;
    }).toList();

    final hasUnreadNotif = notificationProvider.cachedNotifications.any((n) => !n.isRead);

    return Scaffold(
      body: ticketProvider.isInitialLoading
          ? const DashboardShimmer(showCreateCta: false)
          : RefreshIndicator(
              color: Theme.of(context).colorScheme.primary,
              onRefresh: _onRefresh,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    ModernDashboardHeader(
                      name: name,
                      subtitle: 'Ready to help today?',
                      onNotificationTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationScreen(),
                          ),
                        ).then((_) => _onRefresh());
                      },
                      hasUnreadNotifications: hasUnreadNotif,
                    ),

                    // AI Banner
                    const AiAssistantBanner(),

                    // Horizontal Filter Tabs
                    StatusFilterTabs(
                      activeTab: _activeTab,
                      onTabChanged: (tab) {
                        setState(() {
                          _activeTab = tab;
                        });
                      },
                    ),
                    const SizedBox(height: 8),

                    // Tickets List
                    Expanded(
                      child: filteredTickets.isEmpty
                          ? ListView(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                              children: [
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.inbox_outlined,
                                        size: 48,
                                        color: isDark ? Colors.white30 : Colors.black26,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Tidak ada tiket $_activeTab',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? Colors.white54 : Colors.black45,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              itemCount: filteredTickets.length,
                              itemBuilder: (context, index) {
                                final t = filteredTickets[index];
                                return ModernTicketCard(
                                  ticket: t,
                                  role: currentRole,
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TicketDetailScreen(ticket: t),
                                      ),
                                    );
                                    if (!mounted) return;
                                    context.read<TicketProvider>().loadTickets(role: currentRole);
                                  },
                                  onActionTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TicketDetailScreen(ticket: t),
                                      ),
                                    );
                                    if (!mounted) return;
                                    context.read<TicketProvider>().loadTickets(role: currentRole);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
