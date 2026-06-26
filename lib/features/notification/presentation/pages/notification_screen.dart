import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../dashboard/presentation/widgets/app_design_tokens.dart';
import '../providers/notification_provider.dart';
import 'package:helpdesk_ticket/features/auth/presentation/providers/auth_provider.dart';
import 'package:helpdesk_ticket/features/notification/data/models/notification_model.dart';
import 'package:helpdesk_ticket/features/ticket/presentation/providers/ticket_provider.dart';
import 'package:helpdesk_ticket/features/ticket/presentation/pages/ticket_detail_screen.dart';

/// NOTIFICATIONS PAGE — redesign v2
///
/// Konsisten dengan pola My Tickets: header biru solid (#1565D8),
/// FAB dihapus (sudah ada di navbar), card list dengan border tipis.
///
/// Catatan untuk rapi-rapi lanjutan: spacing/alignment di sini SUDAH
/// dibuat seragam (lihat AppSpacing di app_design_tokens.dart) — kalau
/// hasil render masih berantakan di environment asli, kemungkinan besar
/// karena ada style lama yang masih nge-override dari parent widget/theme.
/// Cek ThemeData global (textTheme, cardTheme) untuk konflik sebelum
/// menambah override baru di sini.
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

enum _NotifFilter { all, unread, read }

class _NotificationScreenState extends State<NotificationScreen> {
  _NotifFilter _filter = _NotifFilter.all;

  @override
  void initState() {
    super.initState();

    final authProvider = context.read<AuthProvider>();
    final notificationProvider = context.read<NotificationProvider>();
    Future.microtask(() {
      final userId = authProvider.userId;
      if (userId != null) {
        notificationProvider.initNotifications(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ===== Header biru =====
            Container(
              color: AppColors.primaryDark,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Notifikasi',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white, height: 1),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          final unreadIds = provider.cachedNotifications
                              .where((n) => !n.isRead)
                              .map((n) => n.id)
                              .toList();
                          if (unreadIds.isNotEmpty) {
                            provider.markAllAsRead(unreadIds);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Semua notifikasi ditandai dibaca',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Baca semua',
                          style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.9), height: 1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Update terbaru seputar tiketmu',
                    style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.75), height: 1.3),
                  ),
                ],
              ),
            ),

            // ===== Tab filter — overlap ke atas header sedikit =====
            Transform.translate(
              offset: const Offset(0, -10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    _buildTab('Semua', _NotifFilter.all),
                    const SizedBox(width: AppSpacing.sm),
                    _buildTab('Belum dibaca', _NotifFilter.unread),
                    const SizedBox(width: AppSpacing.sm),
                    _buildTab('Dibaca', _NotifFilter.read),
                  ],
                ),
              ),
            ),

            // ===== List =====
            Expanded(
              child: !provider.hasInitialData && provider.cachedNotifications.isEmpty
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryDark,
                        strokeWidth: 2.5,
                      ),
                    )
                  : _buildBodyContent(provider.cachedNotifications),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, _NotifFilter value) {
    final isActive = _filter == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _filter = value),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryDark : Colors.transparent,
            border: isActive ? null : Border.all(color: AppColors.borderLight, width: 0.6),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              height: 1,
              color: isActive ? Colors.white : AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBodyContent(List<NotificationModel> notifications) {
    final filtered = notifications.where((n) {
      if (_filter == _NotifFilter.unread) return !n.isRead;
      if (_filter == _NotifFilter.read) return n.isRead;
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text('Tidak ada notifikasi', style: AppTextStyles.bodyMeta),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
          child: Text(
            '${filtered.length} notifikasi',
            style: AppTextStyles.caption.copyWith(height: 1),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg,
            ),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final n = filtered[index];
              return Dismissible(
                key: Key(n.id),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  context.read<NotificationProvider>().deleteNotification(n.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Notifikasi berhasil dihapus',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(AppRadius.card),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                child: _NotificationCard(notif: n),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _NotificationCard extends StatefulWidget {
  final NotificationModel notif;

  const _NotificationCard({required this.notif});

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard> {
  bool _isLoading = false;

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return months[month - 1];
  }

  Future<void> _handleTap(BuildContext context) async {
    final notificationProvider = context.read<NotificationProvider>();
    final ticketProvider = context.read<TicketProvider>();
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // 1. Mark as read immediately if unread
    if (!widget.notif.isRead) {
      notificationProvider.markAsRead(widget.notif.id);
    }

    // 2. Fetch ticket and navigate to details if ticketId exists
    final ticketId = widget.notif.ticketId;
    if (ticketId == null || ticketId.isEmpty || ticketId == 'null') {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final ticket = await ticketProvider.getTicketById(ticketId);
      if (!mounted) return;

      if (ticket != null) {
        navigator.push(
          MaterialPageRoute(
            builder: (_) => TicketDetailScreen(ticket: ticket),
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: const Text(
              'Tiket sudah tidak tersedia atau telah dihapus.',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              'Gagal memuat detail tiket: $e',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final parsedDate = DateTime.tryParse(widget.notif.createdAt)?.toLocal() ?? DateTime.now();
    final dateStr = '${parsedDate.day} ${_monthName(parsedDate.month)} ${parsedDate.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: widget.notif.isRead ? AppColors.bgCard : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: widget.notif.isRead ? AppColors.borderLight : const Color(0xFFB5D4F4),
          width: 0.6,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : () => _handleTap(context),
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Stack(
              children: [
                if (!widget.notif.isRead)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: AppColors.primaryDark, shape: BoxShape.circle),
                    ),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: _isLoading
                          ? Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryDark,
                              ),
                            )
                          : Icon(Icons.notifications_outlined, size: 15, color: AppColors.primaryDark),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.notif.title,
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.3, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              widget.notif.message,
                              style: TextStyle(fontSize: 11, height: 1.4, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 3),
                            Text(dateStr, style: AppTextStyles.caption.copyWith(height: 1.3)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
