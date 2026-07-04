import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/dashboard_widgets.dart';
import '../widgets/dashboard_shimmer.dart';
import '../../../ticket/data/models/ticket_model.dart';
import '../../../ticket/presentation/providers/ticket_provider.dart';
import '../../../ticket/presentation/pages/my_tickets_page.dart';
import '../../../ticket/presentation/pages/ticket_detail_screen.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notification/data/models/notification_model.dart';
import '../../../notification/presentation/providers/notification_provider.dart';
import '../../../notification/presentation/pages/notification_screen.dart';
import '../../../admin/presentation/pages/user_management_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String _activeTab = 'Open';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<TicketProvider>().loadTickets(role: 'admin');
      }
    });
  }

  Future<void> _onRefresh() async {
    if (!mounted) return;
    await context.read<TicketProvider>().loadTickets(role: 'admin');
  }

  @override
  Widget build(BuildContext context) {
    final ticketProvider = context.watch<TicketProvider>();
    final authProvider = context.watch<AuthProvider>();
    final notificationProvider = context.watch<NotificationProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final name = authProvider.name ?? 'Admin';
    final allTickets = ticketProvider.tickets;
    const currentRole = 'admin';

    // Filter by the selected status tab category
    final filteredTickets = allTickets.where((t) {
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

    // Filter critical tickets: priority is high/urgent and status is not closed/resolved
    final criticalTickets = allTickets.where((t) {
      final p = t.priority.toLowerCase();
      final s = t.status.toLowerCase();
      final isCritical = p == 'high' || p == 'urgent' || p == 'kritis' || p == 'darurat';
      final isResolved = ['closed', 'done', 'resolved', 'close'].contains(s);
      return isCritical && !isResolved;
    }).toList();

    final hasUnreadNotif = notificationProvider.cachedNotifications.any((n) => !n.isRead);

    return Scaffold(
      body: ticketProvider.isInitialLoading
          ? const DashboardShimmer(showCreateCta: false)
          : RefreshIndicator(
              color: Theme.of(context).colorScheme.primary,
              onRefresh: _onRefresh,
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      ModernDashboardHeader(
                        name: name,
                        subtitle: 'System status is stable today',
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

                      // Critical alert banner if there are high priority unresolved tickets
                      if (criticalTickets.isNotEmpty)
                        _buildCriticalAlertBanner(context, criticalTickets),

                      // AI Banner
                      const AiAssistantBanner(),

                      // Quick Actions
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const UserManagementScreen(),
                                    ),
                                  ).then((_) => _onRefresh());
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isDark ? const Color(0xFF334155) : const Color(0xFFEBEBEB),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.people_outline_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Kelola User',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? Colors.white70 : const Color(0xFF1F1F1F),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const MyTicketsPage(),
                                    ),
                                  ).then((_) => _onRefresh());
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isDark ? const Color(0xFF334155) : const Color(0xFFEBEBEB),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.assignment_ind_outlined, color: Theme.of(context).colorScheme.primary, size: 20),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Assign Tiket',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? Colors.white70 : const Color(0xFF1F1F1F),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

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
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                              alignment: Alignment.center,
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
                                    if (!context.mounted) return;
                                    context.read<TicketProvider>().loadTickets(role: currentRole);
                                  },
                                  onActionTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TicketDetailScreen(ticket: t),
                                      ),
                                    );
                                    if (!context.mounted) return;
                                    context.read<TicketProvider>().loadTickets(role: currentRole);
                                  },
                                );
                              },
                            ),

                      const SizedBox(height: 16),

                      // Recent System Activities Section
                      _buildRecentActivitiesSection(
                        context,
                        allTickets,
                        notificationProvider.cachedNotifications,
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildCriticalAlertBanner(BuildContext context, List<TicketModel> criticalTickets) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFEF4444), Color(0xFFF97316)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEF4444).withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showCriticalTicketsBottomSheet(context, criticalTickets),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tiket Kritis Terdeteksi',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Ada ${criticalTickets.length} tiket prioritas tinggi yang belum selesai.',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCriticalTicketsBottomSheet(BuildContext context, List<TicketModel> tickets) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Daftar Tiket Kritis',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1F1F1F),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: tickets.length,
                    itemBuilder: (context, index) {
                      final t = tickets[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Text(
                            t.title,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: isDark ? Colors.white : const Color(0xFF1F1F1F),
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                t.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: isDark ? Colors.white60 : Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEE2E2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      t.priority,
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFFEF4444),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      t.category,
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF2563EB),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TicketDetailScreen(ticket: t),
                              ),
                            ).then((_) => _onRefresh());
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentActivitiesSection(
    BuildContext context,
    List<TicketModel> tickets,
    List<NotificationModel> notifications,
  ) {
    final activities = getTimelineActivities(
      tickets: tickets,
      notifications: notifications,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (activities.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Aktivitas Terbaru',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1F1F1F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final act = activities[index];
              final associatedTicket = act[ActivityKeys.ticket] as TicketModel?;
              return ActivityTimelineCard(
                activity: act,
                onTap: associatedTicket != null
                    ? () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TicketDetailScreen(ticket: associatedTicket),
                          ),
                        );
                        if (!context.mounted) return;
                        context.read<TicketProvider>().loadTickets(role: 'admin');
                      }
                    : null,
              );
            },
          ),
        ],
      ),
    );
  }
}
