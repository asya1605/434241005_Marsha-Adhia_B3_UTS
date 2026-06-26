import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_design_tokens.dart';
import '../../../ticket/data/models/ticket_model.dart';
import '../../../notification/data/models/notification_model.dart';

// ── Warna Gradien Header per Role ─────────────────────────────────────────────
class DC {
  static const adminGrad    = [Color(0xFF1565D8), Color(0xFF2B9FF0)];
  static const userGrad     = [Color(0xFF1565D8), Color(0xFF2B9FF0)];
  static const helpdeskGrad = [Color(0xFF4C1D95), Color(0xFF7C3AED)];
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. DASHBOARD HEADER WIDGET
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
    final days = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final dateStr = '${days[now.weekday % 7]}, ${now.day} ${months[now.month - 1]} ${now.year}';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar inisial
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
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
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.75),
                        ),
                      ),
                      Text(
                        '$name 👋',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Role chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 0.8),
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
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 11, color: Colors.white.withOpacity(0.7)),
                const SizedBox(width: 5),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
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
// 2. SECTION HEADER
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTextStyles.sectionHeading,
          ),
          if (linkText != null) ...[
            const Spacer(),
            GestureDetector(
              onTap: onLink,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  linkText!,
                  style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. STAT CARD GRID
// ─────────────────────────────────────────────────────────────────────────────
class StatItem {
  final String label;
  final int value;
  final IconData icon;
  final Color iconColor;

  const StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });
}

class StatCardGrid extends StatelessWidget {
  final List<StatItem> items;

  const StatCardGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.2,
      children: items.map((item) => _StatCard(item: item)).toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final StatItem item;
  const _StatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = AppColors.cardBg(context);
    final cardBorder = AppColors.cardBorderColor(context);
    final numColor = isDark ? Colors.white : AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cardBorder, width: 0.6),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(item.icon, size: 13, color: item.iconColor),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  item.label,
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            '${item.value}',
            style: AppTextStyles.statNumber.copyWith(color: numColor),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. HERO ACTION BANNER
// ─────────────────────────────────────────────────────────────────────────────
class HeroActionBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final String ctaLabel;
  final VoidCallback onCtaTap;
  final IconData? backgroundIcon;
  final double? progress;
  final String? progressLabel;

  const HeroActionBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.onCtaTap,
    this.backgroundIcon,
    this.progress,
    this.progressLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
        boxShadow: [AppColors.cardShadow],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.05),
                      Colors.black.withOpacity(0.45),
                    ],
                  ),
                ),
              ),
            ),
            if (backgroundIcon != null)
              Positioned(
                right: 12,
                top: 12,
                child: Icon(backgroundIcon, size: 44, color: Colors.white.withOpacity(0.2)),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                  if (progress != null || progressLabel != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (progressLabel != null)
                          Text(
                            progressLabel!,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                      ],
                    ),
                    if (progress != null) ...[
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: progress!.clamp(0.0, 1.0),
                          minHeight: 4,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ],
                  ],
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: onCtaTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      ctaLabel,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
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
// 5. CATEGORY PILL ROW
// ─────────────────────────────────────────────────────────────────────────────
class CategoryItem {
  final String label;
  final IconData icon;
  final String value;

  const CategoryItem({required this.label, required this.icon, required this.value});
}

class CategoryPillRow extends StatelessWidget {
  final List<CategoryItem> categories;
  final ValueChanged<String> onCategoryTap;

