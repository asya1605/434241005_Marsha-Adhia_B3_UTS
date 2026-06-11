import 'package:flutter/material.dart';

class ShimmerBlock extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBlock({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12.0,
  });

  @override
  State<ShimmerBlock> createState() => _ShimmerBlockState();
}

class _ShimmerBlockState extends State<ShimmerBlock>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final baseColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final highlightColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                (_animation.value - 0.4).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.4).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DashboardShimmer extends StatelessWidget {
  final bool showCreateCta;

  const DashboardShimmer({
    super.key,
    this.showCreateCta = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 1. Header Shimmer
            const ShimmerBlock(
              width: double.infinity,
              height: 140,
              borderRadius: 16,
            ),
            const SizedBox(height: 20),

            /// 2. Create Ticket CTA Shimmer (conditional)
            if (showCreateCta) ...[
              const ShimmerBlock(
                width: double.infinity,
                height: 80,
                borderRadius: 16,
              ),
              const SizedBox(height: 28),
            ],

            /// 3. Stats Section Title
            const ShimmerBlock(
              width: 120,
              height: 20,
              borderRadius: 4,
            ),
            const SizedBox(height: 14),

            /// 4. Stats Cards Shimmer
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.55,
              children: const [
                ShimmerBlock(width: double.infinity, height: double.infinity),
                ShimmerBlock(width: double.infinity, height: double.infinity),
                ShimmerBlock(width: double.infinity, height: double.infinity),
                ShimmerBlock(width: double.infinity, height: double.infinity),
              ],
            ),
            const SizedBox(height: 28),

            /// 5. Recent Tickets Title
            const ShimmerBlock(
              width: 140,
              height: 20,
              borderRadius: 4,
            ),
            const SizedBox(height: 14),

            /// 6. Recent Tickets List Shimmer (5 items)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                return const ShimmerBlock(
                  width: double.infinity,
                  height: 86,
                  borderRadius: 14,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

