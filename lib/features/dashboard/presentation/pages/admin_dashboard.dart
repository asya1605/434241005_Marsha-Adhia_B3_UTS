import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/dashboard_widgets.dart';
import '../widgets/dashboard_shimmer.dart';
import '../widgets/app_design_tokens.dart';
import '../../../ticket/data/models/ticket_model.dart';
import '../../../ticket/presentation/providers/ticket_provider.dart';
import '../../../ticket/presentation/pages/my_tickets_page.dart';
import '../../../ticket/presentation/pages/ticket_detail_screen.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notification/presentation/providers/notification_provider.dart';
import '../../../admin/presentation/pages/user_management_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<TicketProvider>().loadTickets(role: 'admin');
      }
    });
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'network':
        return Icons.wifi;
      case 'hardware':
        return Icons.laptop_outlined;
      case 'software':
        return Icons.apps;
      case 'account':
        return Icons.account_circle_outlined;
      default:
        return Icons.more_horiz;
    }
  }

  Future<void> _onRefresh() async {
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

    // Calculate dynamic stats using Task 1 extension
    final totalCount = allTickets.length;
    final openCount = allTickets.where((t) => t.statusCategory == 'open').length;
    final assignedCount = allTickets.where((t) => t.assignedTo != null).length;
    final closedCount = allTickets.where((t) => t.statusCategory == 'closed').length;
    final otherCount = allTickets.where((t) => t.statusCategory == 'other').length;

    if (otherCount > 0) {
      debugPrint('Warning: $otherCount tickets with unrecognized status detected.');
    }

    final stats = [
      StatItem(label: 'Total Tickets', value: totalCount, icon: Icons.layers_outlined, iconColor: AppColors.primary),
      StatItem(label: 'Open', value: openCount, icon: Icons.folder_outlined, iconColor: AppColors.statusWarningText),
      StatItem(label: 'Assigned', value: assignedCount, icon: Icons.assignment_turned_in_outlined, iconColor: AppColors.primary),
      StatItem(label: 'Closed', value: closedCount, icon: Icons.check_circle_outline, iconColor: AppColors.statusClosedText),
      if (otherCount > 0)
        StatItem(label: 'Other', value: otherCount, icon: Icons.help_outline, iconColor: AppColors.textSecondary),
    ];

    // Count unique assigned agents dynamically from loaded tickets list
    final activeAgents = allTickets
        .map((t) => t.assignedTo)
        .whereType<String>()
        .toSet()
        .length;

    // Count unassigned tickets
    final unassignedCount = allTickets.where((t) => t.assignedTo == null).length;

    // Up to 5 recent tickets
    final recentTickets = allTickets.length > 5 ? allTickets.sublist(0, 5) : allTickets;

    // Get unread notification ticket IDs
    final unreadTicketIds = notificationProvider.cachedNotifications
        .where((n) => !n.isRead && n.ticketId != null)
        .map((n) => n.ticketId)
        .toSet();

    // Timeline activities (using tickets + notifications mapping locally)
    final activities = getTimelineActivities(
      tickets: allTickets,
      notifications: notificationProvider.cachedNotifications,
    );

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1117) : AppColors.bgPage,
      body: ticketProvider.isInitialLoading
          ? const DashboardShimmer(showCreateCta: false)
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _onRefresh,
              child: CustomScrollView(
                slivers: [
                  // ── Header gradient sky-blue ──────────────────────────────────────
                  SliverToBoxAdapter(
                    child: DashboardHeader(
                      name: name,
                      subtitle: 'Administrator Panel',
                      roleLabel: 'Admin',
                      roleIcon: Icons.shield_outlined,
                      gradientColors: DC.adminGrad,
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // ── 1. Global Overview statistics ──────────────────────
                        const SectionHeader(title: 'Global Overview'),
                        const SizedBox(height: 4),
                        StatCardGrid(items: stats),
                        const SizedBox(height: 14),

                        // ── 2. Agent Distribution panel ────────────────────────
                        const SectionHeader(title: 'Distribusi Agent'),
                        const SizedBox(height: 4),
                        InsightMiniCard(
                          label: 'Helpdesk Bertugas',
                          value: '$activeAgents agent',
                          subtitle: '*dari tiket termuat',
                          subtitleColor: isDark ? Colors.white30 : AppColors.textTertiary,
                        ),
                        const SizedBox(height: 14),

                        // ── 3. Quick Actions row ───────────────────────────────
                        const SectionHeader(title: 'Quick Actions'),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: QuickActionButton(
                                label: 'Kelola User',
                                subtitle: 'Lihat & kelola pengguna',
                                icon: Icons.people_outline_rounded,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const UserManagementScreen(),
                                    ),
                                  ).then((_) => _onRefresh());
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: QuickActionButton(
                                label: 'Assign Tiket',
                                subtitle: '$unassignedCount unassigned',
                                icon: Icons.assignment_ind_outlined,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const MyTicketsPage(),
                                    ),
                                  ).then((_) => _onRefresh());
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // ── 4. Recent Tickets list ─────────────────────────────
                        SectionHeader(
                          title: 'Recent Tickets',
                          linkText: totalCount > 5 ? 'Lihat semua' : null,
                          onLink: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MyTicketsPage(),
                              ),
                            ).then((_) => _onRefresh());
                          },
                        ),
                        const SizedBox(height: 4),
                        if (recentTickets.isEmpty)
                          const DashboardEmptyState(
                            icon: Icons.inbox_outlined,
                            title: 'Belum Ada Tiket',
                            subtitle: 'Tidak ada tiket pendukung di dalam sistem.',
                          )
                        else
                          ...recentTickets.map(
                            (t) => TicketBoardingCard(
                              ticketCode: t.id,
                              title: t.title,
                              status: t.status,
                              categoryIcon: _getCategoryIcon(t.category),
                              createdAt: t.createdAt,
                              createdByName: t.creatorName ?? 'User',
                              hasUnread: unreadTicketIds.contains(t.id),
                              category: t.category,
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TicketDetailScreen(
                                      ticket: t,
                                    ),
                                  ),
                                );
                                if (!context.mounted) return;
                                context.read<TicketProvider>().loadTickets(
                                  role: currentRole,
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 14),

                        // ── 5. System Activity timeline ────────────────────────
                        const SectionHeader(title: 'Aktivitas Sistem'),
                        const SizedBox(height: 4),
                        if (activities.isEmpty)
                          const DashboardEmptyState(
                            icon: Icons.history_rounded,
                            title: 'Belum Ada Aktivitas',
                            subtitle: 'Aktivitas tiket akan muncul di sini.',
                          )
                        else
                          ...activities.map(
                            (act) => ActivityTimelineCard(
                              activity: act,
                              onTap: () async {
                                final activityTicket = act[ActivityKeys.ticket] as TicketModel?;
                                if (activityTicket != null) {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TicketDetailScreen(
                                        ticket: activityTicket,
                                      ),
                                    ),
                                  );
                                  if (!context.mounted) return;
                                  context.read<TicketProvider>().loadTickets(
                                    role: currentRole,
                                  );
                                }
                              },
                            ),
                          ),
                        const SizedBox(height: 20),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

