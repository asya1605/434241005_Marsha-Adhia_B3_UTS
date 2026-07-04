import 'package:flutter/material.dart';
import 'package:helpdesk_ticket/features/dashboard/presentation/widgets/app_design_tokens.dart';

/// TicketListCard — kartu tiket untuk halaman list (My Tickets).
/// Didesain ulang agar menyerupai tampilan kartu kelas di aplikasi referensi:
/// - Category pill di kiri atas (solid color background, text putih tebal).
/// - Judul tebal di sebelah category pill.
/// - Deskripsi (subtitle) tiket di baris berikutnya.
/// - Bottom bar: ID & Tanggal di kiri, tombol "Buka" (jika aktif) atau rating bintang (jika closed) di kanan.
class TicketListCard extends StatelessWidget {
  final String ticketCode;
  final String title;
  final String description;
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
    required this.description,
    required this.status,
    required this.category,
    required this.categoryIcon,
    required this.date,
    required this.onTap,
    this.priority,
  });

  Color _getCategoryColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'network':
        return const Color(0xFF2B9FF0); // Biru
      case 'hardware':
        return const Color(0xFF7C3AED); // Ungu
      case 'software':
        return const Color(0xFF1F9D63); // Hijau
      case 'account':
        return const Color(0xFFFBBF24); // Kuning/Amber
      case 'general':
      default:
        return const Color(0xFFF97316); // Oranye
    }
  }

  bool _isActive(String status) {
    final s = status.toLowerCase();
    return !['closed', 'done', 'resolved', 'close'].contains(s);
  }

  int _priorityStarCount(String p) {
    switch (p.toLowerCase()) {
      case 'high':
        return 3;
      case 'medium':
        return 2;
      case 'low':
      default:
        return 1;
    }
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = '${date.day} ${_monthName(date.month)}';
    final active = _isActive(status);
    final categoryColor = _getCategoryColor(category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderLight.withOpacity(0.5),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Category pill + Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: categoryColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Middle row: Description (subtitle)
                Text(
                  description.isNotEmpty ? description : 'Tidak ada deskripsi.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                // Bottom row: Info & Button/Stars
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Code & Date
                    Text(
                      '$ticketCode  •  $dateStr',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // Action / Status Indicator
                    if (active)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Buka',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(3, (index) {
                          final isFilled = index < _priorityStarCount(priority ?? 'medium');
                          return Icon(
                            isFilled ? Icons.star : Icons.star_border,
                            size: 16,
                            color: isFilled ? Colors.amber : Colors.grey.shade400,
                          );
                        }),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
