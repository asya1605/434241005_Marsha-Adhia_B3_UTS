import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:helpdesk_ticket/features/dashboard/presentation/widgets/app_design_tokens.dart';
import 'package:helpdesk_ticket/features/auth/presentation/providers/auth_provider.dart';
import 'package:helpdesk_ticket/features/ticket/presentation/providers/ticket_provider.dart';
import 'package:helpdesk_ticket/features/ticket/presentation/widgets/ticket_list_shimmer.dart';
import 'package:helpdesk_ticket/features/ticket/presentation/pages/ticket_detail_screen.dart';
import 'package:helpdesk_ticket/features/ticket/data/models/ticket_model.dart';
import '../widgets/ticket_list_card.dart';

/// MY TICKETS PAGE — redesign v3 (Course Layout style)
class MyTicketsPage extends StatefulWidget {
  const MyTicketsPage({super.key});

  @override
  State<MyTicketsPage> createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage> {
  String _statusFilter = 'All';
  String _categoryFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        final authProvider = context.read<AuthProvider>();
        final role = authProvider.role ?? "user";
        context.read<TicketProvider>().loadTickets(role: role);
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
        return Icons.devices_other_outlined;
    }
  }

  void _showCategoryFilterSheet() {
    _showFilterSheet(
      title: 'Kategori',
      options: const ['All', 'General', 'Network', 'Hardware', 'Software', 'Account'],
      currentValue: _categoryFilter,
      onSelected: (value) => setState(() => _categoryFilter = value),
    );
  }

  IconData _getCategoryIconForSheet(String category) {
    switch (category.toLowerCase()) {
      case 'all':
        return Icons.grid_view_rounded;
      case 'general':
        return Icons.layers_outlined;
      case 'network':
        return Icons.wifi_rounded;
      case 'hardware':
        return Icons.laptop_mac_rounded;
      case 'software':
        return Icons.apps_rounded;
      case 'account':
        return Icons.account_circle_outlined;
      default:
        return Icons.devices_other_rounded;
    }
  }

  Color _getCategoryColorForSheet(String category) {
    switch (category.toLowerCase()) {
      case 'all':
        return AppColors.primary;
      case 'general':
        return const Color(0xFFF97316); // Orange
      case 'network':
        return const Color(0xFF2B9FF0); // Blue
      case 'hardware':
        return const Color(0xFF7C3AED); // Purple
      case 'software':
        return const Color(0xFF1F9D63); // Green
      case 'account':
        return const Color(0xFFFBBF24); // Kuning/Amber
      default:
        return AppColors.primary;
    }
  }

  void _showFilterSheet({
    required String title,
    required List<String> options,
    required String currentValue,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle bar
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.textTertiary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Title
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Options list
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: options.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final opt = options[index];
                      final isSelected = opt == currentValue;
                      final icon = _getCategoryIconForSheet(opt);
                      final color = _getCategoryColorForSheet(opt);

                      return InkWell(
                        onTap: () {
                          onSelected(opt);
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withOpacity(0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? color.withOpacity(0.3)
                                  : AppColors.borderLight.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? color.withOpacity(0.2)
                                      : AppColors.bgPage,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                    icon,
                                    size: 18,
                                    color: isSelected ? color : AppColors.textSecondary,
                                  ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                opt,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? color : AppColors.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 20,
                                  color: color,
                                ),
                            ],
                          ),
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

  Widget _buildTabs() {
    final tabs = ['All', 'To begin', 'In Progress', 'Finish'];
    final selectedIndex = _getSelectedIndex();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(tabs.length, (index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                if (index == 0) {
                  _statusFilter = 'All';
                } else if (index == 1) {
                  _statusFilter = 'Open';
                } else if (index == 2) {
                  _statusFilter = 'On Progress';
                } else if (index == 3) {
                  _statusFilter = 'Closed';
                }
              });
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tabs[index],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 3,
                  width: 36,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  int _getSelectedIndex() {
    final f = _statusFilter.toLowerCase();
    if (f == 'open' || f == 'assign') {
      return 1;
    } else if (f == 'on progress' || f == 'on_progress' || f == 'process' || f == 'pending' || f == 'in_progress' || f == 'in progress') {
      return 2;
    } else if (f == 'closed' || f == 'done' || f == 'resolved' || f == 'close') {
      return 3;
    }
    return 0; // 'all' or default
  }

  Widget _buildProgressCard(List<TicketModel> tickets) {
    final totalTickets = tickets.length;
    final closedTickets = tickets.where((t) {
      final s = t.status.toLowerCase();
      return ['closed', 'done', 'resolved', 'close'].contains(s);
    }).length;
    final progressVal = totalTickets > 0 ? closedTickets / totalTickets : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2B9FF0),
            Color(0xFF1565D8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2B9FF0).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Penyelesaian Tiket',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$closedTickets',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '/$totalTickets',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Progress Bar
                LayoutBuilder(
                  builder: (context, constraints) {
                    final barWidth = constraints.maxWidth;
                    return Stack(
                      children: [
                        Container(
                          height: 6,
                          width: barWidth,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        Container(
                          height: 6,
                          width: barWidth * progressVal,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Clipboard Checklist & Pencil Badge Illustration
          Container(
            width: 65,
            height: 75,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Checklist lines inside
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Row 1: green check + line
                      Row(
                        children: [
                          const Icon(Icons.check, size: 10, color: Colors.green),
                          const SizedBox(width: 4),
                          Container(width: 24, height: 3, color: Colors.grey.shade300),
                        ],
                      ),
                      // Row 2: green check + line
                      Row(
                        children: [
                          const Icon(Icons.check, size: 10, color: Colors.green),
                          const SizedBox(width: 4),
                          Container(width: 24, height: 3, color: Colors.grey.shade300),
                        ],
                      ),
                      // Row 3: pencil decoration
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: const [
                          Icon(Icons.edit, size: 11, color: Colors.amber),
                        ],
                      ),
                    ],
                  ),
                ),
                // Yellow Ribbon Badge at bottom of clipboard
                Positioned(
                  bottom: -6,
                  left: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'TIKET',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticketProvider = context.watch<TicketProvider>();
    final authProvider = context.watch<AuthProvider>();
    final role = authProvider.role ?? "user";

    // Filtering logic
    final filteredTickets = ticketProvider.tickets.where((t) {
      // 1. Status Filter
      bool statusMatch = _statusFilter == 'All';
      if (!statusMatch) {
        final f = _statusFilter.toLowerCase();
        final s = t.status.toLowerCase();
        if (f == 'open') {
          statusMatch = s == 'open';
        } else if (f == 'assign') {
          statusMatch = s == 'assign';
        } else if (f == 'on progress' || f == 'on_progress') {
          statusMatch = s == 'on progress' || s == 'on_progress' || s == 'process' || s == 'pending' || s == 'in_progress' || s == 'in progress';
        } else if (f == 'closed') {
          statusMatch = s == 'closed' || s == 'done' || s == 'resolved' || s == 'close';
        } else {
          statusMatch = s == f;
        }
      }

      // 2. Category Filter
      final categoryMatch = _categoryFilter == 'All' ||
          t.category.toLowerCase() == _categoryFilter.toLowerCase();

      // 3. Search Filter
      final searchMatch = _searchController.text.isEmpty ||
          t.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          t.description.toLowerCase().contains(_searchController.text.toLowerCase());

      return statusMatch && categoryMatch && searchMatch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TIKET SAYA',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.assignment_outlined, color: AppColors.textPrimary, size: 24),
                    onPressed: () {
                      context.read<TicketProvider>().loadTickets(role: role);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Tabs Row
              _buildTabs(),
              const SizedBox(height: 12),

              // Resolution progress card
              _buildProgressCard(ticketProvider.tickets),
              const SizedBox(height: 16),

              // Compact Search & Category filter row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderLight, width: 0.6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Cari judul tiket...',
                          hintStyle: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                          prefixIcon: Icon(Icons.search, size: 18, color: AppColors.textTertiary),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, size: 16, color: AppColors.textTertiary),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: _categoryFilter == 'All' ? 'Kategori' : _categoryFilter,
                    onTap: _showCategoryFilterSheet,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Tickets List
              Expanded(
                child: ticketProvider.isLoading
                    ? const TicketListShimmer()
                    : filteredTickets.isEmpty
                        ? Center(
                            child: Text('Tidak ada tiket yang cocok', style: AppTextStyles.bodyMeta),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: filteredTickets.length,
                            itemBuilder: (context, index) {
                              final t = filteredTickets[index];
                              final shortId = t.id.length > 5 ? t.id.substring(0, 5).toUpperCase() : t.id.toUpperCase();
                              return TicketListCard(
                                ticketCode: '#TCK-$shortId',
                                title: t.title,
                                description: t.description,
                                status: t.status,
                                category: t.category.isEmpty ? 'General' : t.category,
                                categoryIcon: _getCategoryIcon(t.category),
                                priority: t.priority.isEmpty ? 'Medium' : t.priority,
                                date: t.createdAt,
                                onTap: () async {
                                  final tProvider = context.read<TicketProvider>();
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TicketDetailScreen(ticket: t),
                                    ),
                                  );
                                  tProvider.loadTickets(role: role);
                                },
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          border: Border.all(color: AppColors.borderLight, width: 0.6),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
