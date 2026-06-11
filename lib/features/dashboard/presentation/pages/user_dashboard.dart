import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/dashboard_widgets.dart';
import '../../../ticket/data/models/ticket_model.dart';
import '../../../ticket/presentation/providers/ticket_provider.dart';
import '../../../ticket/presentation/pages/create_ticket_screen.dart';
import '../../../ticket/presentation/pages/ticket_list_screen.dart';
import '../../../ticket/presentation/pages/ticket_detail_screen.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notification/presentation/providers/notification_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// user_dashboard.dart
// Taruh di: lib/features/dashboard/presentation/pages/user_dashboard.dart
// ─────────────────────────────────────────────────────────────────────────────

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

  @override
  Widget build(BuildContext context) {
    final ticketProvider = context.watch<TicketProvider>();
    final authProvider = context.watch<AuthProvider>();
    final notificationProvider = context.watch<NotificationProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final name = authProvider.name ?? 'User';
    final myTickets = ticketProvider.tickets;
    final currentRole = 'user';

    // Calculate dynamic counts
    final totalCount = myTickets.length;
    final openCount = myTickets.where((t) => t.status == 'Open').length;
    final pendingCount = myTickets.where((t) => t.status == 'Pending').length;
    final closedCount = myTickets.where((t) => t.status == 'Closed').length;

    // Get ticket IDs with unread notifications
    final unreadTicketIds = notificationProvider.cachedNotifications
        .where((n) => !n.isRead && n.ticketId != null)
        .map((n) => n.ticketId)
        .toSet();

    // Up to 5 recent tickets
    final recentTickets = myTickets.length > 5 ? myTickets.sublist(0, 5) : myTickets;

    // Timeline activities
    final activities = getTimelineActivities(
      tickets: myTickets,
      notifications: notificationProvider.cachedNotifications,
    );

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1117) : const Color(0xFFF4F6FA),
      body: ticketProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: DC.blue,
              ),
            )
          : RefreshIndicator(
              color: DC.blue,
              onRefresh: _onRefresh,
              child: CustomScrollView(
                slivers: [
                  // ── Header gradient biru ────────────────────────────────────────
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
                    padding: const EdgeInsets.all(14),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // ── 1. Create Ticket CTA ──────────────────────────────
                        _buildCreateTicketCTA(context, isDark),
                        const SizedBox(height: 16),

                        // ── 2. Update terbaru tiketmu (Unread replies) ──────────
                        if (myTickets.any((t) => unreadTicketIds.contains(t.id))) ...[
                          SectionHeader(
                            title: 'Update terbaru tiketmu (${myTickets.where((t) => unreadTicketIds.contains(t.id)).length})',
                          ),
                          ...myTickets
                              .where((t) => unreadTicketIds.contains(t.id))
                              .map(
                                (t) => TicketRowCard(
                                  title: t.title,
                                  description: t.description,
                                  status: t.status,
                                  hasUnread: true,
                                  agentEmail: t.assignedName,
                                  dateStr: '${t.createdAt.day}/${t.createdAt.month}/${t.createdAt.year}',
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
                          const SizedBox(height: 16),
                        ],

                        // ── 3. Overview stat grid ──────────────────────────────
                        const SectionHeader(title: 'My Tickets Overview'),
                        StatCardGrid(
                          items: [
                            StatCardData(
                              label: 'Total Tickets',
                              value: totalCount,
                              icon: Icons.confirmation_number_outlined,
                              color: DC.blue,
                            ),
                            StatCardData(
                              label: 'Open',
                              value: openCount,
                              icon: Icons.folder_open_outlined,
                              color: DC.cyan,
                            ),
                            StatCardData(
                              label: 'Pending',
                              value: pendingCount,
                              icon: Icons.pause_circle_outline,
                              color: DC.amber,
                            ),
                            StatCardData(
                              label: 'Closed',
                              value: closedCount,
                              icon: Icons.check_circle_outline,
                              color: DC.green,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // ── 3.5. Aktivitas Terbaru ─────────────────────────────
                        const SectionHeader(title: 'Aktivitas Terbaru'),
                        if (activities.isEmpty)
                          const DashboardEmptyState(
                            icon: Icons.history_rounded,
                            imageAsset: 'assets/images/empty_activity.png',
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
                        const SizedBox(height: 16),


                        // ── 4. Recent Tickets ───────────────────────────────────
                        SectionHeader(
                          title: 'Recent Tickets ($totalCount)',
                          linkText: totalCount > 5 ? 'View All' : null,
                          onLink: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TicketListScreen(),
                              ),
                            );
                          },
                        ),
                        if (recentTickets.isEmpty)
                          const DashboardEmptyState(
                            icon: Icons.inbox_outlined,
                            imageAsset: 'assets/images/empty_ticket.png',
                            title: 'Belum Ada Tiket',
                            subtitle: 'Silakan buat tiket baru untuk memulai.',
                          )
                        else
                          ...recentTickets.map(
                            (t) => TicketRowCard(
                              title: t.title,
                              description: t.description,
                              status: t.status,
                              hasUnread: unreadTicketIds.contains(t.id),
                              agentEmail: t.assignedName,
                              dateStr: '${t.createdAt.day}/${t.createdAt.month}/${t.createdAt.year}',
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

                        const SizedBox(height: 20),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCreateTicketCTA(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const CreateTicketScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.add_circle_outline_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create New Ticket',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Report an issue or request support',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white70,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    await context.read<TicketProvider>().loadTickets(role: 'user');
  }
}

