import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final userId = context.read<AuthProvider>().userId;

      if (userId != null) {
        context.read<NotificationProvider>().initNotifications(userId);
      } else {
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F1117) : const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF161B2E) : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF111827),
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          StreamBuilder<List<NotificationModel>>(
            stream: provider.notificationStream,
            builder: (context, snapshot) {
              // Update cache if new data arrives
              if (snapshot.hasData) {
                provider.cachedNotifications = snapshot.data!;
              }

              final count = snapshot.data?.length ?? provider.cachedNotifications.length;

              if (count > 0) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
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
      body: StreamBuilder<List<NotificationModel>>(
        stream: provider.notificationStream,
        builder: (context, snapshot) {
          print("📡 SNAPSHOT DATA: ${snapshot.data}");
          print("📡 SNAPSHOT ERROR: ${snapshot.error}");

          // Update cache if new data arrives successfully
          if (snapshot.hasData) {
            provider.cachedNotifications = snapshot.data!;
          }

          if (snapshot.connectionState == ConnectionState.waiting && provider.cachedNotifications.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2563EB),
                strokeWidth: 2.5,
              ),
            );
          }

          if (snapshot.hasError) {
             return Column(
               children: [
                 Container(
                   width: double.infinity,
                   padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                   color: Colors.redAccent.withOpacity(0.1),
                   child: Row(
                     children: [
                       const Icon(Icons.wifi_off_rounded, size: 16, color: Colors.redAccent),
                       const SizedBox(width: 8),
                       Text(
                         "Koneksi realtime terputus",
                         style: TextStyle(color: Colors.redAccent.shade700, fontSize: 12, fontWeight: FontWeight.w600),
                       ),
                     ],
                   ),
                 ),
                 Expanded(child: _buildBodyContent(provider.cachedNotifications, isDark, snapshot.connectionState)),
               ],
             );
          }

          final notifications = snapshot.data ?? provider.cachedNotifications;
          return _buildBodyContent(notifications, isDark, snapshot.connectionState);
        },
      ),
    );
  }

  Widget _buildBodyContent(List<NotificationModel> notifications, bool isDark, ConnectionState connectionState) {
    /// empty state
    if (notifications.isEmpty && connectionState != ConnectionState.active) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E2438)
                      : const Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_off_outlined,
                  size: 32,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Belum ada notifikasi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You have no notifications at the moment.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color:
                      isDark ? Colors.white38 : const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ),
      );
    }

    /// list notification
    return Column(
      children: [
        /// ── Count bar ──────────────────────────────────────────────
        Container(
          color: isDark ? const Color(0xFF161B2E) : Colors.white,
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Text(
                '${notifications.length} notification${notifications.length > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? Colors.white60
                      : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : const Color(0xFFE5E7EB),
        ),

        /// ── List ───────────────────────────────────────────────────
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return NotificationTile(notification: notif);
            },
          ),
        ),
      ],
    );
  }
}
