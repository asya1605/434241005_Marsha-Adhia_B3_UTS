import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'custom_bottom_nav_bar.dart';
import 'navigation_notifications.dart';

import '../features/dashboard/presentation/pages/user_dashboard.dart';
import '../features/ticket/presentation/pages/my_tickets_page.dart';
import '../features/ticket/presentation/pages/create_ticket_screen.dart';
import '../features/notification/presentation/pages/notification_screen.dart';
import '../features/profile/presentation/pages/profile_screen.dart';
import '../features/notification/presentation/providers/notification_provider.dart';
import '../features/auth/presentation/providers/auth_provider.dart';

class UserNavigation extends StatefulWidget {
  const UserNavigation({super.key});

  @override
  State<UserNavigation> createState() => _UserNavigationState();
}

class _UserNavigationState extends State<UserNavigation> {
  int currentIndex = 0;

  final List pages = [
    const UserDashboard(),
    const MyTicketsPage(),
    const CreateTicketScreen(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<TabSwitchNotification>(
        onNotification: (notification) {
          setState(() {
            currentIndex = notification.targetIndex;
          });
          return true;
        },
        child: pages[currentIndex],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: [
          CustomNavbarItem(
            defaultIcon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'Beranda',
          ),
          CustomNavbarItem(
            defaultIcon: Icons.list_alt_outlined,
            activeIcon: Icons.list_alt_rounded,
            label: 'Tiket Saya',
          ),
          CustomNavbarItem(
            defaultIcon: Icons.add_circle_outline_rounded,
            activeIcon: Icons.add_circle_rounded,
            label: 'Buat Tiket',
          ),
          CustomNavbarItem(
            defaultIcon: Icons.notifications_outlined,
            activeIcon: Icons.notifications_rounded,
            label: 'Notifikasi',
            isNotification: true,
          ),
          CustomNavbarItem(
            defaultIcon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}