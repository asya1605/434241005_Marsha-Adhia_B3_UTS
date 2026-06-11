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
// admin_dashboard.dart
// Taruh di: lib/features/dashboard/presentation/pages/admin_dashboard.dart
// ─────────────────────────────────────────────────────────────────────────────

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

  @override
  Widget build(BuildContext context) {
    final ticketProvider = context.watch<TicketProvider>();
    final authProvider = context.watch<AuthProvider>();
    final notificationProvider = context.watch<NotificationProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final name = authProvider.name ?? 'Admin';
    final allTickets = ticketProvider.tickets;
    final currentRole = 'admin';
    
    // Dynamic calculations from provider data
    final totalCount = allTickets.length;
    final openCount = allTickets.where((t) => t.status == 'Open').length;
    final pendingCount = allTickets.where((t) => t.status == 'Pending').length;
    final closedCount = allTickets.where((t) => t.status == 'Closed').length;

    // Count unique assigned agents dynamically from ticket list
    final activeAgents = allTickets
        .map((t) => t.assignedTo)
        .whereType<String>()
        .toSet()
        .length;

    final unassignedCount = allTickets.where((t) => t.assignedTo == null).length;

    // Up to 5 recent tickets
    final recentTickets = allTickets.length > 5 ? allTickets.sublist(0, 5) : allTickets;

    // Timeline activities
    final activities = getTimelineActivities(
      tickets: allTickets,
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
                  // ── Header gradient ─────────────────────────────────────────────
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
                    padding: const EdgeInsets.all(14),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // NOTE: SLA Compliance ProgressBarCard is hidden entirely because it is a synthetic metric.

                        // ── 1. Global Overview stat grid ─────────────────────────
                        SectionHeader(
                          title: 'Global Overview',
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

                        // ── 2. Distribusi Agent ───────────────────────────────────
                        const SectionHeader(title: 'Distribusi Agent'),
                        Row(
                          children: [
                            Expanded(
                              child: InsightMiniCard(
                                label: 'Helpdesk aktif',
                                value: activeAgents.toString(),
                                subtitle: null, // Omit synthetic overloaded subtitle
                                barProgress: activeAgents > 0 ? (activeAgents / 5) : 0,
                                barColor: DC.blue,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: InsightMiniCard(
                                label: 'Avg. resolve time',
                                value: 'N/A', // Omit synthetic resolve time
                                subtitle: null,
                                barProgress: 0.0,
                                barColor: DC.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // ── 2.5. Aktivitas Sistem ──────────────────────────────
                        const SectionHeader(title: 'Aktivitas Sistem'),
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


                        // ── 3. Quick Actions 2×2 ─────────────────────────────────
                        const SectionHeader(title: 'Quick Actions'),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2.4,
                          children: [
                            QuickActionButton(
                              label: 'Kelola User',
                              subtitle: 'N/A user aktif',
                              icon: Icons.people_outline_rounded,
                              iconBg: DC.blueBg,
                              iconColor: DC.blue,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Fitur Kelola User belum diimplementasikan'),
                                  ),
                                );
                              },
                            ),
                            QuickActionButton(
                              label: 'Laporan',
                              subtitle: 'Export data',
                              icon: Icons.bar_chart_rounded,
                              iconBg: DC.amberBg,
                              iconColor: DC.amber,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Fitur Laporan belum diimplementasikan'),
                                  ),
                                );
                              },
                            ),
                            QuickActionButton(
                              label: 'Assign Tiket',
                              subtitle: '$unassignedCount unassigned',
                              icon: Icons.assignment_ind_outlined,
                              iconBg: DC.greenBg,
                              iconColor: DC.green,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const TicketListScreen(),
                                  ),
                                );
                              },
                            ),
                            QuickActionButton(
                              label: 'SLA Alert',
                              subtitle: 'N/A overdue', // SLA is not tracked in DB
                              icon: Icons.warning_amber_outlined,
                              iconBg: DC.redBg,
                              iconColor: DC.red,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('SLA Alert tidak didukung oleh database/provider saat ini'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // ── 4. Recent Tickets ─────────────────────────────────────
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
                              creatorEmail: null, // Hide user email to avoid clutter
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

  Future<void> _onRefresh() async {
    await context.read<TicketProvider>().loadTickets(role: 'admin');
  }
}

