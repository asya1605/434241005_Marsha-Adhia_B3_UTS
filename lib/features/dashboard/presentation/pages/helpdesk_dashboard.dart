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

class HelpdeskDashboard extends StatefulWidget {
  const HelpdeskDashboard({super.key});

  @override
  State<HelpdeskDashboard> createState() => _HelpdeskDashboardState();
}

class _HelpdeskDashboardState extends State<HelpdeskDashboard> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<TicketProvider>().loadTickets(role: 'helpdesk');
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

    final totalAssigned = myAssignedTickets.length;
    final openCount = myAssignedTickets.where((t) => t.statusCategory == 'open').length;
    final inProgressCount = myAssignedTickets.where((t) => t.statusCategory == 'inProgress').length;
    final resolvedCount = myAssignedTickets.where((t) => t.statusCategory == 'closed').length;
    final otherCount = myAssignedTickets.where((t) => t.statusCategory == 'other').length;

    if (otherCount > 0) {
      debugPrint('Warning: $otherCount tickets with unrecognized status detected.');
    }

    final stats = [
      StatItem(label: 'Assigned', value: openCount, icon: Icons.assignment_outlined, iconColor: AppColors.primary),
      StatItem(label: 'In Progress', value: inProgressCount, icon: Icons.autorenew, iconColor: AppColors.statusWarningText),
      StatItem(label: 'Resolved Today', value: resolvedCount, icon: Icons.check_circle_outline, iconColor: AppColors.statusClosedText),
      StatItem(label: 'Total Assigned', value: totalAssigned, icon: Icons.layers_outlined, iconColor: AppColors.primary),
      if (otherCount > 0)
        StatItem(label: 'Other', value: otherCount, icon: Icons.help_outline, iconColor: AppColors.textSecondary),
    ];

    // Pending count = Assigned + In Progress
    final pendingCount = openCount + inProgressCount;

    // Up to 5 assigned tickets
    final recentTickets = myAssignedTickets.length > 5 
        ? myAssignedTickets.sublist(0, 5) 
        : myAssignedTickets;

    // Get unread notification ticket IDs
    final unreadTicketIds = notificationProvider.cachedNotifications
        .where((n) => !n.isRead && n.ticketId != null)
        .map((n) => n.ticketId)
        .toSet();

    // Timeline activities (using tickets + notifications mapping locally)
    final activities = getTimelineActivities(
      tickets: ticketProvider.tickets,
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
                  // ── Header gradient purple ────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: DashboardHeader(
                      name: name,
                      subtitle: 'Helpdesk Agent Panel',
                      roleLabel: 'Helpdesk',
                      roleIcon: Icons.headset_mic_outlined,
                      gradientColors: DC.helpdeskGrad,
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // ── 1. Workload Info Banner ────────────────────────────
                        HeroActionBanner(
                          title: '$pendingCount tiket menunggu kamu tangani',
                          subtitle: 'Prioritaskan tiket yang sudah lama menunggu',
                          ctaLabel: 'Lihat Semua',
                          backgroundIcon: Icons.support_agent,
                          onCtaTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MyTicketsPage(),
                              ),
                            ).then((_) => _onRefresh());
                          },
                        ),
                        const SizedBox(height: 14),

                        // ── 2. Workload statistics ─────────────────────────────
                        const SectionHeader(title: 'My Workload'),
                        const SizedBox(height: 4),
                        StatCardGrid(items: stats),
                        const SizedBox(height: 14),

                        // ── 3. Assigned Tickets list ───────────────────────────
                        SectionHeader(
                          title: 'Assigned Tickets',
                          linkText: totalAssigned > 5 ? 'Lihat semua' : null,
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
                            subtitle: 'Tidak ada tiket yang ditugaskan kepada Anda.',
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

                        // ── 4. Activity section ────────────────────────────────
                        const SectionHeader(title: 'Aktivitas Tim'),
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

