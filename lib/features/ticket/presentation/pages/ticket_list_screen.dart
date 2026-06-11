import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/ticket_model.dart';
import '../providers/ticket_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/ticket_list_shimmer.dart';
import 'ticket_detail_screen.dart';
import 'create_ticket_screen.dart';

class TicketListScreen extends StatefulWidget {
  const TicketListScreen({super.key});

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = "All";
  String _selectedPriority = "All";

  @override
  void initState() {
    super.initState();

    final authProvider = context.read<AuthProvider>();
    final ticketProvider = context.read<TicketProvider>();

    Future.microtask(() {
      final role = authProvider.role ?? "user";
      ticketProvider.loadTickets(role: role);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Stable hashing of the UUID to dynamically compute deterministic category and priority
  int _stableHash(String value) {
    int hash = 0;
    for (int i = 0; i < value.length; i++) {
      hash = value.codeUnitAt(i) + ((hash << 5) - hash);
    }
    return hash.abs();
  }

  String _getMockCategory(String id) {
    final categories = ["Hardware", "Software", "Network"];
    return categories[_stableHash(id) % categories.length];
  }

  String _getMockPriority(String id) {
    final priorities = ["Low", "Medium", "High"];
    return priorities[(_stableHash(id) ~/ 3) % priorities.length];
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return AppColors.statusOpen;
      case 'pending':
        return AppColors.statusPending;
      case 'process':
        return AppColors.statusProcess;
      case 'closed':
      case 'done':
        return AppColors.statusClosed;
      default:
        return AppColors.textHint;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppColors.priorityHigh;
      case 'medium':
        return AppColors.priorityMed;
      case 'low':
        return AppColors.priorityLow;
      default:
        return AppColors.textHint;
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekday = days[date.weekday - 1];
    final month = months[date.month - 1];
    return '$weekday, ${date.day} $month ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final ticketProvider = context.watch<TicketProvider>();
    final authProvider = context.watch<AuthProvider>();
    final role = authProvider.role ?? "user";
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Apply Client-Side Filter
    final filteredTickets = ticketProvider.tickets.where((ticket) {
      final query = _searchController.text.toLowerCase();
      final matchesQuery = query.isEmpty ||
          ticket.title.toLowerCase().contains(query) ||
          ticket.description.toLowerCase().contains(query);

      final matchesStatus = _selectedStatus == "All" ||
          ticket.status.toLowerCase() == _selectedStatus.toLowerCase();

      final ticketPriority = _getMockPriority(ticket.id);
      final matchesPriority = _selectedPriority == "All" ||
          ticketPriority.toLowerCase() == _selectedPriority.toLowerCase();

      return matchesQuery && matchesStatus && matchesPriority;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        title: Text(
          role == "user"
              ? "My Support Tickets"
              : role == "helpdesk"
                  ? "Assigned Queue"
                  : "Global Tickets",
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
            onPressed: () {
              ticketProvider.loadTickets(role: role);
            },
          ),
        ],
      ),
      floatingActionButton: role == "user"
          ? FloatingActionButton.extended(
              onPressed: () async {
                final tProvider = context.read<TicketProvider>();
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateTicketScreen(),
                  ),
                );
                tProvider.loadTickets(role: role);
              },
              backgroundColor: AppColors.blue,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: Text(
                'New Ticket',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
              ),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            /// 1. Floating Search Bar
            _buildSearchBar(isDark),

            /// 2. Double-Row Scrollable Filter Chips
            _buildFilterChipsSection(isDark),
            const SizedBox(height: 8),

            /// 3. Main Body Content (Shimmer / Empty State / List View)
            Expanded(
              child: ticketProvider.isLoading
                  ? const TicketListShimmer()
                  : _buildListOrEmptyState(
                      context,
                      filteredTickets,
                      ticketProvider.tickets.isEmpty,
                      role,
                      isDark,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          setState(() {});
        },
        style: GoogleFonts.outfit(
          fontSize: 14,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: "Search by title or description...",
          hintStyle: GoogleFonts.outfit(
            fontSize: 13.5,
            color: isDark ? const Color(0xFF64748B) : AppColors.textHint,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.blue,
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: isDark ? Colors.white54 : AppColors.textHint,
                    size: 18,
                  ),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterChipsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status Row
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Center(
                  child: Text(
                    "Status:",
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF64748B) : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              _buildChip("All", _selectedStatus, (val) {
                setState(() {
                  _selectedStatus = val;
                });
              }, isDark),
              _buildChip("Open", _selectedStatus, (val) {
                setState(() {
                  _selectedStatus = val;
                });
              }, isDark),
              _buildChip("Process", _selectedStatus, (val) {
                setState(() {
                  _selectedStatus = val;
                });
              }, isDark),
              _buildChip("Pending", _selectedStatus, (val) {
                setState(() {
                  _selectedStatus = val;
                });
              }, isDark),
              _buildChip("Closed", _selectedStatus, (val) {
                setState(() {
                  _selectedStatus = val;
                });
              }, isDark),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Priority Row
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Center(
                  child: Text(
                    "Priority:",
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF64748B) : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              _buildChip("All", _selectedPriority, (val) {
                setState(() {
                  _selectedPriority = val;
                });
              }, isDark),
              _buildChip("High", _selectedPriority, (val) {
                setState(() {
                  _selectedPriority = val;
                });
              }, isDark),
              _buildChip("Medium", _selectedPriority, (val) {
                setState(() {
                  _selectedPriority = val;
                });
              }, isDark),
              _buildChip("Low", _selectedPriority, (val) {
                setState(() {
                  _selectedPriority = val;
                });
              }, isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChip(
    String label,
    String currentValue,
    Function(String) onSelected,
    bool isDark,
  ) {
    final isSelected = label.toLowerCase() == currentValue.toLowerCase();

    return GestureDetector(
      onTap: () => onSelected(label),
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.blue
              : (isDark ? AppColors.surfaceDark : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.blue
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white70 : AppColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListOrEmptyState(
    BuildContext context,
    List<TicketModel> filteredTickets,
    bool isProviderEmpty,
    String role,
    bool isDark,
  ) {
    // 1. True Empty State: Database/Provider has no tickets
    if (isProviderEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.inbox_outlined,
                  size: 54,
                  color: AppColors.blue,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                role == "user"
                    ? "No Tickets Created Yet"
                    : role == "helpdesk"
                        ? "Your Queue is Empty"
                        : "No Tickets Found",
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                role == "user"
                    ? "Report your first issue using the button below."
                    : role == "helpdesk"
                        ? "All assigned support requests have been resolved."
                        : "There are currently no tickets in the database.",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                ),
              ),
              if (role == "user") ...[
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateTicketScreen(),
                      ),
                    );
                    if (context.mounted) {
                      context.read<TicketProvider>().loadTickets(role: role);
                    }
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text("Create Ticket"),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(160, 44),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    // 2. Filter Empty State: Database has tickets, but search/filter returned nothing
    if (filteredTickets.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.priorityMed.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  size: 54,
                  color: AppColors.priorityMed,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "No Matching Tickets",
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "We couldn't find any tickets that match your search query or filter selections.",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _selectedStatus = "All";
                    _selectedPriority = "All";
                  });
                },
                icon: const Icon(Icons.clear_all_rounded),
                label: const Text("Clear Filters"),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.blue),
                  foregroundColor: AppColors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Ticket List View
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: filteredTickets.length,
      itemBuilder: (context, index) {
        final ticket = filteredTickets[index];
        return _buildTicketCard(context, ticket, role, isDark);
      },
    );
  }

  Widget _buildTicketCard(
    BuildContext context,
    TicketModel ticket,
    String role,
    bool isDark,
  ) {
    final statusColor = _getStatusColor(ticket.status);
    final category = _getMockCategory(ticket.id);
    final priority = _getMockPriority(ticket.id);
    final priorityColor = _getPriorityColor(priority);
    final shortId = ticket.id.length > 5 ? ticket.id.substring(0, 5).toUpperCase() : ticket.id.toUpperCase();
    final hasMetadata = (role == 'admin' || role == 'helpdesk');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              final tProvider = context.read<TicketProvider>();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TicketDetailScreen(ticket: ticket),
                ),
              );
              tProvider.loadTickets(role: role);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Short ID & Status badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '#TCK-$shortId',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Ticket Title
                  Text(
                    ticket.title,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Ticket Description
                  Text(
                    ticket.description,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      height: 1.4,
                      color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 14),

                  // Double Badges: Category & Priority
                  Row(
                    children: [
                      // Category Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF0F172A)
                              : AppColors.blueSubtle,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF1E293B)
                                : AppColors.blueLight.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.label_outline_rounded,
                              size: 11,
                              color: isDark ? const Color(0xFF60A5FA) : AppColors.blue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              category,
                              style: GoogleFonts.outfit(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFF60A5FA) : AppColors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Priority Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: priorityColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: priorityColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 11,
                              color: priorityColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              priority,
                              style: GoogleFonts.outfit(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: priorityColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Divider
                  Container(
                    height: 1,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : AppColors.borderLight.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 12),

                  // Bottom Row: Date & Assignee info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Creation Date
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 12,
                            color: isDark ? Colors.white30 : AppColors.textHint,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatDate(ticket.createdAt),
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white30 : AppColors.textHint,
                            ),
                          ),
                        ],
                      ),

                      // Assignee Name
                      Row(
                        children: [
                          Icon(
                            Icons.headset_mic_outlined,
                            size: 12,
                            color: isDark ? Colors.white30 : AppColors.textHint,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            ticket.assignedName ?? 'Unassigned',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: ticket.assignedName != null
                                  ? (isDark ? const Color(0xFF60A5FA) : AppColors.blue)
                                  : (isDark ? Colors.white30 : AppColors.textHint),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Extra User metadata line for Admin/Helpdesk
                  if (hasMetadata) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 12,
                          color: isDark ? Colors.white30 : AppColors.textHint,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'User ID: ${ticket.userId}',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white30 : AppColors.textHint,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}