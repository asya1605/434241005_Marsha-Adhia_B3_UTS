import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../features/dashboard/presentation/pages/admin_dashboard.dart';
import '../features/ticket/presentation/pages/ticket_list_screen.dart';
import '../features/notification/presentation/pages/notification_screen.dart';
import '../features/profile/presentation/pages/profile_screen.dart';
import '../features/notification/presentation/providers/notification_provider.dart';
import '../features/auth/presentation/providers/auth_provider.dart';

class AdminNavigation extends StatefulWidget {
  const AdminNavigation({super.key});

  @override
  State<AdminNavigation> createState() => _AdminNavigationState();
}

class _AdminNavigationState extends State<AdminNavigation> {
  int currentIndex = 0;

  final List pages = [
    const AdminDashboard(),
    const TicketListScreen(),
    const NotificationScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      final notifProvider = context.read<NotificationProvider>();
      if (auth.userId != null &&
          notifProvider.notificationStream == null) {
        notifProvider.initNotifications(auth.userId!);
      }
    });
  }

  Widget _buildTabItem({
    required IconData defaultIcon,
    required IconData activeIcon,
    required String label,
    required int index,
    bool isNotification = false,
    double iconSize = 22,
  }) {
    final isSelected = currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget iconWidget = AnimatedScale(
      scale: isSelected ? 1.15 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      child: Icon(
        isSelected ? activeIcon : defaultIcon,
        size: iconSize,
        color: isSelected
            ? const Color(0xFF2563EB)
            : (isDark ? Colors.white30 : const Color(0xFF94A3B8)),
      ),
    );

    if (isNotification) {
      final unreadCount = context.watch<NotificationProvider>().unreadCount;
      iconWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          iconWidget,
          if (unreadCount > 0)
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Center(
                  child: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    }

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() {
            currentIndex = index;
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: iconWidget,
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 16,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.15),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOut,
                      )),
                      child: child,
                    ),
                  );
                },
                child: isSelected
                    ? Text(
                        label,
                        key: ValueKey(label),
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF2563EB),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('empty')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161B2E) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 66,
            child: Row(
              children: [
                _buildTabItem(
                  defaultIcon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard_rounded,
                  label: 'Dashboard',
                  index: 0,
                ),
                _buildTabItem(
                  defaultIcon: Icons.list_alt_outlined,
                  activeIcon: Icons.list_alt_rounded,
                  label: 'Tickets',
                  index: 1,
                ),
                _buildTabItem(
                  defaultIcon: Icons.notifications_outlined,
                  activeIcon: Icons.notifications_rounded,
                  label: 'Notif',
                  index: 2,
                  isNotification: true,
                ),
                _buildTabItem(
                  defaultIcon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Profile',
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}