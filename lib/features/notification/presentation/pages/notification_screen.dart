import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/notification_provider.dart';
import '../widgets/notification_tile.dart';
import 'package:helpdesk_ticket/features/auth/presentation/providers/auth_provider.dart';
import 'package:helpdesk_ticket/features/notification/data/models/notification_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _filter = 'All'; // 'All', 'Unread', 'Read'

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final userId = context.read<AuthProvider>().userId;
      if (userId != null) {
        context.read<NotificationProvider>().initNotifications(userId);
      }
    });
  }

  Widget _buildFilterChips(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: isDark ? const Color(0xFF0F1117) : const Color(0xFFF4F6FA),
      child: Row(
        children: [
          _buildFilterChip('All', 'Semua', isDark),
          const SizedBox(width: 8),
          _buildFilterChip('Unread', 'Belum Dibaca', isDark),
          const SizedBox(width: 8),
          _buildFilterChip('Read', 'Dibaca', isDark),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterType, String label, bool isDark) {
    final isSelected = _filter == filterType;
    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 12.5,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected
              ? Colors.white
              : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(0xFF2563EB),
      backgroundColor: isDark ? const Color(0xFF1E293B).withOpacity(0.5) : Colors.white,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _filter = filterType;
          });
        }
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? const Color(0xFF2563EB)
              : (isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFE2E8F0)),
          width: 1.2,
        ),
      ),
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F1117) : const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF111827) : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black12,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          'Notifications',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF111827),
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          StreamBuilder<List<NotificationModel>>(
            stream: provider.notificationStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                provider.cachedNotifications = snapshot.data!;
              }

              final list = snapshot.data ?? provider.cachedNotifications;
              final unreadCount = list.where((n) => !n.isRead).length;

              if (unreadCount > 0) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton.icon(
                    onPressed: () {
                      final unreadIds = list.where((n) => !n.isRead).map((n) => n.id).toList();
                      if (unreadIds.isNotEmpty) {
                        provider.markAllAsRead(unreadIds);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Semua notifikasi ditandai dibaca',
                              style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                            ),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.done_all_rounded,
                      size: 18,
                      color: Color(0xFF2563EB),
                    ),
                    label: Text(
                      'Baca Semua',
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : const Color(0xFFE5E7EB),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterChips(isDark),
          Expanded(
            child: StreamBuilder<List<NotificationModel>>(
              stream: provider.notificationStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  provider.cachedNotifications = snapshot.data!;
                }

                if (snapshot.connectionState == ConnectionState.waiting &&
                    provider.cachedNotifications.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF2563EB),
                      strokeWidth: 2.5,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  debugPrint("Realtime stream error: ${snapshot.error}");
                }

                final notifications =
                    snapshot.data ?? provider.cachedNotifications;
                return _buildBodyContent(
                  notifications,
                  isDark,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent(List<NotificationModel> notifications, bool isDark) {
    // Apply client-side filter
    final filtered = notifications.where((n) {
      if (_filter == 'Unread') return !n.isRead;
      if (_filter == 'Read') return n.isRead;
      return true;
    }).toList();

    /// empty state
    if (filtered.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/empty_notification.png',
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                Text(
                  'Belum Ada Notifikasi',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Notifikasi baru akan muncul di sini.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    /// list notification
    return Column(
      children: [
        /// ── Count bar ──────────────────────────────────────────────
        Container(
          color: isDark ? const Color(0xFF0F1117) : const Color(0xFFF4F6FA),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Text(
                '${filtered.length} notifikasi${_filter == 'Unread' ? ' belum dibaca' : _filter == 'Read' ? ' dibaca' : ''}',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),

        /// ── List ───────────────────────────────────────────────────
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final notif = filtered[index];
              return Dismissible(
                key: Key(notif.id),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  context
                      .read<NotificationProvider>()
                      .deleteNotification(notif.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Notifikasi berhasil dihapus',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
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
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                child: NotificationTile(notification: notif),
              );
            },
          ),
        ),
      ],
    );
  }
}
