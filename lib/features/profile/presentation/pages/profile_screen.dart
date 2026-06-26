import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/theme_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/pages/login_screen.dart';
import '../../../notification/presentation/providers/notification_provider.dart';
import '../../../dashboard/presentation/widgets/app_design_tokens.dart';

/// PROFILE PAGE — redesign v2
///
/// Konsisten dengan Notifications & My Tickets: header biru solid,
/// section heading dengan accent bar, card info dengan ikon fixed-width
/// supaya semua label align di titik horizontal yang sama.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    final name = authProvider.name ?? "-";
    final email = authProvider.email ?? "-";
    final role = authProvider.role ?? "user";

    // Role display config
    IconData roleIcon;
    String roleLabel;

    switch (role.toLowerCase()) {
      case "admin":
        roleIcon = Icons.shield_outlined;
        roleLabel = "Admin";
        break;
      case "helpdesk":
        roleIcon = Icons.headset_mic_outlined;
        roleLabel = "Helpdesk";
        break;
      default:
        roleIcon = Icons.person_outline_rounded;
        roleLabel = "User";
    }

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ===== Header biru =====
            Container(
              width: double.infinity,
              color: AppColors.primaryDark,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl + 6,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      if (Navigator.canPop(context))
                        IconButton(
                          onPressed: () => Navigator.maybePop(context),
                          icon: const Icon(Icons.arrow_back, size: 18, color: Colors.white),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                        ),
                      const SizedBox(width: AppSpacing.xs),
                      const Text(
                        'Profil',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white, height: 1),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.2),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                    ),
                    child: const Icon(Icons.person_outline, size: 26, color: Colors.white),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white, height: 1),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      roleLabel.toUpperCase(),
                      style: const TextStyle(fontSize: 10, color: Colors.white, height: 1, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

            // ===== Content — overlap ke atas header sedikit =====
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -10),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    children: [
                      const _SectionLabel('Informasi Akun'),
                  const SizedBox(height: AppSpacing.sm),
                  _InfoCard(
                    rows: [
                      _InfoRow(icon: Icons.person_outline, label: 'Nama Lengkap', value: name),
                      _InfoRow(icon: Icons.mail_outline, label: 'Email', value: email),
                    ],
                    lastRow: _InfoRow(
                      icon: roleIcon,
                      label: 'Role',
                      value: roleLabel,
                      valueColor: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  const _SectionLabel('Preferensi'),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: AppColors.borderLight, width: 0.6),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 18,
                          child: Icon(Icons.dark_mode_outlined, size: 14, color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dark Mode',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1.3, color: AppColors.textPrimary),
                              ),
                              Text(
                                isDark ? 'Saat ini aktif' : 'Saat ini nonaktif',
                                style: AppTextStyles.bodyMeta.copyWith(fontSize: 11, height: 1.3),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: isDark,
                          activeThumbColor: AppColors.primaryDark,
                          onChanged: (v) {
                            themeProvider.toggleTheme(v);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  const _SectionLabel('Akun'),
                  const SizedBox(height: AppSpacing.sm),
                  InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    onTap: () async {
                      if (context.mounted) {
                        context.read<NotificationProvider>().clear();
                      }
                      await authProvider.logout();

                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LoginScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        border: Border.all(color: const Color(0xFFF0997B), width: 0.6),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(
                            width: 18,
                            child: Icon(Icons.logout, size: 14, color: Color(0xFFD85A30)),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Logout',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, height: 1, color: Color(0xFFD85A30)),
                            ),
                          ),
                          Icon(Icons.chevron_right, size: 16, color: Color(0xFFD85A30)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: Text(
                      'HelpDesk System  •  v1.0.0',
                      style: AppTextStyles.caption.copyWith(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  ),
);
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 3, height: 10, decoration: BoxDecoration(color: AppColors.primaryDark, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 6),
        Text(text, style: AppTextStyles.sectionHeading.copyWith(fontSize: 13.5, height: 1)),
      ],
    );
  }
}

class _InfoRow {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });
}

class _InfoCard extends StatelessWidget {
  final List<_InfoRow> rows;
  final _InfoRow? lastRow;

  const _InfoCard({required this.rows, this.lastRow});

  @override
  Widget build(BuildContext context) {
    final all = [...rows, ?lastRow];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.borderLight, width: 0.6),
      ),
      child: Column(
        children: List.generate(all.length, (i) {
          final row = all[i];
          final isLast = i == all.length - 1;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 11),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(bottom: BorderSide(color: AppColors.borderLight, width: 0.6)),
            ),
            child: Row(
              children: [
                SizedBox(width: 18, child: Icon(row.icon, size: 14, color: AppColors.textSecondary)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(row.label, style: TextStyle(fontSize: 13, height: 1, color: AppColors.textSecondary)),
                ),
                Text(
                  row.value,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1,
                    fontWeight: FontWeight.w500,
                    color: row.valueColor ?? AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}