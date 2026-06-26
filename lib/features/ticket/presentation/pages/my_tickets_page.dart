import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:helpdesk_ticket/features/dashboard/presentation/widgets/app_design_tokens.dart';
import 'package:helpdesk_ticket/features/auth/presentation/providers/auth_provider.dart';
import 'package:helpdesk_ticket/features/ticket/presentation/providers/ticket_provider.dart';
import 'package:helpdesk_ticket/features/ticket/presentation/widgets/ticket_list_shimmer.dart';
import 'package:helpdesk_ticket/features/ticket/presentation/pages/ticket_detail_screen.dart';
import '../widgets/ticket_list_card.dart';

/// MY TICKETS PAGE — redesign v2
///
/// Perubahan dari layout lama:
/// - Header biru solid (#1565D8) dengan judul + subtitle, search & filter
///   menyatu di kartu putih yang overlap ke header (konsisten dgn gaya
///   dashboard yang sudah dibuat).
/// - 3 baris filter pill (Status/Priority/Category) dipadatkan jadi 2
///   dropdown compact (Status, Kategori). Priority dipindah jadi dot
///   kecil berwarna di tiap kartu, bukan filter row terpisah.
/// - FAB "+ New Ticket" DIHAPUS — aksi buat tiket sudah ada di bottom
///   navbar (ikon tengah +), jadi tidak perlu duplikat di halaman ini.
/// - "Unassigned" dihapus dari list view (kurang relevan buat User
///   melihat tiketnya sendiri) — tetap bisa ditampilkan di detail page.
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

  void _showStatusFilterSheet() {
    _showFilterSheet(
      title: 'Status',
      options: const ['All', 'Open', 'Process', 'Closed'],
      currentValue: _statusFilter,
      onSelected: (value) => setState(() => _statusFilter = value),
    );
  }

  void _showCategoryFilterSheet() {
    _showFilterSheet(
      title: 'Kategori',
      options: const ['All', 'General', 'Network', 'Hardware', 'Software', 'Account'],
      currentValue: _categoryFilter,
      onSelected: (value) => setState(() => _categoryFilter = value),
    );
  }

  void _showFilterSheet({
    required String title,
    required List<String> options,
    required String currentValue,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(title, style: AppTextStyles.sectionHeading),
                ),
                const SizedBox(height: 8),
                ...options.map(
                  (opt) => ListTile(
                    dense: true,
                    title: Text(opt, style: const TextStyle(fontSize: 13)),
                    trailing: opt == currentValue
                        ? const Icon(Icons.check, size: 18, color: AppColors.primary)
                        : null,
                    onTap: () {
                      onSelected(opt);
                      Navigator.pop(context);
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
        } else if (f == 'process') {
          statusMatch = s == 'process' || s == 'pending' || s == 'in_progress';
        } else if (f == 'closed') {
          statusMatch = s == 'closed' || s == 'done' || s == 'resolved';
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
        child: Column(
          children: [
            // Header biru solid
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              color: AppColors.primaryDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tiket Saya',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
                        onPressed: () {
                          context.read<TicketProvider>().loadTickets(role: role);
                        },
                      ),
                    ],
                  ),
                  Text(
                    'Kelola dan pantau semua laporanmu',
                    style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.75)),
                  ),
                ],
              ),
            ),

            // Search & filter — overlap ke atas header sedikit
            Transform.translate(
              offset: const Offset(0, -10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.bgPage,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(fontSize: 13),
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
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _FilterChip(
                            label: 'Status: $_statusFilter',
                            onTap: _showStatusFilterSheet,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _FilterChip(
                            label: 'Kategori: $_categoryFilter',
                            onTap: _showCategoryFilterSheet,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: ticketProvider.isLoading
                  ? const TicketListShimmer()
                  : filteredTickets.isEmpty
                      ? Center(
                          child: Text('Tidak ada tiket yang cocok', style: AppTextStyles.bodyMeta),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: filteredTickets.length,
                          itemBuilder: (context, index) {
                            final t = filteredTickets[index];
                            final shortId = t.id.length > 5 ? t.id.substring(0, 5).toUpperCase() : t.id.toUpperCase();
                            return TicketListCard(
                              ticketCode: '#TCK-$shortId',
                              title: t.title,
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
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderLight, width: 0.6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 11, color: AppColors.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down, size: 15, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
