import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../features/notification/presentation/providers/notification_provider.dart';

class CustomNavbarItem {
  final IconData defaultIcon;
  final IconData activeIcon;
  final String label;
  final bool isNotification;

  CustomNavbarItem({
    required this.defaultIcon,
    required this.activeIcon,
    required this.label,
    this.isNotification = false,
  });
}

class NotchedFloatingClipper extends CustomClipper<Path> {
  final double borderRadius;
  final double notchMargin;

  NotchedFloatingClipper({
    this.borderRadius = 24.0,
    this.notchMargin = 6.0,
  });

  @override
  Path getClip(Size size) {
    final host = Rect.fromLTWH(0, 0, size.width, size.height);
    // The FAB diameter is 56, so radius is 28.
    // The cutout is centered at the top edge of the navigation bar.
    final guest = Rect.fromCircle(
      center: Offset(size.width / 2, 0),
      radius: 28.0 + notchMargin,
    );

    // Rounded rectangle path for the floating bar
    final path1 = Path()
      ..addRRect(RRect.fromRectAndRadius(host, Radius.circular(borderRadius)));

    // Circular notched path
    final path2 = const CircularNotchedRectangle().getOuterPath(host, guest);

    // Intersect both paths to get a rounded rectangle with the notch cutout
    return Path.combine(PathOperation.intersect, path1, path2);
  }

  @override
  bool shouldReclip(covariant NotchedFloatingClipper oldClipper) {
    return oldClipper.borderRadius != borderRadius ||
        oldClipper.notchMargin != notchMargin;
  }
}

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<CustomNavbarItem> items;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final colorScheme = Theme.of(context).colorScheme;
    final barColor = colorScheme.surface;
    final activeColor = colorScheme.primary;
    final inactiveColor = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
    final fabColor = colorScheme.tertiary;
    final fabIconColor = colorScheme.primary;

    return Container(
      height: 96,
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // 1. The Floating Nav Bar
          Positioned(
            left: 20,
            right: 20,
            bottom: 16,
            child: PhysicalShape(
              clipper: NotchedFloatingClipper(
                borderRadius: 24.0,
                notchMargin: 6.0,
              ),
              color: barColor,
              elevation: 8,
              shadowColor: Colors.black.withValues(alpha: 0.12),
              child: SizedBox(
                height: 64,
                child: Row(
                  children: List.generate(5, (index) {
                    if (index == 2) {
                      // Spacer slot for the FAB
                      return const Expanded(
                        child: SizedBox.shrink(),
                      );
                    }

                    final item = items[index];
                    final isSelected = currentIndex == index;

                    Widget iconWidget = AnimatedScale(
                      scale: isSelected ? 1.1 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutBack,
                      child: Icon(
                        isSelected ? item.activeIcon : item.defaultIcon,
                        size: 22,
                        color: isSelected ? activeColor : inactiveColor,
                      ),
                    );

                    if (item.isNotification) {
                      final unreadCount = context.watch<NotificationProvider>().unreadCount;
                      if (unreadCount > 0) {
                        iconWidget = Stack(
                          clipBehavior: Clip.none,
                          children: [
                            iconWidget,
                            Positioned(
                              right: -4,
                              top: -4,
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
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 8,
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
                    }

                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onTap(index);
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            iconWidget,
                            const SizedBox(height: 4),
                            Text(
                              item.label,
                              style: GoogleFonts.poppins(
                                color: isSelected ? activeColor : inactiveColor,
                                fontSize: 10,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),

          // 2. The Center Circular Floating Action Button (Create)
          Positioned(
            bottom: 16 + 64 - 28, // Center on the top edge of the 64-height bar
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                onTap(2);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: fabColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.16),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: fabIconColor,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
