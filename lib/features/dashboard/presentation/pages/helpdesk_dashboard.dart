import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/dashboard_widgets.dart';
import '../../../ticket/data/models/ticket_model.dart';
import '../../../ticket/presentation/providers/ticket_provider.dart';
import '../../../ticket/presentation/pages/ticket_list_screen.dart';
import '../../../ticket/presentation/pages/ticket_detail_screen.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notification/presentation/providers/notification_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// helpdesk_dashboard.dart
// Taruh di: lib/features/dashboard/presentation/pages/helpdesk_dashboard.dart
// ─────────────────────────────────────────────────────────────────────────────

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

  @override
  Widget build(BuildContext context) {
    final ticketProvider = context.watch<TicketProvider>();
    final authProvider = context.watch<AuthProvider>();
    final notificationProvider = context.watch<NotificationProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final name = authProvider.name ?? 'Helpdesk';
    final agentId = authProvider.userId;
    final currentRole = 'helpdesk';

    // Filter tickets assigned to current helpdesk agent dynamically
    final myAssignedTickets = ticketProvider.tickets
        .where((t) => t.assignedTo == agentId)
        .toList();

    final totalAssigned = myAssignedTickets.length;
    final openTickets = myAssignedTickets.where((t) => t.status == 'Open').length;
    final pendingTickets = myAssignedTickets.where((t) => t.status == 'Pending').length;
    final closedTickets = myAssignedTickets.where((t) => t.status == 'Closed').length;

    // Up to 5 assigned tickets
    final recentTickets = myAssignedTickets.length > 5 
        ? myAssignedTickets.sublist(0, 5) 
        : myAssignedTickets;

    // Timeline activities
    final activities = getTimelineActivities(
      tickets: ticketProvider.tickets,
      notifications: notificationProvider.cachedNotifications,
    );

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1117) : const Color(0xFFF4F6FA),
      body: ticketProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: DC.purple,
              ),
            )
          : RefreshIndicator(
              color: DC.purple,
              onRefresh: _onRefresh,
              child: CustomScrollView(
                slivers: [
                  // ── Header gradient ungu ────────────────────────────────────────
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
                    padding: const EdgeInsets.all(14),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // NOTE: Daily Progress Bar Card is hidden because daily targets are synthetic metrics not stored in DB.

                        // ── 1. My Workload stat grid ──────────────────────────────
                        const SectionHeader(title: 'My Workload'),
                        StatCardGrid(
                          items: [
                            StatCardData(
                              label: 'Total Assigned',
                              value: totalAssigned,
                              icon: Icons.confirmation_number_outlined,
                              color: DC.blue,
                            ),
                            StatCardData(
                              label: 'Open',
                              value: openTickets,
                              icon: Icons.folder_open_outlined,
                              color: DC.cyan,
                            ),
                            StatCardData(
                              label: 'Pending',
                              value: pendingTickets,
                              icon: Icons.pause_circle_outline,
                              color: DC.amber,
                            ),
                            StatCardData(
                              label: 'Closed',
                              value: closedTickets,
                              icon: Icons.check_circle_outline,
                              color: DC.green,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // ── 1.5. Aktivitas Tim ─────────────────────────────────
                        const SectionHeader(title: 'Aktivitas Tim'),
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


                        // NOTE: Synthetic "Segera ditangani" priority ticket list is hidden because priorities are not supported in the database/provider data.

                        // ── 2. Assigned Tickets ───────────────────────────────────
                        SectionHeader(
                          title: 'Assigned Tickets ($totalAssigned)',
                          linkText: totalAssigned > 5 ? 'View All' : null,
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
                              creatorEmail: null,
                              agentEmail: null,
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

  Future<void> _onRefresh() async {
    await context.read<TicketProvider>().loadTickets(role: 'helpdesk');
  }
}

