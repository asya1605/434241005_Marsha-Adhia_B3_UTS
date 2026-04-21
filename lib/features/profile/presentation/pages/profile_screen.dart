import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/theme_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/pages/login_screen.dart';
import '../widgets/profile_item.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final role = authProvider.role ?? "user";
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final name = authProvider.name ?? "-";
    final email = authProvider.email ?? "-";

    // Role display config
    Color roleBg;
    Color roleFg;
    IconData roleIcon;
    String roleLabel;

    switch (role) {
      case "admin":
        roleBg = const Color(0xFFFEF3C7);
        roleFg = const Color(0xFFB45309);
        roleIcon = Icons.shield_outlined;
        roleLabel = "Admin";
        break;
      case "helpdesk":
        roleBg = const Color(0xFFEDE9FE);
        roleFg = const Color(0xFF6D28D9);
        roleIcon = Icons.headset_mic_outlined;
        roleLabel = "Helpdesk";
        break;
      default:
        roleBg = const Color(0xFFEFF6FF);
        roleFg = const Color(0xFF1D4ED8);
        roleIcon = Icons.person_outline_rounded;
        roleLabel = "User";
    }

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
          'Profile',
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
        child: Column(
          children: [
            /// ── PROFILE HERO ────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1A1F35), const Color(0xFF0D1321)]
                      : [const Color(0xFF1E40AF), const Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 36),
              child: Column(
                children: [
                  /// Avatar
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.35),
                        width: 2.5,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person,
                        size: 44,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// Name
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),

                  const SizedBox(height: 4),

                  /// Email
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.72),
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// Role badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(roleIcon,
                            size: 13, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          roleLabel.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ── ACCOUNT INFO CARD ─────────────────────────────
                  _SectionLabel(label: 'Account Info', isDark: isDark),
                  const SizedBox(height: 12),
                  _InfoCard(
                    isDark: isDark,
                    children: [
                      _InfoRow(
                        icon: Icons.person_outline_rounded,
                        label: 'Full Name',
                        value: name,
                        isDark: isDark,
                      ),
                      _Divider(isDark: isDark),
                      _InfoRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: email,
                        isDark: isDark,
                      ),
                      _Divider(isDark: isDark),
                      _InfoRow(
                        icon: roleIcon,
                        label: 'Role',
                        value: roleLabel,
                        isDark: isDark,
                        valueColor: roleFg,
                        valueBg: isDark ? roleBg.withOpacity(0.15) : roleBg,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  /// ── PREFERENCES ───────────────────────────────────
                  _SectionLabel(label: 'Preferences', isDark: isDark),
                  const SizedBox(height: 12),
                  _InfoCard(
                    isDark: isDark,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E2438)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                themeProvider.themeMode == ThemeMode.dark
                                    ? Icons.dark_mode_outlined
                                    : Icons.light_mode_outlined,
                                size: 18,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dark Mode',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    themeProvider.themeMode == ThemeMode.dark
                                        ? 'Currently enabled'
                                        : 'Currently disabled',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark
                                          ? Colors.white38
                                          : const Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: themeProvider.themeMode == ThemeMode.dark,
                              onChanged: (value) {
                                themeProvider.toggleTheme(value);
                              },
                              activeColor: const Color(0xFF2563EB),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  /// ── ACCOUNT ACTIONS ───────────────────────────────
                  _SectionLabel(label: 'Account', isDark: isDark),
                  const SizedBox(height: 12),
                  _InfoCard(
                    isDark: isDark,
                    children: [
                      ProfileItem(
                        icon: Icons.logout,
                        title: "Logout",
                        onTap: () async {
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
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  /// ── APP VERSION ───────────────────────────────────
                  Center(
                    child: Text(
                      'HelpDesk System  •  v1.0.0',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white24 : const Color(0xFFD1D5DB),
                      ),
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

// ─── Private helper widgets ───────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;

  const _SectionLabel({required this.label, required this.isDark});

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
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white60 : const Color(0xFF6B7280),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  final bool isDark;

  const _InfoCard({required this.children, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : const Color(0xFFE5E7EB),
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
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final Color? valueColor;
  final Color? valueBg;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.valueColor,
    this.valueBg,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E2438)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isDark
                  ? const Color(0xFF94A3B8)
                  : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white54 : const Color(0xFF6B7280),
              ),
            ),
          ),
          valueColor != null && valueBg != null
              ? Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: valueBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: valueColor,
                    ),
                  ),
                )
              : Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 66,
      endIndent: 0,
      color: isDark
          ? Colors.white.withOpacity(0.06)
          : const Color(0xFFF1F5F9),
    );
  }
}