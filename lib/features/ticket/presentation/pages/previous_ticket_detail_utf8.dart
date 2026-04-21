import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/ticket_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class TicketDetailScreen extends StatefulWidget {
  final TicketModel ticket;

  const TicketDetailScreen({
    super.key,
    required this.ticket,
  });

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final TextEditingController commentController = TextEditingController();

  List<String> comments = [];

  String selectedStatus = "Open";
  String assignedHelpdesk = "None";

  final List<String> statusList = ["Open", "Pending", "Closed"];

  final List<String> helpdeskList = ["None", "Helpdesk A", "Helpdesk B"];

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.ticket.status;
  }


  Widget buildTracking(String status) {
    List<String> steps = ["Ticket Created"];

    if (status == "Pending" || status == "Closed") {
      steps.add("Being Processed");
    }

    if (status == "Closed") {
      steps.add("Resolved");
    }

    // All possible steps for timeline rendering
    final List<Map<String, dynamic>> allSteps = [
      {
        "label": "Ticket Created",
        "icon": Icons.confirmation_number_outlined,
        "active": true,
      },
      {
        "label": "Being Processed",
        "icon": Icons.engineering_outlined,
        "active": status == "Pending" || status == "Closed",
      },
      {
        "label": "Resolved",
        "icon": Icons.verified_outlined,
        "active": status == "Closed",
      },
    ];

    return Column(
      children: List.generate(allSteps.length, (i) {
        final step = allSteps[i];
        final bool isActive = step["active"] as bool;
        final bool isLast = i == allSteps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Left: icon + connector line
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF2563EB)
                        : Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF1E2438)
                            : const Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFF2563EB)
                          : Theme.of(context).brightness == Brightness.dark
                              ? Colors.white12
                              : const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    isActive ? Icons.check_rounded : step["icon"] as IconData,
                    color: isActive
                        ? Colors.white
                        : Theme.of(context).brightness == Brightness.dark
                            ? Colors.white24
                            : const Color(0xFFCBD5E1),
                    size: 15,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 32,
                    color: isActive
                        ? const Color(0xFF2563EB).withOpacity(0.3)
                        : Theme.of(context).brightness == Brightness.dark
                            ? Colors.white12
                            : const Color(0xFFE2E8F0),
                  ),
              ],
            ),

            const SizedBox(width: 14),

            /// Right: label
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                step["label"] as String,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      isActive ? FontWeight.w700 : FontWeight.w400,
                  color: isActive
                      ? Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : const Color(0xFF111827)
                      : Theme.of(context).brightness == Brightness.dark
                          ? Colors.white30
                          : const Color(0xFFCBD5E1),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final role = authProvider.role ?? "user";
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
          'Ticket Detail',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF111827),
            letterSpacing: -0.3,
          ),
        ),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionCard(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ID + Status badge row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '#${widget.ticket.id?.toString().padLeft(4, '0') ?? '0000'}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFF6B7280)
                              : const Color(0xFF9CA3AF),
                          letterSpacing: 0.5,
                        ),
                      ),
                      _StatusPill(status: selectedStatus),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.ticket.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF111827),
                      letterSpacing: -0.3,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 1,
                    color: isDark
                        ? Colors.white.withOpacity(0.06)
                        : const Color(0xFFF1F5F9),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _MetaChip(
                        icon: Icons.label_outline_rounded,
                        label: "General",
                        isDark: isDark,
                      ),
                      const SizedBox(width: 8),
                      _MetaChip(
                        icon: Icons.person_outline_rounded,
                        label: "User",
                        isDark: isDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (role != "user") ...[
              _SectionCard(
                isDark: isDark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CardSectionLabel(
                        label: 'Update Status', isDark: isDark),
                    const SizedBox(height: 14),
                    _StyledDropdown<String>(
                      value: selectedStatus,
                      items: statusList,
                      isDark: isDark,
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (role == "admin") ...[
              _SectionCard(
                isDark: isDark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CardSectionLabel(
                        label: 'Assign Helpdesk', isDark: isDark),
                    const SizedBox(height: 14),
                    _StyledDropdown<String>(
                      value: assignedHelpdesk,
                      items: helpdeskList,
                      isDark: isDark,
                      onChanged: (value) {
                        setState(() {
                          assignedHelpdesk = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            _SectionCard(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CardSectionLabel(label: 'Description', isDark: isDark),
                  const SizedBox(height: 12),
                  Text(
                    widget.ticket.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? Colors.white70
                          : const Color(0xFF374151),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _SectionCard(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CardSectionLabel(
                      label: 'Ticket Tracking', isDark: isDark),
                  const SizedBox(height: 20),
                  buildTracking(selectedStatus),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _SectionCard(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _CardSectionLabel(label: 'Comments', isDark: isDark),
                      const SizedBox(width: 8),
                      if (comments.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${comments.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// Comment list
                  if (comments.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No comments yet. Be the first to reply.',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? Colors.white30
                              : const Color(0xFF9CA3AF),
                        ),
                      ),
                    )
                  else
                    ...comments.map(
                      (c) => _CommentBubble(comment: c, isDark: isDark),
                    ),

                  const SizedBox(height: 16),

                  Container(
                    height: 1,
                    color: isDark
                        ? Colors.white.withOpacity(0.06)
                        : const Color(0xFFF1F5F9),
                  ),

                  const SizedBox(height: 16),

                  /// Comment input
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          maxLines: 3,
                          minLines: 1,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white : const Color(0xFF111827),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Write a reply...',
                            hintStyle: TextStyle(
                              color: isDark
                                  ? Colors.white30
                                  : const Color(0xFFBFC8D7),
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: isDark
                                ? const Color(0xFF0F1117)
                                : const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark
                                    ? const Color(0xFF2D3554)
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark
                                    ? const Color(0xFF2D3554)
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF3B82F6),
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 46,
                        width: 46,
                        child: ElevatedButton(
                          onPressed: () {
                            if (commentController.text.isNotEmpty) {
                              setState(() {
                                comments.add(commentController.text);
                              });
                              commentController.clear();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Icon(
                            Icons.send_rounded,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _SectionCard extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const _SectionCard({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
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
      child: child,
    );
  }
}

class _CardSectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;

  const _CardSectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF111827),
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;

    switch (status) {
      case "Open":
        bg = const Color(0xFFFFF3E0);
        fg = const Color(0xFFE65100);
        icon = Icons.folder_open_outlined;
        break;
      case "Closed":
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF2E7D32);
        icon = Icons.check_circle_outline;
        break;
      case "Pending":
        bg = const Color(0xFFE3F2FD);
        fg = const Color(0xFF1565C0);
        icon = Icons.hourglass_empty_rounded;
        break;
      default:
        bg = const Color(0xFFF5F5F5);
        fg = const Color(0xFF616161);
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _MetaChip(
      {required this.icon, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2438) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color:
                  isDark ? Colors.white54 : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class _StyledDropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final bool isDark;
  final void Function(T?) onChanged;

  const _StyledDropdown({
    required this.value,
    required this.items,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      dropdownColor: isDark ? const Color(0xFF1E2438) : Colors.white,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: isDark ? Colors.white : const Color(0xFF111827),
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor:
            isDark ? const Color(0xFF0F1117) : const Color(0xFFF8FAFC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? const Color(0xFF2D3554)
                : const Color(0xFFE2E8F0),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? const Color(0xFF2D3554)
                : const Color(0xFFE2E8F0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF3B82F6),
            width: 2,
          ),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(item.toString()),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

class _CommentBubble extends StatelessWidget {
  final String comment;
  final bool isDark;

  const _CommentBubble({required this.comment, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 16,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E2438)
                    : const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Text(
                comment,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? Colors.white70
                      : const Color(0xFF374151),
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
