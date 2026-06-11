import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:helpdesk_ticket/features/ticket/data/models/ticket_model.dart';
import 'package:helpdesk_ticket/features/notification/data/models/notification_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// dashboard_widgets.dart
// Widget bersama yang dipakai oleh admin, user, dan helpdesk dashboard.
// Taruh di: lib/features/dashboard/presentation/widgets/dashboard_widgets.dart
// ─────────────────────────────────────────────────────────────────────────────

// ── Warna ────────────────────────────────────────────────────────────────────
class DC {
  static const blue       = Color(0xFF2563EB);
  static const blueDark   = Color(0xFF1D4ED8);
  static const blueBg     = Color(0xFFEFF6FF);
  static const cyan       = Color(0xFF06B6D4);
  static const cyanBg     = Color(0xFFECFEFF);
  static const amber      = Color(0xFFF59E0B);
  static const amberBg    = Color(0xFFFFFBEB);
  static const green      = Color(0xFF10B981);
  static const greenBg    = Color(0xFFECFDF5);
  static const red        = Color(0xFFEF4444);
  static const redBg      = Color(0xFFFEF2F2);
  static const purple     = Color(0xFF7C3AED);
  static const purpleBg   = Color(0xFFF5F3FF);
  static const surface    = Color(0xFFFFFFFF);
  static const surface2   = Color(0xFFF8FAFC);
  static const bg         = Color(0xFFF1F5F9);
  static const border     = Color(0xFFE2E8F0);
  static const txt        = Color(0xFF0F172A);
  static const txt2       = Color(0xFF475569);
  static const txt3       = Color(0xFF94A3B8);

  // Header gradient per role
  static const adminGrad    = [Color(0xFF1E3A8A), Color(0xFF2563EB)];
  static const userGrad     = [Color(0xFF1D4ED8), Color(0xFF3B82F6)];
  static const helpdeskGrad = [Color(0xFF5B21B6), Color(0xFF7C3AED)];
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER CARD — gradient per role (Dominant visual hierarchy)
// ─────────────────────────────────────────────────────────────────────────────
class DashboardHeader extends StatelessWidget {
  final String name;
  final String subtitle;
  final String roleLabel;
  final IconData roleIcon;
  final List<Color> gradientColors;

