import 'package:flutter/material.dart';
import '../../../dashboard/presentation/widgets/dashboard_shimmer.dart';

class TicketListShimmer extends StatelessWidget {
  const TicketListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Short ID & Status Badge Shimmer
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerBlock(width: 80, height: 12, borderRadius: 4),
                  ShimmerBlock(width: 55, height: 18, borderRadius: 20),
                ],
              ),
              const SizedBox(height: 12),

              // Title Shimmer
              const ShimmerBlock(width: 180, height: 15, borderRadius: 4),
              const SizedBox(height: 8),

              // Description Shimmer (2 lines)
              const ShimmerBlock(width: double.infinity, height: 11, borderRadius: 4),
              const SizedBox(height: 6),
              const ShimmerBlock(width: 220, height: 11, borderRadius: 4),
              const SizedBox(height: 12),

              // Double Badges Row: Category & Priority Shimmer
              const Row(
                children: [
                  ShimmerBlock(width: 70, height: 18, borderRadius: 20),
                  SizedBox(width: 8),
                  ShimmerBlock(width: 60, height: 18, borderRadius: 20),
                ],
              ),
              const SizedBox(height: 14),

              // Divider
              Container(
                height: 1,
                color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE2E8F0),
              ),
              const SizedBox(height: 12),

              // Bottom Row: Date & Assignee Shimmer
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerBlock(width: 100, height: 11, borderRadius: 4),
                  ShimmerBlock(width: 90, height: 11, borderRadius: 4),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
