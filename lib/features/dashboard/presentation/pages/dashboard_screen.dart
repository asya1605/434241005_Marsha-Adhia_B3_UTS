import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../ticket/presentation/providers/ticket_provider.dart';
import '../../../ticket/presentation/pages/my_tickets_page.dart';
import '../../../ticket/presentation/pages/create_ticket_screen.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

import '../providers/dashboard_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/dashboard_shimmer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();

    final authProvider = context.read<AuthProvider>();
    final ticketProvider = context.read<TicketProvider>();
    final dashboardProvider = context.read<DashboardProvider>();

    Future.microtask(() async {
      await authProvider.checkLoginStatus();
      
      if (mounted) {
        final role = authProvider.role ?? "user";
        
        // Load tickets dynamically based on the current user's role
        await ticketProvider.loadTickets(role: role);
        
        if (mounted) {
          // Process statistics in the DashboardProvider
          dashboardProvider.loadDashboard(
            ticketProvider.tickets,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardProvider>();
    final ticketProvider = context.watch<TicketProvider>();
    final authProvider = context.watch<AuthProvider>();
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final role = authProvider.role ?? "user";
    
    // Show shimmer skeleton screen while loading
    if (ticketProvider.isLoading || dashboard.isLoading) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        body: SafeArea(
          child: DashboardShimmer(showCreateCta: role == 'user'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.blue,
          onRefresh: () async {
            final dProvider = context.read<DashboardProvider>();
            await ticketProvider.loadTickets(role: role);
            dProvider.loadDashboard(ticketProvider.tickets);
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ── 1. HEADER (Dynamic per Role) ───────────────────────────
                _buildHeader(authProvider, isDark),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// ── 2. CREATE TICKET CTA (User Role Only) ─────────────────
                      if (role == 'user') ...[
                        _buildCreateTicketCTA(context),
                        const SizedBox(height: 24),
                      ],

                      /// ── 3. OVERVIEW SECTION ──────────────────────────────────
                      _SectionHeader(
                        title: role == 'user'
                            ? 'My Tickets Overview'
                            : role == 'helpdesk'
                                ? 'My Workload'
                                : 'Global Overview',
                      ),
                      const SizedBox(height: 12),

                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.38,
                        children: [
                          StatCard(
                            title: role == 'helpdesk' ? "Total Assigned" : "Total Tickets",
                            number: dashboard.total.toString(),
                            icon: Icons.confirmation_number_outlined,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          StatCard(
                            title: "Open",
                            number: dashboard.open.toString(),
                            icon: Icons.folder_open_outlined,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF06B6D4), Color(0xFF67E8F9)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          StatCard(
                            title: "Pending",
                            number: dashboard.pending.toString(),
                            icon: Icons.hourglass_empty_outlined,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF59E0B), Color(0xFFFCD34D)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          StatCard(
                            title: "Closed",
                            number: dashboard.closed.toString(),
                            icon: Icons.check_circle_outline,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF34D399)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      /// ── 4. RECENT TICKETS SECTION ────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _SectionHeader(
                            title: role == 'helpdesk' ? 'Assigned Tickets' : 'Recent Tickets',
                          ),
                          if (ticketProvider.tickets.length > 5)
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const MyTicketsPage(),
                                  ),
                                );
                              },
                              child: Text(
                                'View All',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.blue,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      _buildRecentTickets(
                        context,
                        ticketProvider,
                        role,
                        isDark,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── HEADER (Unified and Themed dynamically by Role) ──────────────────────

  Widget _buildHeader(AuthProvider authProvider, bool isDark) {
    final name = authProvider.name ?? "User";
    final role = (authProvider.role ?? "user").toLowerCase();

    // Setup role specific visual properties
    Gradient headerGradient;
    Widget roleBadge;
    String panelTitle;
    String initialLetter = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : "U";

    if (role == 'admin') {
      panelTitle = 'Administrator Panel';
      headerGradient = LinearGradient(
        colors: isDark
            ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
            : [const Color(0xFF1E3A8A), const Color(0xFF2563EB)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      roleBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFBBF24).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFFBBF24).withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shield_outlined, size: 12, color: Color(0xFFFBBF24)),
            const SizedBox(width: 4),
            Text(
              'ADMIN',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFFBBF24),
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      );
    } else if (role == 'helpdesk') {
      panelTitle = 'Helpdesk Agent Panel';
      headerGradient = LinearGradient(
        colors: isDark
            ? [const Color(0xFF2D1E4E), const Color(0xFF1A1235)]
            : [const Color(0xFF5B21B6), const Color(0xFF7C3AED)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      roleBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFA78BFA).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFA78BFA).withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.headset_mic_outlined, size: 12, color: Color(0xFFA78BFA)),
            const SizedBox(width: 4),
            Text(
              'HELPDESK',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFA78BFA),
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      );
    } else {
      panelTitle = 'User Portal';
      headerGradient = LinearGradient(
        colors: isDark
            ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
            : [const Color(0xFF1E40AF), const Color(0xFF3B82F6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      roleBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF60A5FA).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF60A5FA).withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_outline_rounded, size: 12, color: Color(0xFF60A5FA)),
            const SizedBox(width: 4),
            Text(
              'USER',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF60A5FA),
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: headerGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    initialLetter,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, $name 👋',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      panelTitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              roleBadge,
            ],
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.12)),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                color: Colors.white.withValues(alpha: 0.6),
                size: 13,
              ),
              const SizedBox(width: 6),
              Text(
                _formattedDate(),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.65),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 3,
                      backgroundColor: Color(0xFF10B981),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Online',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF10B981),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── CREATE TICKET CTA (User Only) ─────────────────────────────────────

  Widget _buildCreateTicketCTA(BuildContext context) {
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
                  Text(
                    'Create New Ticket',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Report an issue or request support',
                    style: GoogleFonts.poppins(
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

  // ─── RECENT TICKETS LIST ───────────────────────────────────────────────

  Widget _buildRecentTickets(
    BuildContext context,
    TicketProvider ticketProvider,
    String role,
    bool isDark,
  ) {
    final tickets = ticketProvider.tickets;

    if (tickets.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 44,
              color: isDark ? Colors.white24 : AppColors.textHint,
            ),
            const SizedBox(height: 12),
            Text(
              role == 'helpdesk' ? 'No assigned tickets' : 'No tickets yet',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white54 : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              role == 'helpdesk'
                  ? "You're completely caught up!"
                  : 'Create your first ticket to get started',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isDark ? Colors.white24 : AppColors.textHint,
              ),
            ),
          ],
        ),
      );
    }

    final recentTickets = tickets.length > 5 ? tickets.sublist(0, 5) : tickets;

    return Column(
      children: recentTickets.map((ticket) {
        return _ticketListItem(context, ticket, role, isDark);
      }).toList(),
    );
  }

  Widget _ticketListItem(
    BuildContext context,
    dynamic ticket,
    String role,
    bool isDark,
  ) {
    final statusColor = _statusColor(ticket.status);
    final hasMetadata = (role == 'admin' || role == 'helpdesk');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            /// Left accent status line
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),

            /// Ticket main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            ticket.title,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : AppColors.textPrimary,
                              letterSpacing: -0.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),

                        /// Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            ticket.status,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ticket.description,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    /// Extra Role Specific Metadata (Admin / Helpdesk only)
                    if (hasMetadata) ...[
                      const SizedBox(height: 8),
                      Container(
                        height: 1,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : AppColors.borderLight.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 13,
                            color: isDark ? Colors.white30 : AppColors.textHint,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'User: ${ticket.userId.toString().length > 8 ? "${ticket.userId.toString().substring(0, 8)}..." : ticket.userId}',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white30 : AppColors.textHint,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          if (ticket.assignedTo != null) ...[
                            const SizedBox(width: 12),
                            Icon(
                              Icons.headset_mic_outlined,
                              size: 13,
                              color: isDark ? Colors.white30 : AppColors.textHint,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                ticket.assignedName ?? 'Assigned',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white30 : AppColors.textHint,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return AppColors.statusOpen;
      case 'assign':
        return AppColors.statusPending;
      case 'on progress':
      case 'on_progress':
      case 'in progress':
      case 'in_progress':
      case 'process':
        return AppColors.statusProcess;
      case 'closed':
      case 'close':
      case 'done':
        return AppColors.statusClosed;
      default:
        return AppColors.textHint;
    }
  }

  String _formattedDate() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekday = days[now.weekday - 1];
    final month = months[now.month - 1];
    return '$weekday, ${now.day} $month ${now.year}';
  }
}

// ─── Section Header ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.blue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

