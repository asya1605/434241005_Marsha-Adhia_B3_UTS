import 'package:flutter/material.dart';

class ProfileItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ProfileItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Logout gets special destructive styling
    final bool isDestructive = title.toLowerCase().contains('logout') ||
        title.toLowerCase().contains('delete') ||
        title.toLowerCase().contains('remove');

    final Color iconColor = isDestructive
        ? const Color(0xFFEF4444)
        : isDark
            ? const Color(0xFF94A3B8)
            : const Color(0xFF64748B);

    final Color iconBg = isDestructive
        ? const Color(0xFFEF4444).withOpacity(0.1)
        : isDark
            ? const Color(0xFF1E2438)
            : const Color(0xFFF1F5F9);

    final Color titleColor = isDestructive
        ? const Color(0xFFEF4444)
        : isDark
            ? Colors.white
            : const Color(0xFF111827);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              /// Icon box
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),

              const SizedBox(width: 14),

              /// Title
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
              ),

              /// Arrow
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: isDestructive
                    ? const Color(0xFFEF4444).withOpacity(0.5)
                    : isDark
                        ? Colors.white24
                        : const Color(0xFFCBD5E1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}