import 'package:flutter/material.dart';
import 'package:helpdesk_ticket/features/dashboard/presentation/widgets/app_design_tokens.dart';

/// TicketListCard — kartu tiket untuk halaman list (My Tickets).
/// Beda dari TicketBoardingCard (dashboard): lebih ringkas, tanpa kolom
/// dibuat/agent di bawah, karena di list view fokusnya scanning cepat
/// banyak tiket, bukan detail satu tiket.
class TicketListCard extends StatelessWidget {
  final String ticketCode;
  final String title;
  final String status; // 'open' | 'in_progress' | 'closed'
  final String category;
  final IconData categoryIcon;
  final String? priority; // 'high' | 'medium' | 'low' | null
  final DateTime date;
  final VoidCallback onTap;

  const TicketListCard({
    super.key,
    required this.ticketCode,
    required this.title,
    required this.status,
    required this.category,
    required this.categoryIcon,
    required this.date,
    required this.onTap,
    this.priority,
  });

  @override
  Widget build(BuildContext context) {
    final (statusBg, statusText) = AppColors.statusColors(status);
    final dateStr = '${date.day} ${_monthName(date.month)}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.borderLight, width: 0.6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(ticketCode, style: AppTextStyles.caption),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _statusLabel(status),
                    style: TextStyle(fontSize: 10, color: statusText, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: AppTextStyles.cardTitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(categoryIcon, size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 5),
                    Text(category, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    if (priority != null && priority!.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _priorityDotColor(priority!),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(dateStr, style: AppTextStyles.caption),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _priorityDotColor(String p) {
    switch (p.toLowerCase()) {
      case 'high':
        return AppColors.statusDangerDot;
      case 'medium':
        return AppColors.statusWarningText;
      default:
        return AppColors.statusOpenText;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return 'Open';
      case 'in_progress':
      case 'process':
      case 'pending':
        return 'Process';
      case 'closed':
      case 'done':
      case 'resolved':
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
