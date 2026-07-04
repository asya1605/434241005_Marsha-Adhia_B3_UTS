import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/data/models/user_profile_model.dart';
import '../providers/user_management_provider.dart';

class UserDetailScreen extends StatefulWidget {
  final UserProfileModel user;

  const UserDetailScreen({
    super.key,
    required this.user,
  });

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  bool _isLoading = false;

  Color _getAvatarColor(String name) {
    final colors = [
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF10B981), // Green
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEF4444), // Red
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFEC4899), // Pink
      const Color(0xFF06B6D4), // Cyan
    ];
    int hash = 0;
    for (int i = 0; i < name.length; i++) {
      hash = name.codeUnitAt(i) + ((hash << 5) - hash);
    }
    return colors[hash.abs() % colors.length];
  }

  Widget _buildRoleBadge(String role, bool isDark) {
    Color bg;
    Color fg;
    switch (role.toLowerCase()) {
      case 'admin':
        bg = isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7);
        fg = isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309);
        break;
      case 'helpdesk':
        bg = isDark ? const Color(0xFF4C1D95) : const Color(0xFFEDE9FE);
        fg = isDark ? const Color(0xFFA78BFA) : const Color(0xFF6D28D9);
        break;
      default:
        bg = isDark ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF);
        fg = isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        role.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: fg,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isActive, bool isDark) {
    Color bg;
    Color fg;
    if (isActive) {
      bg = isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5);
      fg = isDark ? const Color(0xFF34D399) : const Color(0xFF065F46);
    } else {
      bg = isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2);
      fg = isDark ? const Color(0xFFF87171) : const Color(0xFF991B1B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        isActive ? 'ACTIVE' : 'INACTIVE',
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: fg,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Tanggal tidak diketahui';
    final localDate = date.toLocal();
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final month = months[localDate.month - 1];
    return '${localDate.day} $month ${localDate.year}';
  }

  Widget _buildDetailItem({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    bool isDark = false,
    VoidCallback? onCopy,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF334155)
                  : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2563EB),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          if (onCopy != null)
            IconButton(
              icon: Icon(
                Icons.copy_rounded,
                color: isDark ? Colors.white54 : Colors.black45,
                size: 20,
              ),
              onPressed: onCopy,
            ),
        ],
      ),
    );
  }

  Future<void> _handleStatusChange(BuildContext context, UserProfileModel userData) async {
    final bool activate = !userData.isActive;
    final actionName = activate ? 'Aktivasi' : 'Deaktivasi';

    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<UserManagementProvider>();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Konfirmasi $actionName',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin melakukan $actionName pada user ini?',
            style: GoogleFonts.poppins(
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: activate ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                activate ? 'Aktifkan' : 'Nonaktifkan',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      await provider.updateActiveStatus(userData.id, activate);
      
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'User berhasil ${activate ? 'diaktifkan' : 'dinonaktifkan'}',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Watch provider to get latest user details
    final provider = context.watch<UserManagementProvider>();
    final currentUserData = provider.users.firstWhere(
      (u) => u.id == widget.user.id,
      orElse: () => widget.user,
    );

    final avatarColor = _getAvatarColor(currentUserData.name);
    final initials = currentUserData.name.isNotEmpty ? currentUserData.name[0].toUpperCase() : '?';

    // Check if viewed account is current logged in admin
    final authProvider = context.read<AuthProvider>();
    final isOwnAccount = currentUserData.id == authProvider.userId;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1117) : const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF161B2E) : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          'Detail User',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // User Header Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161B2E) : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: avatarColor,
                    child: Text(
                      initials,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentUserData.name,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildRoleBadge(currentUserData.role, isDark),
                      const SizedBox(width: 8),
                      _buildStatusBadge(currentUserData.isActive, isDark),
                    ],
                  ),
                ],
              ),
            ),
            // User Detailed Fields
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informasi Profil',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black87,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailItem(
                    context: context,
                    label: 'NAMA LENGKAP',
                    value: currentUserData.name,
                    icon: Icons.person_rounded,
                    isDark: isDark,
                  ),
                  _buildDetailItem(
                    context: context,
                    label: 'TANGGAL BERGABUNG',
                    value: _formatDate(currentUserData.createdAt),
                    icon: Icons.calendar_today_rounded,
                    isDark: isDark,
                  ),

                  // Dropdown Role
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: DropdownButtonFormField<String>(
                      initialValue: currentUserData.role.toLowerCase(),
                      dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        labelText: 'ROLE / PERAN',
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                        prefixIcon: Icon(
                          Icons.security_rounded,
                          color: const Color(0xFF2563EB),
                          size: 20,
                        ),
                        border: InputBorder.none,
                      ),
                      items: ['user', 'helpdesk', 'admin'].map((role) {
                        return DropdownMenuItem<String>(
                          value: role,
                          child: Text(
                            role.toUpperCase(),
                            style: GoogleFonts.poppins(),
                          ),
                        );
                      }).toList(),
                      onChanged: _isLoading
                          ? null
                          : (newRole) async {
                              if (newRole != null && newRole != currentUserData.role.toLowerCase()) {
                                if (!mounted) return;
                                setState(() => _isLoading = true);
                                final messenger = ScaffoldMessenger.of(context);
                                final mProvider = context.read<UserManagementProvider>();
                                try {
                                  await mProvider.updateRole(currentUserData.id, newRole);
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Role berhasil diubah menjadi ${newRole.toUpperCase()}',
                                        style: GoogleFonts.poppins(),
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } catch (e) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        e.toString().replaceAll('Exception: ', ''),
                                        style: GoogleFonts.poppins(),
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() => _isLoading = false);
                                  }
                                }
                              }
                            },
                    ),
                  ),

                  _buildDetailItem(
                    context: context,
                    label: 'USER ID',
                    value: currentUserData.id,
                    icon: Icons.fingerprint_rounded,
                    isDark: isDark,
                    onCopy: () {
                      Clipboard.setData(ClipboardData(text: currentUserData.id));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'User ID disalin ke clipboard',
                            style: GoogleFonts.poppins(),
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                  if (isOwnAccount)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF3B1E1E) : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFCA5A5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: Colors.redAccent),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Anda tidak dapat menonaktifkan akun Anda sendiri.',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.red[200] : const Color(0xFF991B1B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: currentUserData.isActive
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _isLoading ? null : () => _handleStatusChange(context, currentUserData),
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Icon(currentUserData.isActive ? Icons.block_flipped : Icons.check_circle_outline_rounded),
                        label: Text(
                          currentUserData.isActive ? 'Nonaktifkan User' : 'Aktifkan User',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
