import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../main.dart';
import '../../../ticket/presentation/pages/ticket_detail_screen.dart';
import '../../../ticket/presentation/providers/ticket_provider.dart';

class InAppNotificationToast {
  static void show({
    required String title,
    required String message,
    String? ticketId,
  }) {
    final overlayState = navigatorKey.currentState?.overlay;
    if (overlayState == null) return;

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _InAppNotificationToastWidget(
        title: title,
        message: message,
        ticketId: ticketId,
        onDismiss: () {
          overlayEntry.remove();
        },
      ),
    );

    overlayState.insert(overlayEntry);
  }
}

class _InAppNotificationToastWidget extends StatefulWidget {
  final String title;
  final String message;
  final String? ticketId;
  final VoidCallback onDismiss;

  const _InAppNotificationToastWidget({
    required this.title,
    required this.message,
    this.ticketId,
    required this.onDismiss,
  });

  @override
  State<_InAppNotificationToastWidget> createState() =>
      __InAppNotificationToastWidgetState();
}

class __InAppNotificationToastWidgetState
    extends State<_InAppNotificationToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  Timer? _dismissTimer;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    _dismissTimer = Timer(const Duration(seconds: 3, milliseconds: 500), () {
      _dismiss();
    });
  }

  Future<void> _dismiss() async {
    if (_isDismissing || !mounted) return;
    setState(() {
      _isDismissing = true;
    });
    _dismissTimer?.cancel();
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                width: double.infinity,
                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    if (details.primaryDelta! < -8) {
                      _dismiss();
                    }
                  },
                  onTap: () async {
                    if (widget.ticketId != null) {
                      final targetTicketId = widget.ticketId!;
                      // Dismiss immediately
                      _dismiss();

                      // Navigate to ticket detail
                      final context = navigatorKey.currentContext;
                      if (context != null && context.mounted) {
                        try {
                          final ticketProvider = context.read<TicketProvider>();
                          final ticket = await ticketProvider.getTicketById(targetTicketId);
                          if (ticket != null && context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TicketDetailScreen(ticket: ticket),
                              ),
                            );
                          }
                        } catch (e) {
                          debugPrint("Error navigating from notification toast: $e");
                        }
                      }
                    } else {
                      _dismiss();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.black.withOpacity(0.08),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Dynamic Bell Icon
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_active_rounded,
                            color: Color(0xFF2563EB),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Title & Body text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.message,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563),
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Drag Indicator
                        Icon(
                          Icons.drag_handle_rounded,
                          color: isDark ? Colors.white24 : Colors.black26,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
