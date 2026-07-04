import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/dashboard_widgets.dart';
import '../widgets/dashboard_shimmer.dart';
import '../../../ticket/presentation/providers/ticket_provider.dart';
import '../../../ticket/presentation/pages/ticket_detail_screen.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  String _activeTab = 'Open';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) setState(() {});
    });
    Future.microtask(() {
      if (mounted) {
        context.read<TicketProvider>().loadTickets(role: 'user');
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await context.read<TicketProvider>().loadTickets(role: 'user');
  }

  @override
  Widget build(BuildContext context) {
    final ticketProvider = context.watch<TicketProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final name = authProvider.name ?? 'User';
    final myTickets = ticketProvider.tickets;
    const currentRole = 'user';

    // Filter by selected status tab, search query, and category
    final filteredTickets = myTickets.where((t) {
      // 1. Status Filter
      final s = t.status.toLowerCase();
      bool statusMatch = false;
      if (_activeTab == 'Open') {
        statusMatch = s == 'open';
      } else if (_activeTab == 'Assign') {
        statusMatch = s == 'assign';
      } else if (_activeTab == 'On Progress') {
        statusMatch = ['process', 'pending', 'in_progress', 'diproses', 'on progress', 'on_progress', 'in progress'].contains(s);
      } else if (_activeTab == 'Closed') {
        statusMatch = ['closed', 'done', 'resolved', 'close'].contains(s);
      } else {
        statusMatch = true;
      }

      // 2. Search Filter
      final searchMatch = _searchController.text.isEmpty ||
          t.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          t.id.toLowerCase().contains(_searchController.text.toLowerCase());

      return statusMatch && searchMatch;
    }).toList();

    return Scaffold(
      body: ticketProvider.isInitialLoading
          ? const DashboardShimmer(showCreateCta: true)
          : RefreshIndicator(
              color: Theme.of(context).colorScheme.primary,
              onRefresh: _onRefresh,
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Redesigned Wave Curved Header with Search
                    WaveDashboardHeader(
                      name: name,
                      subtitle: authProvider.email ?? 'Client User',
                      searchController: _searchController,
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Redesigned AI Banner with dots
                            const AiAssistantBanner(),

                            const SizedBox(height: 12),

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
                            filteredTickets.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                                    child: Center(
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
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
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
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
