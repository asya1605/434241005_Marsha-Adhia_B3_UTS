import 'package:flutter/material.dart';
import '../../data/models/notification_model.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;

  const NotificationTile({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isUnread = !notification.isRead;

    return Container(
      decoration: BoxDecoration(
        color: isUnread
            ? isDark
                ? const Color(0xFF1A2340)
                : const Color(0xFFEFF6FF)
            : isDark
                ? const Color(0xFF161B2E)
                : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread
              ? isDark
                  ? const Color(0xFF2563EB).withOpacity(0.3)
                  : const Color(0xFF2563EB).withOpacity(0.2)
              : isDark
                  ? Colors.white.withOpacity(0.06)
                  : const Color(0xFFE5E7EB),
          width: 1,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Icon box
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isUnread
                  ? const Color(0xFF2563EB).withOpacity(0.12)
                  : isDark
                      ? const Color(0xFF1E2438)
                      : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.notifications_outlined,
              size: 18,
              color: isUnread
                  ? const Color(0xFF2563EB)
                  : isDark
                      ? Colors.white38
                      : const Color(0xFF94A3B8),
            ),
          ),

          const SizedBox(width: 12),

          /// Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Title
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isUnread
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF111827),
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),

                    /// Unread dot
                    if (isUnread) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2563EB),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 5),

                /// Message
                Text(
                  notification.message,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? Colors.white54
                        : const Color(0xFF6B7280),
                    height: 1.45,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}