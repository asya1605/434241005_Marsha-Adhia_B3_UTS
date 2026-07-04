import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/user_management_provider.dart';
import 'user_detail_screen.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<UserManagementProvider>().loadUsers();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        role.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 10,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'ACTIVE' : 'INACTIVE',
        style: GoogleFonts.poppins(
          fontSize: 10,
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
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[localDate.month - 1];
    return '${localDate.day} $month ${localDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Admin access check
    if (authProvider.role != 'admin') {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F1117) : const Color(0xFFF4F6FA),
        appBar: AppBar(
          title: Text(
            'Akses Ditolak',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 80,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 16),
                Text(
                  'Hanya Administrator yang memiliki akses ke halaman ini.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final provider = context.watch<UserManagementProvider>();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1117) : const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF161B2E) : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          'Kelola User',
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
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  provider.setSearchQuery(val);
                },
                style: GoogleFonts.poppins(
                  color: isDark ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'Cari user berdasarkan nama atau role...',
                  hintStyle: GoogleFonts.poppins(
                    color: isDark ? Colors.white38 : Colors.black38,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            provider.setSearchQuery('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: BorderSide(
                      color: const Color(0xFF2563EB),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF2563EB),
                    ),
                  )
                : RefreshIndicator(
                    color: const Color(0xFF2563EB),
                    onRefresh: () => provider.loadUsers(),
                    child: provider.filteredUsers.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.4,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.people_outline_rounded,
                                        size: 64,
                                        color: isDark ? Colors.white30 : Colors.black38,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Tidak ada user ditemukan',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          color: isDark ? Colors.white54 : Colors.black54,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            itemCount: provider.filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = provider.filteredUsers[index];
                              final avatarColor = _getAvatarColor(user.name);
                              final initials = user.name.isNotEmpty
                                  ? user.name[0].toUpperCase()
                                  : '?';

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                    borderRadius: BorderRadius.circular(16.0),
                                    border: Border.all(
                                      color: isDark
                                          ? const Color(0xFF334155)
                                          : const Color(0xFFE2E8F0),
                                      width: 1,
                                    ),
                                    boxShadow: isDark
                                        ? []
                                        : [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.02),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16.0),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => UserDetailScreen(user: user),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          children: [
                                            // Avatar
                                            CircleAvatar(
                                              radius: 24,
                                              backgroundColor: avatarColor,
                                              child: Text(
                                                initials,
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            // Details
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          user.name,
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w600,
                                                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      _buildRoleBadge(user.role, isDark),
                                                      const SizedBox(width: 6),
                                                      _buildStatusBadge(user.isActive, isDark),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Dibuat pada: ${_formatDate(user.createdAt)}',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 13,
                                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(
                                              Icons.chevron_right_rounded,
                                              color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
