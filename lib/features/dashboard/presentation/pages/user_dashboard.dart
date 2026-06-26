import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/dashboard_widgets.dart';
import '../widgets/dashboard_shimmer.dart';
import '../widgets/app_design_tokens.dart';
import '../../../ticket/data/models/ticket_model.dart';
import '../../../ticket/presentation/providers/ticket_provider.dart';
import '../../../ticket/presentation/pages/create_ticket_screen.dart';
import '../../../ticket/presentation/pages/my_tickets_page.dart';
import '../../../ticket/presentation/pages/ticket_detail_screen.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notification/presentation/providers/notification_provider.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<TicketProvider>().loadTickets(role: 'user');
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
    await context.read<TicketProvider>().loadTickets(role: 'user');
  }

  @override
  Widget build(BuildContext context) {
    final ticketProvider = context.watch<TicketProvider>();
    final authProvider = context.watch<AuthProvider>();
    final notificationProvider = context.watch<NotificationProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final name = authProvider.name ?? 'User';
    final myTickets = ticketProvider.tickets;
    const currentRole = 'user';

    // Calculate dynamic stats using Task 1 extension
    final totalCount = myTickets.length;
    final openCount = myTickets.where((t) => t.statusCategory == 'open').length;
    final inProgressCount = myTickets.where((t) => t.statusCategory == 'inProgress').length;
    final closedCount = myTickets.where((t) => t.statusCategory == 'closed').length;
    final otherCount = myTickets.where((t) => t.statusCategory == 'other').length;

    if (otherCount > 0) {
      debugPrint('Warning: $otherCount tickets with unrecognized status detected.');
    }

    final stats = [
      StatItem(label: 'Total Tickets', value: totalCount, icon: Icons.layers_outlined, iconColor: AppColors.primary),
      StatItem(label: 'Open', value: openCount, icon: Icons.folder_outlined, iconColor: AppColors.statusWarningText),
      StatItem(label: 'In Progress', value: inProgressCount, icon: Icons.autorenew, iconColor: AppColors.primary),
      StatItem(label: 'Closed', value: closedCount, icon: Icons.check_circle_outline, iconColor: AppColors.statusClosedText),
      if (otherCount > 0)
        StatItem(label: 'Other', value: otherCount, icon: Icons.help_outline, iconColor: AppColors.textSecondary),
    ];

    // Get ticket IDs with unread notifications
    final unreadTicketIds = notificationProvider.cachedNotifications
        .where((n) => !n.isRead && n.ticketId != null)
        .map((n) => n.ticketId)
        .toSet();

    final unreadCount = myTickets.where((t) => unreadTicketIds.contains(t.id)).length;

    // Up to 5 recent tickets
    final recentTickets = myTickets.length > 5 ? myTickets.sublist(0, 5) : myTickets;

    // Timeline activities (semi-dynamic)
    final activities = getTimelineActivities(
      tickets: myTickets,
      notifications: notificationProvider.cachedNotifications,
    );

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1117) : AppColors.bgPage,
      body: ticketProvider.isInitialLoading
          ? const DashboardShimmer(showCreateCta: true)
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _onRefresh,
              child: CustomScrollView(
                slivers: [
                  // ── Header gradient sky-blue ──────────────────────────────────────
                  SliverToBoxAdapter(
                    child: DashboardHeader(
                      name: name,
                      subtitle: 'User Portal',
                      roleLabel: 'User',
                      roleIcon: Icons.person_outline_rounded,
                      gradientColors: DC.userGrad,
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // ── 2. Hero Status Card (Task 4/6) ─────────────────────
                        HeroActionBanner(
                          title: 'Butuh bantuan IT?',
                          subtitle: 'Laporkan masalahmu, tim kami siap membantu',
                          ctaLabel: '+ Buat Tiket',
                          backgroundIcon: Icons.help_outline,
                          progress: totalCount > 0 ? (totalCount - openCount) / totalCount : 0.0,
                          progressLabel: '$openCount dari $totalCount tiket masih open',
                          onCtaTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CreateTicketScreen(),
                              ),
                            ).then((_) => _onRefresh());
                          },
                        ),
                        const SizedBox(height: 12),

                        // ── 3. Update Alert Banner (MOVED UP) ──────────────────
                        UpdateAlertBanner(
                          unreadCount: unreadCount,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MyTicketsPage(),
                              ),
                            ).then((_) => _onRefresh());
                          },
                        ),
                        if (unreadCount > 0) const SizedBox(height: 12),

                        // ── 4. Kategori Section ────────────────────────────────
                        const SectionHeader(title: 'Kategori'),
                        const SizedBox(height: 4),
                        CategoryGrid(
                          categories: const [
                            CategoryItem(label: 'Jaringan', icon: Icons.wifi, value: 'Network'),
                            CategoryItem(label: 'Hardware', icon: Icons.laptop_outlined, value: 'Hardware'),
                            CategoryItem(label: 'Software', icon: Icons.apps, value: 'Software'),
                            CategoryItem(label: 'Lainnya', icon: Icons.more_horiz, value: 'General'),
                          ],
                          onCategoryTap: (val) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CreateTicketScreen(initialCategory: val),
                              ),
                            ).then((_) => _onRefresh());
                          },
                        ),
                        const SizedBox(height: 14),

                        // ── 5. Overview Grid ──────────────────────────────────
                        const SectionHeader(title: 'Ringkasan Tiket'),
                        const SizedBox(height: 4),
                        StatCardGrid(items: stats),
                        const SizedBox(height: 14),

                        // ── 6. Recent Tickets List ─────────────────────────────
                        SectionHeader(
                          title: 'Tiket Kamu',
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
                            subtitle: 'Silakan buat tiket baru untuk memulai.',
                          )
                        else
                          ...recentTickets.map(
                            (t) => TicketBoardingCard(
                              ticketCode: t.id,
                              title: t.title,
                              status: t.status,
                              categoryIcon: _getCategoryIcon(t.category),
                              createdAt: t.createdAt,
                              assignedAgentName: t.assignedName,
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

                        // ── 7. Activity Timeline ───────────────────────────────
                        const SectionHeader(title: 'Aktivitas Terbaru'),
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