  const DashboardHeader({
    super.key,
    required this.name,
    required this.subtitle,
    required this.roleLabel,
    required this.roleIcon,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = ['Min','Sen','Sel','Rab','Kam','Jum','Sab'];
    final months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    final dateStr = '${days[now.weekday % 7]}, ${now.day} ${months[now.month - 1]} ${now.year}';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Baris atas: avatar + nama (Greeting is dominant) ───────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar inisial
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat datang,',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.75),
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        '$name 👋',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Role chip
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3), width: .8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(roleIcon, size: 10, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        roleLabel.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: .4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // ── Baris bawah: tanggal + online pill ─────────────────────────
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 11, color: Colors.white.withValues(alpha: 0.7)),
                const SizedBox(width: 5),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: Color(0xFF6EE7B7),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Online',
                        style: TextStyle(
                          fontSize: 9,
                          color: Color(0xFF6EE7B7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STAT CARD GRID — 2×2
// ─────────────────────────────────────────────────────────────────────────────
class StatCardGrid extends StatelessWidget {
  final List<StatCardData> items;
  const StatCardGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.35,
      children: items.map((d) => _StatCard(data: d)).toList(),
    );
  }
}

class StatCardData {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final String? trend;

  const StatCardData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.trend,
  });
}

class _StatCard extends StatefulWidget {
  final StatCardData data;
  const _StatCard({required this.data});

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(begin: 1, end: .95).animate( // Premium touch scale
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final shadowColor = isDark ? Colors.transparent : Colors.black.withValues(alpha: 0.03);
    final valueColor = d.color;
    final labelColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        _ctrl.forward();
      },
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 0.8),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(d.icon, size: 20, color: d.color),
                  const Spacer(),
                  if (d.trend != null) ...[
                    Icon(
                      d.trend!.startsWith('+')
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      size: 14,
                      color: d.trend!.startsWith('+') ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      d.trend!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: d.trend!.startsWith('+') ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ],
              ),
              const Spacer(),
              Text(
                d.value.toString(),
                style: TextStyle(
                  fontSize: 32, // Stronger value typography
                  fontWeight: FontWeight.w800,
                  color: valueColor,
                  height: 1,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                d.label,
                style: TextStyle(
                  fontSize: 11,
                  color: labelColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION HEADER — titik biru + judul + optional link
// ─────────────────────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? linkText;
  final VoidCallback? onLink;

  const SectionHeader({
    super.key,
    required this.title,
    this.linkText,
    this.onLink,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: DC.blue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : DC.txt,
            ),
          ),
          if (linkText != null) ...[
            const Spacer(),
            GestureDetector(
              onTap: onLink,
              child: Text(
                linkText!,
                style: const TextStyle(fontSize: 12, color: DC.blue),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TICKET ROW CARD — recent/assigned tickets (Scale animation + Chevron indicator)
// ─────────────────────────────────────────────────────────────────────────────
class TicketRowCard extends StatefulWidget {
  final String title;
  final String description;
  final String status;
  final String? priority;
  final String? creatorEmail;
  final String? agentEmail;
  final String? dateStr;
  final bool hasUnread;
  final Color? leftBorderColor;
  final VoidCallback? onTap;

  const TicketRowCard({
    super.key,
    required this.title,
    required this.description,
    required this.status,
    this.priority,
    this.creatorEmail,
    this.agentEmail,
    this.dateStr,
    this.hasUnread = false,
    this.leftBorderColor,
    this.onTap,
  });

  @override
  State<TicketRowCard> createState() => _TicketRowCardState();
}

class _TicketRowCardState extends State<TicketRowCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1, end: .97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (statusBg, statusFg, statusLabel) = _statusStyle(widget.status);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final cardBorderColor = isDark ? const Color(0xFF334155) : DC.border;
    final titleColor = isDark ? Colors.white : DC.txt;
    final descColor = isDark ? const Color(0xFFCBD5E1) : DC.txt2;
    final metaColor = isDark ? const Color(0xFF94A3B8) : DC.txt3;

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        _ctrl.forward();
      },
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap?.call();
      },
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: widget.leftBorderColor != null
                ? const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  )
                : BorderRadius.circular(12),
            border: Border(
              left: widget.leftBorderColor != null
                  ? BorderSide(color: widget.leftBorderColor!, width: 3)
                  : BorderSide(color: cardBorderColor, width: .8),
              top: BorderSide(color: cardBorderColor, width: .8),
              right: BorderSide(color: cardBorderColor, width: .8),
              bottom: BorderSide(color: cardBorderColor, width: .8),
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Baris judul + status badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w600,
                              color: titleColor,
                              letterSpacing: -0.1,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: statusFg,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Deskripsi
                    Text(
                      widget.description,
                      style: TextStyle(fontSize: 11.5, color: descColor, height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Indikator balasan baru
                    if (widget.hasUnread) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: DC.amber,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'Ada balasan baru',
                            style: TextStyle(
                              fontSize: 10,
                              color: DC.amber,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                    // Meta row: creator, agent, tanggal
                    if (widget.creatorEmail != null || widget.agentEmail != null || widget.dateStr != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (widget.creatorEmail != null) ...[
                            Icon(Icons.person_outline_rounded,
                                size: 11, color: metaColor),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                widget.creatorEmail!,
                                style: TextStyle(
                                    fontSize: 10, color: metaColor),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          if (widget.agentEmail != null) ...[
                            Icon(Icons.headset_mic_outlined,
                                size: 11, color: metaColor),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                widget.agentEmail!,
                                style: TextStyle(
                                    fontSize: 10, color: metaColor),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          if (widget.dateStr != null) ...[
                            Icon(Icons.calendar_today_outlined,
                                size: 11, color: metaColor),
                            const SizedBox(width: 3),
                            Text(
                              widget.dateStr!,
                              style: TextStyle(fontSize: 10, color: metaColor),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Chevron arrow indicating clickability
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  (Color bg, Color fg, String label) _statusStyle(String s) {
    switch (s.toLowerCase()) {
      case 'open':
        return (DC.cyanBg, const Color(0xFF0E7490), 'Open');
      case 'process':
        return (DC.amberBg, const Color(0xFF92400E), 'Process');
      case 'pending':
        return (DC.purpleBg, const Color(0xFF5B21B6), 'Pending');
      case 'done':
      case 'closed':
        return (DC.greenBg, const Color(0xFF065F46), 'Done');
      default:
        return (const Color(0xFFF1F5F9), DC.txt2, s);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PROGRESS BAR CARD — SLA / daily target / tiket aktif
// ─────────────────────────────────────────────────────────────────────────────
class ProgressBarCard extends StatelessWidget {
  final String label;
  final String valueLabel;
  final double progress;
  final Color barColor;
  final String? bottomLeft;
  final String? bottomRight;
  final Color? bottomRightColor;

  const ProgressBarCard({
    super.key,
    required this.label,
    required this.valueLabel,
    required this.progress,
    required this.barColor,
    this.bottomLeft,
    this.bottomRight,
    this.bottomRightColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final cardBorderColor = isDark ? const Color(0xFF334155) : DC.border;
    final labelColor = isDark ? const Color(0xFFCBD5E1) : DC.txt2;
    final bottomLabelColor = isDark ? const Color(0xFF94A3B8) : DC.txt3;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardBorderColor, width: .8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: TextStyle(fontSize: 11, color: labelColor)),
              Text(
                valueLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: barColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: isDark ? const Color(0xFF334155) : DC.border,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          if (bottomLeft != null || bottomRight != null) ...[
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (bottomLeft != null)
                  Text(bottomLeft!,
                      style: TextStyle(fontSize: 10, color: bottomLabelColor)),
                if (bottomRight != null)
                  Text(
                    bottomRight!,
                    style: TextStyle(
                      fontSize: 10,
                      color: bottomRightColor ?? bottomLabelColor,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INSIGHT MINI CARD — metric kecil
// ─────────────────────────────────────────────────────────────────────────────
class InsightMiniCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final Color? subtitleColor;
  final double? barProgress;
  final Color? barColor;

  const InsightMiniCard({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    this.subtitleColor,
    this.barProgress,
    this.barColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final cardBorderColor = isDark ? const Color(0xFF334155) : DC.border;
    final labelColor = isDark ? const Color(0xFF94A3B8) : DC.txt3;
    final valColor = isDark ? Colors.white : DC.txt;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardBorderColor, width: .8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10, color: labelColor, letterSpacing: .3)),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: valColor,
              height: 1,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 10,
                color: subtitleColor ?? (isDark ? const Color(0xFFCBD5E1) : DC.txt2),
              ),
            ),
          ],
          if (barProgress != null) ...[
            const SizedBox(height: 7),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: barProgress!.clamp(0.0, 1.0),
                minHeight: 4,
                backgroundColor: isDark ? const Color(0xFF334155) : DC.border,
                valueColor:
                    AlwaysStoppedAnimation<Color>(barColor ?? DC.blue),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QUICK ACTION BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class QuickActionButton extends StatelessWidget {
  final String label;
  final String? subtitle;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback? onTap;

  const QuickActionButton({
    super.key,
    required this.label,
    this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final cardBorderColor = isDark ? const Color(0xFF334155) : DC.border;
    final labelColor = isDark ? Colors.white : DC.txt;
    final subColor = isDark ? const Color(0xFFCBD5E1) : DC.txt3;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cardBorderColor, width: .8),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDark ? iconColor.withValues(alpha: 0.12) : iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 17, color: iconColor),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: labelColor,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(fontSize: 10, color: subColor),
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

// ─────────────────────────────────────────────────────────────────────────────
// ALERT CARD — tiket prioritas tinggi / SLA warning (Scale animation + Chevron)
// ─────────────────────────────────────────────────────────────────────────────
class AlertTicketCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String alertText;
  final Color alertColor;
  final VoidCallback? onTap;

  const AlertTicketCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.alertText,
    required this.alertColor,
    this.onTap,
  });

  @override
  State<AlertTicketCard> createState() => _AlertTicketCardState();
}

class _AlertTicketCardState extends State<AlertTicketCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1, end: .97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final cardBorderColor = isDark ? const Color(0xFF334155) : DC.border;
    final titleColor = isDark ? Colors.white : DC.txt;
    final descColor = isDark ? const Color(0xFFCBD5E1) : DC.txt2;

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        _ctrl.forward();
      },
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap?.call();
      },
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            border: Border(
              left: BorderSide(color: widget.alertColor, width: 3),
              top: BorderSide(color: cardBorderColor, width: .8),
              right: BorderSide(color: cardBorderColor, width: .8),
              bottom: BorderSide(color: cardBorderColor, width: .8),
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w600,
                              color: titleColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: widget.alertColor.withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'High',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: widget.alertColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.subtitle,
                      style: TextStyle(fontSize: 11, color: descColor, height: 1.4),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: widget.alertColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          widget.alertText,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: widget.alertColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD EMPTY STATE (Centered empty indicator wrapped in ConstrainedBox)
// ─────────────────────────────────────────────────────────────────────────────
class DashboardEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? imageAsset;

  const DashboardEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final cardBorderColor = isDark ? const Color(0xFF334155) : DC.border;
    final titleColor = isDark ? Colors.white : DC.txt;
    final subColor = isDark ? const Color(0xFFCBD5E1) : DC.txt3;

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 180,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardBorderColor, width: 0.8),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (imageAsset != null) ...[
              Image.asset(
                imageAsset!,
                width: 180,
                height: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
            ] else ...[
              Icon(
                icon,
                size: 44,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFFCBD5E1),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: titleColor,
                letterSpacing: -0.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11.5,
                color: subColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTIVITY TIMELINE WIDGETS & HELPERS
// ─────────────────────────────────────────────────────────────────────────────

enum ActivityType {
  ticket,
  notification,
}

class ActivityKeys {
  static const type = 'type';
  static const title = 'title';
  static const message = 'message';
  static const timestamp = 'timestamp';
  static const ticket = 'ticket';
  static const notification = 'notification';
}

const int maxTimelineItems = 5;

String formatRelativeTime(DateTime dateTime) {
  final now = DateTime.now();
  final diff = now.difference(dateTime);

  if (diff.isNegative || diff.inSeconds < 60) {
    return 'baru saja';
  } else if (diff.inMinutes < 60) {
    return '${diff.inMinutes} menit lalu';
  } else if (diff.inHours < 24) {
    return '${diff.inHours} jam lalu';
  } else if (diff.inDays < 7) {
    return '${diff.inDays} hari lalu';
  } else {
    final months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
  }
}

List<Map<String, dynamic>> getTimelineActivities({
  required List<TicketModel> tickets,
  required List<NotificationModel> notifications,
}) {
  final List<Map<String, dynamic>> activities = [];

  // 1. Map tickets to activities
  for (final ticket in tickets) {
    // Safeguard 1: Null CreatedAt Protection
    final timestamp = (ticket.createdAt as dynamic) ?? DateTime.now();
    activities.add({
      ActivityKeys.type: ActivityType.ticket,
      ActivityKeys.title: 'Tiket Baru',
      ActivityKeys.message: ticket.title,
      ActivityKeys.timestamp: timestamp,
      ActivityKeys.ticket: ticket,
      ActivityKeys.notification: null,
    });
  }

  // 2. Map notifications to activities
  for (final notification in notifications) {
    final timestamp = DateTime.tryParse(notification.createdAt) ?? DateTime.now();
    
    // Find associated ticket
    TicketModel? associatedTicket;
    if (notification.ticketId != null) {
      try {
        associatedTicket = tickets.firstWhere(
          (t) => t.id == notification.ticketId,
        );
      } catch (_) {
        // Associated ticket not found
      }
    }

    activities.add({
      ActivityKeys.type: ActivityType.notification,
      ActivityKeys.title: notification.title,
      ActivityKeys.message: notification.message,
      ActivityKeys.timestamp: timestamp,
      ActivityKeys.ticket: associatedTicket,
      ActivityKeys.notification: notification,
    });
  }

  // Safeguard 2: Stable Sorting
  activities.sort((a, b) {
    final tA = a[ActivityKeys.timestamp] as DateTime;
    final tB = b[ActivityKeys.timestamp] as DateTime;
    final cmp = tB.compareTo(tA);
    if (cmp != 0) return cmp;
    final titleA = a[ActivityKeys.title] as String;
    final titleB = b[ActivityKeys.title] as String;
    return titleB.compareTo(titleA);
  });

  return activities.take(maxTimelineItems).toList();
}

class ActivityTimelineCard extends StatefulWidget {
  final Map<String, dynamic> activity;
  final VoidCallback? onTap;

  const ActivityTimelineCard({
    super.key,
    required this.activity,
    this.onTap,
  });

  @override
  State<ActivityTimelineCard> createState() => _ActivityTimelineCardState();
}

class _ActivityTimelineCardState extends State<ActivityTimelineCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activity = widget.activity;
    final type = activity[ActivityKeys.type] as ActivityType;
    final title = activity[ActivityKeys.title] as String;
    final message = activity[ActivityKeys.message] as String;
    final timestamp = activity[ActivityKeys.timestamp] as DateTime;
    final associatedTicket = activity[ActivityKeys.ticket] as TicketModel?;
    
    final isClickable = associatedTicket != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final cardBorderColor = isDark ? const Color(0xFF334155) : DC.border;
    final titleColor = isDark ? Colors.white : DC.txt;
    final msgColor = isDark ? const Color(0xFFCBD5E1) : DC.txt2;
    final timeColor = isDark ? const Color(0xFF94A3B8) : DC.txt3;

    final IconData iconData;
    final Color iconColor;
    final Color iconBg;

    if (type == ActivityType.ticket) {
      iconData = Icons.confirmation_number_outlined;
      iconColor = DC.blue;
      iconBg = isDark ? DC.blue.withValues(alpha: 0.15) : DC.blueBg;
    } else {
      iconData = Icons.notifications_outlined;
      iconColor = DC.amber;
      iconBg = isDark ? DC.amber.withValues(alpha: 0.15) : DC.amberBg;
    }

    Widget content = Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cardBorderColor, width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatRelativeTime(timestamp),
                      style: TextStyle(
                        fontSize: 10,
                        color: timeColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: msgColor,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isClickable) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
            ),
          ],
        ],
      ),
    );

    if (isClickable) {
      return GestureDetector(
        onTapDown: (_) {
          HapticFeedback.lightImpact();
          _ctrl.forward();
        },
        onTapUp: (_) => _ctrl.reverse(),
        onTapCancel: () => _ctrl.reverse(),
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap?.call();
        },
        child: ScaleTransition(
          scale: _scale,
          child: content,
        ),
      );
    } else {
      return content;
    }
  }
}