  const CategoryPillRow({
    super.key,
    required this.categories,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: categories
          .map(
            (c) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: InkWell(
                  onTap: () => onCategoryTap(c.value),
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                    ),
                    child: Column(
                      children: [
                        Icon(c.icon, size: 20, color: AppColors.primary),
                        const SizedBox(height: 4),
                        Text(
                          c.label,
                          style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5B. CATEGORY GRID (Task 5)
// ─────────────────────────────────────────────────────────────────────────────
class CategoryGrid extends StatelessWidget {
  final List<CategoryItem> categories;
  final ValueChanged<String> onCategoryTap;

  const CategoryGrid({
    super.key,
    required this.categories,
    required this.onCategoryTap,
  });

  Color _getCategoryColor(String value) {
    switch (value.toLowerCase()) {
      case 'network':
        return AppColors.categoryNetwork;
      case 'hardware':
        return AppColors.categoryHardware;
      case 'software':
        return AppColors.categorySoftware;
      default:
        return AppColors.categoryOther;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: categories.map((c) {
        final color = _getCategoryColor(c.value);
        final bgColor = color.withOpacity(isDark ? 0.15 : 0.08);
        return InkWell(
          onTap: () => onCategoryTap(c.value),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardBg(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.cardBorderColor(context),
                width: 0.6,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(c.icon, size: 22, color: color),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  c.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 6. UPDATE ALERT BANNER
// ─────────────────────────────────────────────────────────────────────────────
class UpdateAlertBanner extends StatelessWidget {
  final int unreadCount;
  final VoidCallback onTap;

  const UpdateAlertBanner({
    super.key,
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (unreadCount <= 0) return const SizedBox.shrink();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.chip),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.statusWarningBg,
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, size: 16, color: AppColors.statusWarningText),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$unreadCount tiket ada update baru',
                style: TextStyle(fontSize: 11, color: AppColors.statusWarningText, fontWeight: FontWeight.w500),
              ),
            ),
            Icon(Icons.chevron_right, size: 16, color: AppColors.statusWarningText),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 7. TICKET BOARDING CARD (Pengganti TicketRowCard)
// ─────────────────────────────────────────────────────────────────────────────
class TicketBoardingCard extends StatelessWidget {
  final String ticketCode;
  final String title;
  final String status;
  final IconData categoryIcon;
  final DateTime createdAt;
  final String? assignedAgentName;
  final String? createdByName;
  final bool hasUnread;
  final VoidCallback onTap;
  final String? category;

  const TicketBoardingCard({
    super.key,
    required this.ticketCode,
    required this.title,
    required this.status,
    required this.categoryIcon,
    required this.createdAt,
    required this.onTap,
    this.assignedAgentName,
    this.createdByName,
    this.hasUnread = false,
    this.category,
  });

  Color _getCategoryColor(String? value) {
    if (value == null) return AppColors.categoryOther;
    switch (value.toLowerCase()) {
      case 'network':
        return AppColors.categoryNetwork;
      case 'hardware':
        return AppColors.categoryHardware;
      case 'software':
        return AppColors.categorySoftware;
      default:
        return AppColors.categoryOther;
    }
  }

  @override
  Widget build(BuildContext context) {
    final (statusBg, statusText) = AppColors.statusColors(status);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final cardBg = AppColors.cardBg(context);
    final cardBorder = AppColors.cardBorderColor(context);
    final tColor = isDark ? Colors.white : AppColors.textPrimary;
    final subText = isDark ? AppColors.textTertiary : AppColors.textPrimary;

    final dateStr = '${createdAt.day} ${_monthName(createdAt.month)} ${createdAt.year}';

    final catColor = _getCategoryColor(category);
    final catBg = catColor.withOpacity(isDark ? 0.15 : 0.08);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: cardBorder, width: 0.6),
                boxShadow: [AppColors.cardShadow],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ticketCode.length > 8 ? '#${ticketCode.substring(0, 8)}...' : '#$ticketCode', 
                        style: AppTextStyles.caption
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _statusLabel(status),
                          style: TextStyle(fontSize: 10, color: statusText, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: catBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(categoryIcon, size: 20, color: catColor),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title,
                          style: AppTextStyles.cardTitle.copyWith(color: tColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: cardBorder, width: 0.6, style: BorderStyle.solid),
                      ),
                    ),
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Dibuat', style: AppTextStyles.caption),
                            Text(dateStr, style: TextStyle(fontSize: 11, color: subText)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              createdByName != null ? 'Dibuat oleh' : 'Agent',
                              style: AppTextStyles.caption,
                            ),
                            Text(
                              createdByName ?? (assignedAgentName ?? 'Belum ditugaskan'),
                              style: TextStyle(fontSize: 11, color: subText),
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
          if (hasUnread)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: AppColors.statusDangerDot,
                  shape: BoxShape.circle,
                  border: Border.all(color: cardBg, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return 'Open';
      case 'in_progress':
      case 'process':
      case 'pending':
        return 'Diproses';
      case 'closed':
      case 'done':
        return 'Closed';
      default:
        return status;
    }
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return months[month - 1];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 8. INSIGHT MINI CARD
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
    final cardBg = AppColors.cardBg(context);
    final cardBorder = AppColors.cardBorderColor(context);
    final labelColor = isDark ? AppColors.textTertiary : AppColors.textSecondary;
    final valColor = isDark ? Colors.white : AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: cardBorder, width: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: labelColor, letterSpacing: 0.3)),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
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
                color: subtitleColor ?? (isDark ? Colors.white70 : AppColors.textSecondary),
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
                backgroundColor: isDark ? const Color(0xFF334155) : AppColors.borderLight,
                valueColor: AlwaysStoppedAnimation<Color>(barColor ?? AppColors.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 9. QUICK ACTION BUTTON (Re-styled Tile)
// ─────────────────────────────────────────────────────────────────────────────
class QuickActionButton extends StatelessWidget {
  final String label;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  // parameter iconBg dan iconColor dipertahankan tanda tanya di constructor
  // agar tidak merusak kompabilitas parameter lama tapi diabaikan di render visual.
  const QuickActionButton({
    super.key,
    required this.label,
    this.subtitle,
    required this.icon,
    this.onTap,
    Color? iconBg,
    Color? iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = AppColors.cardBg(context);
    final cardBorderColor = AppColors.cardBorderColor(context);
    final labelColor = isDark ? Colors.white : AppColors.textPrimary;
    final subColor = isDark ? AppColors.textTertiary : AppColors.textSecondary;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: cardBorderColor, width: .6),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 17, color: AppColors.primary),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: labelColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(fontSize: 10, color: subColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
// 10. DASHBOARD EMPTY STATE
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
    final cardBg = AppColors.cardBg(context);
    final cardBorder = AppColors.cardBorderColor(context);
    final titleColor = isDark ? Colors.white : AppColors.textPrimary;
    final subColor = isDark ? AppColors.textTertiary : AppColors.textSecondary;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 150),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: cardBorder, width: 0.6),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (imageAsset != null) ...[
              Image.asset(
                imageAsset!,
                width: 140,
                height: 140,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 12),
            ] else ...[
              Icon(
                icon,
                size: 36,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFFCBD5E1),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: titleColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
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
// 11. TIMELINE ACTIVITIES & HELPERS (TETAP pakai tickets + notifications)
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
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
  }
}

List<Map<String, dynamic>> getTimelineActivities({
  required List<TicketModel> tickets,
  required List<NotificationModel> notifications,
}) {
  final List<Map<String, dynamic>> activities = [];

  for (final ticket in tickets) {
    final timestamp = ticket.createdAt;

    // Check for matching notification (Task 3 de-duplication)
    final hasMatchingNotification = notifications.any((n) {
      if (n.ticketId != ticket.id) return false;
      final nTime = DateTime.tryParse(n.createdAt);
      if (nTime == null) return false;
      final diff = nTime.difference(ticket.createdAt).abs();
      return diff.inSeconds <= 5;
    });

    if (!hasMatchingNotification) {
      activities.add({
        ActivityKeys.type: ActivityType.ticket,
        ActivityKeys.title: 'Tiket Baru',
        ActivityKeys.message: ticket.title,
        ActivityKeys.timestamp: timestamp,
        ActivityKeys.ticket: ticket,
        ActivityKeys.notification: null,
      });
    }
  }

  for (final notification in notifications) {
    final timestamp = DateTime.tryParse(notification.createdAt) ?? DateTime.now();
    
    TicketModel? associatedTicket;
    if (notification.ticketId != null) {
      try {
        associatedTicket = tickets.firstWhere((t) => t.id == notification.ticketId);
      } catch (_) {}
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

    final cardBg = AppColors.cardBg(context);
    final cardBorder = AppColors.cardBorderColor(context);
    final titleColor = isDark ? Colors.white : AppColors.textPrimary;
    final msgColor = isDark ? AppColors.textTertiary : AppColors.textSecondary;
    final timeColor = isDark ? AppColors.textTertiary : AppColors.textSecondary;

    final IconData iconData;
    final Color iconColor;
    final Color iconBg;

    if (type == ActivityType.ticket) {
      iconData = Icons.confirmation_number_outlined;
      iconColor = AppColors.primary;
      iconBg = AppColors.primaryLight;
    } else {
      iconData = Icons.notifications_outlined;
      iconColor = AppColors.statusWarningText;
      iconBg = AppColors.statusWarningBg;
    }

    Widget content = Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: cardBorder, width: 0.6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, size: 16, color: iconColor),
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
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
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
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 11,
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
              color: isDark ? Colors.white24 : AppColors.textTertiary,
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
