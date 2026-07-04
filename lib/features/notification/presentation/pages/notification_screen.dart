import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../dashboard/presentation/widgets/app_design_tokens.dart';
import '../providers/notification_provider.dart';
import 'package:helpdesk_ticket/features/auth/presentation/providers/auth_provider.dart';
import 'package:helpdesk_ticket/features/notification/data/models/notification_model.dart';
import 'package:helpdesk_ticket/features/ticket/presentation/providers/ticket_provider.dart';
import 'package:helpdesk_ticket/features/ticket/presentation/pages/ticket_detail_screen.dart';

/// NOTIFICATIONS PAGE — redesigned premium card-based layout
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

enum _NotifFilter { all, unread, read }

class _ListItem {
  final String? headerTitle;
  final NotificationModel? notification;

  _ListItem.header(this.headerTitle) : notification = null;
  _ListItem.item(this.notification) : headerTitle = null;

  bool get isHeader => headerTitle != null;
}

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

  String _getSectionHeader(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (checkDate == today) {
      return 'Today';
    } else if (checkDate == yesterday) {
      return 'Yesterday';
    } else {
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
    }
  }

  List<_ListItem> _buildListItems(List<NotificationModel> notifications) {
    final Map<String, List<NotificationModel>> groups = {};
    for (final n in notifications) {
      final parsedDate = DateTime.tryParse(n.createdAt)?.toLocal() ?? DateTime.now();
      final header = _getSectionHeader(parsedDate);
      groups.putIfAbsent(header, () => []).add(n);
    }

    final List<_ListItem> listItems = [];
    groups.forEach((header, notifs) {
      listItems.add(_ListItem.header(header));
      for (final notif in notifs) {
        listItems.add(_ListItem.item(notif));
      }
    });

    return listItems;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final onSurfaceColor = isDark ? Colors.white : Theme.of(context).colorScheme.onSurface;
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ===== Custom App Bar / Header Row =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  if (Navigator.canPop(context))
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: onSurfaceColor, size: 20),
                      onPressed: () => Navigator.pop(context),
                    )
                  else
                    const SizedBox(width: 48),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: onSurfaceColor,
                        ),
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert_rounded, color: onSurfaceColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (val) {
                      if (val == 'read_all') {
                        final unreadIds = provider.cachedNotifications
                            .where((n) => !n.isRead)
                            .map((n) => n.id)
                            .toList();
                        if (unreadIds.isNotEmpty) {
                          provider.markAllAsRead(unreadIds);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Semua notifikasi ditandai dibaca'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        }
                      } else if (val == 'clear_all') {
                        final ids = provider.cachedNotifications.map((n) => n.id).toList();
                        if (ids.isNotEmpty) {
                          for (final id in ids) {
                            provider.deleteNotification(id);
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Semua notifikasi berhasil dihapus'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        }
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'read_all',
                        child: Text('Tandai semua dibaca', style: TextStyle(fontSize: 13)),
                      ),
                      const PopupMenuItem<String>(
                        value: 'clear_all',
                        child: Text('Bersihkan semua', style: TextStyle(fontSize: 13, color: Colors.redAccent)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ===== Segmented Pill Selector =====
            _buildFilterChips(),

            // ===== List View =====
            Expanded(
              child: !provider.hasInitialData && provider.cachedNotifications.isEmpty
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
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

  Widget _buildFilterChips() {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E293B)
            : Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          _buildFilterPill('Semua', _NotifFilter.all),
          _buildFilterPill('Belum Dibaca', _NotifFilter.unread),
          _buildFilterPill('Dibaca', _NotifFilter.read),
        ],
      ),
    );
  }

  Widget _buildFilterPill(String label, _NotifFilter value) {
    final isSelected = _filter == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _filter = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected
                ? (Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF334155)
                    : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? (isDark ? Colors.white : Theme.of(context).colorScheme.primary)
                  : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBodyContent(List<NotificationModel> notifications) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = notifications.where((n) {
      if (_filter == _NotifFilter.unread) return !n.isRead;
      if (_filter == _NotifFilter.read) return n.isRead;
      return true;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada notifikasi',
              style: AppTextStyles.bodyMeta.copyWith(fontSize: 14),
            ),
          ],
        ),
      );
    }

    final listItems = _buildListItems(filtered);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: listItems.length,
      itemBuilder: (context, index) {
        final item = listItems[index];
        if (item.isHeader) {
          return Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 10, left: 4),
            child: Text(
              item.headerTitle!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          );
        }

        final n = item.notification!;
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
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16),
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

  Map<String, dynamic> _getNotifStyle(NotificationModel notif) {
    final title = notif.title.toLowerCase();
    final message = notif.message.toLowerCase();

    if (title.contains('cancel') || title.contains('batal') || message.contains('cancel') || message.contains('batal')) {
      return {
        'bg': const Color(0xFFFFF2E8),
        'iconColor': const Color(0xFFFA541C),
        'icon': Icons.calendar_today_rounded,
      };
    } else if (title.contains('complete') || title.contains('selesai') || message.contains('complete') || message.contains('selesai')) {
      return {
        'bg': const Color(0xFFF6FFED),
        'iconColor': const Color(0xFF52C41A),
        'icon': Icons.calendar_today_rounded,
      };
    } else if (title.contains('welcome') || title.contains('selamat datang') || message.contains('welcome')) {
      final primary = Theme.of(context).colorScheme.primary;
      return {
        'bg': primary.withValues(alpha: 0.1),
        'iconColor': primary,
        'icon': Icons.face_retouching_natural_rounded,
      };
    } else {
      final primary = Theme.of(context).colorScheme.primary;
      return {
        'bg': primary.withValues(alpha: 0.1),
        'iconColor': primary,
        'icon': Icons.notifications_active_outlined,
      };
    }
  }

  Widget _buildLeadingIcon(NotificationModel notif) {
    final style = _getNotifStyle(notif);
    final IconData mainIcon = style['icon'] as IconData;
    final Color iconColor = style['iconColor'] as Color;
    final Color bg = style['bg'] as Color;

    Widget? badge;
    final title = notif.title.toLowerCase();
    final message = notif.message.toLowerCase();

    if (title.contains('cancel') || title.contains('batal') || message.contains('cancel') || message.contains('batal')) {
      badge = Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: Color(0xFFFA541C),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.close_rounded,
            size: 8,
            color: Colors.white,
          ),
        ),
      );
    } else if (title.contains('complete') || title.contains('selesai') || message.contains('complete') || message.contains('selesai')) {
      badge = Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: Color(0xFF52C41A),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 8,
            color: Colors.white,
          ),
        ),
      );
    }

    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? iconColor.withValues(alpha: 0.15)
                  : bg,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: _isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : Icon(
                    mainIcon,
                    color: iconColor,
                    size: 22,
                  ),
          ),
          ?badge,
        ],
      ),
    );
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

  String _formatTime(DateTime dateTime) {
    int hour = dateTime.hour;
    int minute = dateTime.minute;
    String ampm = hour >= 12 ? 'PM' : 'AM';
    hour = hour % 12;
    hour = hour == 0 ? 12 : hour;
    String hourStr = hour.toString().padLeft(2, '0');
    String minuteStr = minute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final parsedDate = DateTime.tryParse(widget.notif.createdAt)?.toLocal() ?? DateTime.now();
    final timeStr = _formatTime(parsedDate);

    final title = widget.notif.title;
    final message = widget.notif.message;
    final isWelcome = title.toLowerCase().contains('welcome') || message.toLowerCase().contains('welcome');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.notif.isRead
              ? (isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB))
              : Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
          width: widget.notif.isRead ? 0.6 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : () => _handleTap(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLeadingIcon(widget.notif),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Theme.of(context).colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            timeStr,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          height: 1.4,
                        ),
                      ),
                      if (isWelcome) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Memulai tour...'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                'Take a tour',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Tour dilewati'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Theme.of(context).colorScheme.primary,
                                side: BorderSide(color: Theme.of(context).colorScheme.primary),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                'No, thanks!',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        )
                      ],
                    ],
                  ),
                ),
                if (!widget.notif.isRead) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}

