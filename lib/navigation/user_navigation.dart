import 'package:flutter/material.dart';

import '../features/dashboard/presentation/pages/dashboard_screen.dart';
import '../features/ticket/presentation/pages/ticket_list_screen.dart';
import '../features/ticket/presentation/pages/create_ticket_screen.dart';
import '../features/notification/presentation/pages/notification_screen.dart';
import '../features/profile/presentation/pages/profile_screen.dart';

class UserNavigation extends StatefulWidget {
  const UserNavigation({super.key});

  @override
  State<UserNavigation> createState() => _UserNavigationState();
}

class _UserNavigationState extends State<UserNavigation> {
  int currentIndex = 0;

  final List pages = [
    const DashboardScreen(),
    const TicketListScreen(),
    const CreateTicketScreen(),
    const NotificationScreen(),
    const ProfileScreen(),
  ];

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
                  ? Colors.white.withOpacity(0.06)
                  : const Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF2563EB),
          unselectedItemColor:
              isDark ? Colors.white30 : const Color(0xFF94A3B8),
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.home_outlined, size: 22),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.home_rounded, size: 22),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.list_alt_outlined, size: 22),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.list_alt_rounded, size: 22),
              ),
              label: 'My Tickets',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.add_circle_outline_rounded, size: 26),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.add_circle_rounded, size: 26),
              ),
              label: 'Create',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.notifications_outlined, size: 22),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.notifications_rounded, size: 22),
              ),
              label: 'Notif',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.person_outline_rounded, size: 22),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.person_rounded, size: 22),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}