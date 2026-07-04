import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/theme_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showChangePasswordBottomSheet(BuildContext context, AuthProvider authProvider, bool isDark) {
    _passwordController.clear();
    _confirmPasswordController.clear();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Ubah Kata Sandi",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Masukkan kata sandi baru Anda untuk akun ini.",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: GoogleFonts.poppins(color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
                    decoration: InputDecoration(
                      labelText: "Kata Sandi Baru",
                      hintText: "Minimal 6 karakter",
                      prefixIcon: Icon(Icons.lock_outline_rounded, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return "Kata sandi tidak boleh kosong";
                      }
                      if (val.length < 6) {
                        return "Kata sandi minimal 6 karakter";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    style: GoogleFonts.poppins(color: isDark ? Colors.white : const Color(0xFF1A1A2E)),
                    decoration: InputDecoration(
                      labelText: "Konfirmasi Kata Sandi",
                      hintText: "Ulangi kata sandi baru",
                      prefixIcon: Icon(Icons.lock_reset_rounded, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return "Konfirmasi kata sandi tidak boleh kosong";
                      }
                      if (val != _passwordController.text) {
                        return "Kata sandi tidak cocok";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  StatefulBuilder(
                    builder: (context, setSubState) {
                      bool loading = authProvider.isLoading;
                      return SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: loading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    setSubState(() {});
                                    final err = await authProvider.updatePassword(_passwordController.text.trim());
                                    if (context.mounted) {
                                      if (err != null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text("Gagal memperbarui: $err"),
                                            backgroundColor: const Color(0xFFEF4444),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      } else {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Row(
                                              children: [
                                                Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 16),
                                                SizedBox(width: 8),
                                                Text("Kata sandi berhasil diperbarui!"),
                                              ],
                                            ),
                                            backgroundColor: const Color(0xFF10B981),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                          child: loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation(Colors.white),
                                  ),
                                )
                              : const Text("Simpan Kata Sandi"),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLanguageSelector(BuildContext context, SettingsProvider settingsProvider, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Pilih Bahasa / Select Language",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 16),
              _buildLanguageOption(
                context: context,
                label: "Bahasa Indonesia",
                code: "id",
                flag: "🇮🇩",
                isSelected: settingsProvider.language == "id",
                onTap: () {
                  settingsProvider.setLanguage("id");
                  Navigator.pop(context);
                },
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              _buildLanguageOption(
                context: context,
                label: "English",
                code: "en",
                flag: "🇺🇸",
                isSelected: settingsProvider.language == "en",
                onTap: () {
                  settingsProvider.setLanguage("en");
                  Navigator.pop(context);
                },
                isDark: isDark,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String label,
    required String code,
    required String flag,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final activeColor = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? activeColor
                : isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? activeColor
                      : isDark
                          ? Colors.white
                          : const Color(0xFF1E293B),
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: activeColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8, top: 16),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup({required List<Widget> children, required bool isDark}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.05 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: trailing == null ? onTap : null,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF334155).withValues(alpha: 0.5)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 0.6,
      indent: 52,
      endIndent: 16,
      color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final settingsProvider = context.watch<SettingsProvider>();

    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Pengaturan",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Preferensi Sistem
            _buildSectionHeader("Sistem & Preferensi", isDark),
            _buildSettingsGroup(
              isDark: isDark,
              children: [
                _buildSettingsRow(
                  icon: Icons.language_rounded,
                  title: "Bahasa Aplikasi",
                  subtitle: settingsProvider.language == "id" ? "Bahasa Indonesia (🇮🇩)" : "English (🇺🇸)",
                  isDark: isDark,
                  onTap: () => _showLanguageSelector(context, settingsProvider, isDark),
                ),
                _buildDivider(isDark),
                _buildSettingsRow(
                  icon: Icons.dark_mode_outlined,
                  title: "Mode Gelap",
                  subtitle: isDark ? "Saat ini aktif" : "Saat ini nonaktif",
                  isDark: isDark,
                  trailing: Switch(
                    value: isDark,
                    activeThumbColor: Theme.of(context).colorScheme.primary,
                    activeTrackColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                    onChanged: (v) {
                      themeProvider.toggleTheme(v);
                    },
                  ),
                ),
              ],
            ),

            // Section 2: Notifikasi
            _buildSectionHeader("Notifikasi", isDark),
            _buildSettingsGroup(
              isDark: isDark,
              children: [
                _buildSettingsRow(
                  icon: Icons.notifications_active_outlined,
                  title: "Notifikasi Push",
                  subtitle: "Terima pemberitahuan langsung di perangkat",
                  isDark: isDark,
                  trailing: Switch(
                    value: settingsProvider.pushNotifications,
                    activeThumbColor: Theme.of(context).colorScheme.primary,
                    activeTrackColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                    onChanged: (v) {
                      settingsProvider.setPushNotifications(v);
                    },
                  ),
                ),
                _buildDivider(isDark),
                _buildSettingsRow(
                  icon: Icons.mail_outline_rounded,
                  title: "Notifikasi Email",
                  subtitle: "Kirim email ringkasan aktivitas",
                  isDark: isDark,
                  trailing: Switch(
                    value: settingsProvider.emailNotifications,
                    activeThumbColor: Theme.of(context).colorScheme.primary,
                    activeTrackColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                    onChanged: (v) {
                      settingsProvider.setEmailNotifications(v);
                    },
                  ),
                ),
                _buildDivider(isDark),
                _buildSettingsRow(
                  icon: Icons.update_rounded,
                  title: "Status Tiket",
                  subtitle: "Pemberitahuan perubahan status tiket",
                  isDark: isDark,
                  trailing: Switch(
                    value: settingsProvider.ticketStatusAlerts,
                    activeThumbColor: Theme.of(context).colorScheme.primary,
                    activeTrackColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                    onChanged: (v) {
                      settingsProvider.setTicketStatusAlerts(v);
                    },
                  ),
                ),
                _buildDivider(isDark),
                _buildSettingsRow(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: "Komentar Baru",
                  subtitle: "Notifikasi ketika ada diskusi baru",
                  isDark: isDark,
                  trailing: Switch(
                    value: settingsProvider.commentAlerts,
                    activeThumbColor: Theme.of(context).colorScheme.primary,
                    activeTrackColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                    onChanged: (v) {
                      settingsProvider.setCommentAlerts(v);
                    },
                  ),
                ),
              ],
            ),

            // Section 3: Keamanan & Akun
            _buildSectionHeader("Keamanan & Akun", isDark),
            _buildSettingsGroup(
              isDark: isDark,
              children: [
                _buildSettingsRow(
                  icon: Icons.lock_outline_rounded,
                  title: "Ubah Kata Sandi",
                  subtitle: "Perbarui kata sandi akun Anda",
                  isDark: isDark,
                  onTap: () => _showChangePasswordBottomSheet(context, authProvider, isDark),
                ),
                _buildDivider(isDark),
                _buildSettingsRow(
                  icon: Icons.fingerprint_rounded,
                  title: "Login Biometrik",
                  subtitle: "Gunakan Sidik Jari atau Face ID",
                  isDark: isDark,
                  trailing: Switch(
                    value: settingsProvider.biometricsEnabled,
                    activeThumbColor: Theme.of(context).colorScheme.primary,
                    activeTrackColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                    onChanged: (v) {
                      settingsProvider.setBiometricsEnabled(v);
                    },
                  ),
                ),
              ],
            ),

            // Section 4: Informasi & Bantuan
            _buildSectionHeader("Informasi & Lainnya", isDark),
            _buildSettingsGroup(
              isDark: isDark,
              children: [
                _buildSettingsRow(
                  icon: Icons.help_outline_rounded,
                  title: "Pusat Bantuan",
                  subtitle: "Pertanyaan umum & panduan aplikasi",
                  isDark: isDark,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Pusat Bantuan", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                        content: Text(
                          "Untuk bantuan lebih lanjut, silakan hubungi tim IT Support di internal-support@helpdesk.com atau kunjungi portal dokumentasi kami.",
                          style: GoogleFonts.poppins(),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Tutup"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                _buildDivider(isDark),
                _buildSettingsRow(
                  icon: Icons.info_outline_rounded,
                  title: "Tentang Aplikasi",
                  subtitle: "Informasi versi & pengembang",
                  isDark: isDark,
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: "Helpdesk Ticket",
                      applicationVersion: "v1.2.0 (Build 20260704)",
                      applicationIcon: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Icons.support_agent_rounded, size: 40, color: Theme.of(context).colorScheme.primary),
                      ),
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          "Aplikasi Helpdesk Ticket dikembangkan untuk memudahkan pengelolaan dan pelaporan tiket permasalahan teknologi informasi.",
                          style: GoogleFonts.poppins(fontSize: 13),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
