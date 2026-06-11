import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/notification_model.dart';
import '../providers/notification_provider.dart';
import '../../../ticket/presentation/providers/ticket_provider.dart';
import '../../../ticket/presentation/pages/ticket_detail_screen.dart';

class NotificationTile extends StatefulWidget {
  final NotificationModel notification;

  const NotificationTile({
    super.key,
    required this.notification,
  });

  @override
  State<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile> {
  bool _isLoading = false;

  IconData _getIcon(String title) {
    final t = title.toLowerCase();
    if (t.contains('assigned') || t.contains('ditugaskan')) {
      return Icons.assignment_ind_outlined;
    }
    if (t.contains('done') || t.contains('resolve') || t.contains('close') || t.contains('selesai')) {
      return Icons.check_circle_outline_rounded;
    }
    if (t.contains('comment') || t.contains('pesan') || t.contains('balasan') || t.contains('komentar')) {
      return Icons.chat_bubble_outline_rounded;
    }
    return Icons.notifications_outlined;
  }

  Color _getIconColor(String title) {
    final t = title.toLowerCase();
    if (t.contains('assigned') || t.contains('ditugaskan')) {
      return const Color(0xFF2563EB); // Blue
    }
    if (t.contains('done') || t.contains('resolve') || t.contains('close') || t.contains('selesai')) {
      return const Color(0xFF10B981); // Green
    }
    if (t.contains('comment') || t.contains('pesan') || t.contains('balasan') || t.contains('komentar')) {
      return const Color(0xFFF59E0B); // Amber
    }
    return const Color(0xFF2563EB);
  }

  String _formatTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'Baru saja';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m lalu';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}j lalu';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}h lalu';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (_) {
      return '';
    }
  }

  Future<void> _handleTap(BuildContext context) async {
    // 1. Mark as read immediately if unread
    if (!widget.notification.isRead) {
      context.read<NotificationProvider>().markAsRead(widget.notification.id);
    }

    // 2. Fetch ticket and navigate to details if ticketId exists
    final ticketId = widget.notification.ticketId;
    if (ticketId == null || ticketId.isEmpty || ticketId == 'null') {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final ticket = await context.read<TicketProvider>().getTicketById(ticketId);
      if (!mounted) return;

      if (ticket != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TicketDetailScreen(ticket: ticket),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Tiket sudah tidak tersedia atau telah dihapus.',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal memuat detail tiket: $e',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isUnread = !widget.notification.isRead;
    final color = _getIconColor(widget.notification.title);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _isLoading ? null : () => _handleTap(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: isUnread
                ? isDark
                    ? const Color(0xFF1E293B).withOpacity(0.4)
                    : const Color(0xFFEFF6FF).withOpacity(0.7)
                : isDark
                    ? const Color(0xFF1E293B).withOpacity(0.15)
                    : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUnread
                  ? isDark
                      ? const Color(0xFF2563EB).withOpacity(0.35)
                      : const Color(0xFF2563EB).withOpacity(0.18)
                  : isDark
                      ? Colors.white.withOpacity(0.05)
                      : const Color(0xFFE2E8F0),
              width: 1.2,
            ),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Icon box / Loader
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isUnread
                      ? color.withOpacity(0.12)
                      : isDark
                          ? const Color(0xFF334155).withOpacity(0.3)
                          : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: _isLoading
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: color,
                          ),
                        )
                      : Icon(
                          _getIcon(widget.notification.title),
                          size: 20,
                          color: isUnread
                              ? color
                              : isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                        ),
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
                            widget.notification.title,
                            style: GoogleFonts.outfit(
                              fontSize: 14.5,
                              fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                              letterSpacing: -0.1,
                            ),
                          ),
                        ),

                        /// Unread dot or Time
                        if (isUnread) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 5),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 4),

                    /// Message
                    Text(
                      widget.notification.message,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    /// Time indicator at the bottom of the card content
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatTime(widget.notification.createdAt),
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                          ),
                        ),
                        if (widget.notification.ticketId != null && 
                            widget.notification.ticketId!.isNotEmpty && 
                            widget.notification.ticketId != 'null')
                          Row(
                            children: [
                              Text(
                                'Buka Tiket',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: color,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 8,
                                color: color,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}