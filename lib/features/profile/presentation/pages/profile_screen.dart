import 'dart:convert';
import 'dart:io' as io;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../core/theme/theme_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/pages/login_screen.dart';
import '../../../notification/presentation/providers/notification_provider.dart';
import '../../../ticket/presentation/providers/ticket_provider.dart';
import '../../../ticket/presentation/providers/ticket_history_provider.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../../navigation/navigation_notifications.dart';
import 'settings_screen.dart';

/// PROFILE PAGE — Redesigned modern profile layout
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _avatarType;
  String? _avatarValue;

  final List<List<Color>> _presetGradients = [
    [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)], // Blue
    [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)], // Purple
    [const Color(0xFF10B981), const Color(0xFF047857)], // Green
    [const Color(0xFFF59E0B), const Color(0xFFEA580C)], // Orange/Yellow
    [const Color(0xFFEC4899), const Color(0xFFBE185D)], // Pink
    [const Color(0xFFEF4444), const Color(0xFF991B1B)], // Red
    [const Color(0xFF06B6D4), const Color(0xFF0891B2)], // Cyan
    [const Color(0xFF64748B), const Color(0xFF334155)], // Slate/Dark
  ];

  @override
  void initState() {
    super.initState();
    _loadAvatarData();
    Future.microtask(() async {
      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();
      final ticketProvider = context.read<TicketProvider>();
      final dashboardProvider = context.read<DashboardProvider>();
      final role = authProvider.role ?? "user";

      // Load latest tickets to populate statistics
      await ticketProvider.loadTickets(role: role);
      if (mounted) {
        dashboardProvider.loadDashboard(ticketProvider.tickets);
      }
    });
  }

  String _getInitials(String name) {
    if (name.isEmpty) return "?";
    final parts = name.trim().split(" ");
    if (parts.isEmpty) return "?";
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Future<void> _loadAvatarData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _avatarType = prefs.getString("profile_avatar_type") ?? "initials";
        _avatarValue = prefs.getString("profile_avatar_value");
      });
    }
  }

  Future<void> _saveAvatarData(String type, String? value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove("profile_avatar_type");
      await prefs.remove("profile_avatar_value");
    } else {
      await prefs.setString("profile_avatar_type", type);
      await prefs.setString("profile_avatar_value", value);
    }
    if (mounted) {
      setState(() {
        _avatarType = type;
        _avatarValue = value;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final bytes = file.bytes;
        
        if (bytes != null) {
          final base64String = base64Encode(bytes);
          await _saveAvatarData("base64", base64String);
        } else if (file.path != null) {
          final ioFile = io.File(file.path!);
          final fileBytes = await ioFile.readAsBytes();
          final base64String = base64Encode(fileBytes);
          await _saveAvatarData("base64", base64String);
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal memilih gambar: $e"),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  void _showAvatarPickerSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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
                "Ubah Foto Profil",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.photo_library_rounded, color: Theme.of(context).colorScheme.primary),
                ),
                title: Text(
                  "Pilih dari Galeri",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImageFromGallery();
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.emoji_emotions_rounded, color: Colors.amber),
                ),
                title: Text(
                  "Pilih Emoji / Avatar Kustom",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showEmojiPresetPicker(context, isDark);
                },
              ),
              if (_avatarType != "initials") ...[
                const SizedBox(height: 8),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.delete_rounded, color: Color(0xFFEF4444)),
                  ),
                  title: const Text(
                    "Reset ke Default (Inisial)",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _saveAvatarData("initials", null);
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showEmojiPresetPicker(BuildContext context, bool isDark) {
    int selectedGradientIndex = 0;
    String selectedEmoji = "👨‍💻";

    if (_avatarType == "emoji" && _avatarValue != null) {
      final parts = _avatarValue!.split("|");
      if (parts.length == 2) {
        selectedGradientIndex = int.tryParse(parts[0]) ?? 0;
        selectedEmoji = parts[1];
      }
    }

    final emojis = ["👨‍💻", "👩‍💻", "🦊", "🐼", "🚀", "🛡️", "⚡", "🌟", "👾", "🎨", "☕", "🔑"];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                    "Pilih Warna & Emoji",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: _presetGradients[selectedGradientIndex],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _presetGradients[selectedGradientIndex][0].withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        selectedEmoji,
                        style: const TextStyle(fontSize: 36),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Warna Latar Belakang",
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _presetGradients.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final colors = _presetGradients[index];
                        final isSelected = selectedGradientIndex == index;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectedGradientIndex = index;
                            });
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: colors,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: isSelected
                                  ? Border.all(
                                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                                      width: 2.5,
                                    )
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Pilih Emoji",
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: emojis.map((emoji) {
                      final isSelected = selectedEmoji == emoji;
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            selectedEmoji = emoji;
                          });
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                                : isDark
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFFF8FAFC),
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(
                                    color: Theme.of(context).colorScheme.primary,
                                    width: 2,
                                  )
                                : Border.all(
                                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                    width: 1,
                                  ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _saveAvatarData("emoji", "$selectedGradientIndex|$selectedEmoji");
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Simpan Pilihan"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAvatarChild(String name, bool isDark) {
    if (_avatarType == "base64") {
      return const SizedBox.shrink();
    }
    if (_avatarType == "emoji" && _avatarValue != null) {
      final parts = _avatarValue!.split("|");
      if (parts.length == 2) {
        return Text(
          parts[1],
          style: const TextStyle(fontSize: 38),
        );
      }
    }
    return Text(
      _getInitials(name),
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        color: isDark ? Colors.white : Theme.of(context).colorScheme.primary,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildAvatarWidget(String name, bool isDark) {
    DecorationImage? image;
    Gradient? gradient;
    Color? bgColor;

    if (_avatarType == "base64" && _avatarValue != null) {
      try {
        final bytes = base64Decode(_avatarValue!);
        image = DecorationImage(
          image: MemoryImage(bytes),
          fit: BoxFit.cover,
        );
      } catch (e) {
        debugPrint("Error loading base64 avatar: $e");
      }
    } else if (_avatarType == "emoji" && _avatarValue != null) {
      final parts = _avatarValue!.split("|");
      if (parts.length == 2) {
        final gradientIndex = int.tryParse(parts[0]) ?? 0;
        gradient = LinearGradient(
          colors: _presetGradients[gradientIndex],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      }
    }

    if (image == null && gradient == null) {
      bgColor = isDark ? const Color(0xFF161B2E) : const Color(0xFFEBF6FF);
    }

    return Container(
      width: 83,
      height: 83,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
        gradient: gradient,
        image: image,
      ),
      alignment: Alignment.center,
      child: _buildAvatarChild(name, isDark),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final dashboard = context.watch<DashboardProvider>();
    
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    final name = authProvider.name ?? "User";
    final email = authProvider.email ?? "-";
    final role = authProvider.role ?? "user";

    final openCount = dashboard.open;
    final pendingCount = dashboard.pending;
    final closedCount = dashboard.closed;

    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background with Bokeh/Light Circle Effect
          Container(
            height: MediaQuery.of(context).size.height * 0.32,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [Theme.of(context).colorScheme.primaryContainer, Theme.of(context).scaffoldBackgroundColor]
                    : [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -50,
                  right: -30,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: isDark ? 0.04 : 0.08),
                    ),
                  ),
                ),
                Positioned(
                  top: 30,
                  left: 60,
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: isDark ? 0.03 : 0.06),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -20,
                  right: 40,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: isDark ? 0.02 : 0.05),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // App Bar / Back Button (Title Text Removed)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (Navigator.canPop(context))
                        IconButton(
                          onPressed: () => Navigator.maybePop(context),
                          icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : const Color(0xFF1E293B)),
                        )
                      else
                        const SizedBox(height: 48), // Keep vertical spacing if no back button
                    ],
                  ),

                  const SizedBox(height: 48), // push content down so avatar overlaps nicely

                  // Overlapping Card with Avatar
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      // Glassmorphic Main Info Card
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 45), // Push down to let avatar overlap
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20), // 60 top padding for avatar overlap
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E293B).withValues(alpha: 0.8)
                                    : Colors.white.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF334155).withValues(alpha: 0.6)
                                      : const Color(0xFFFFFFFF).withValues(alpha: 0.5),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  // Name & Badge Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
                                                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                                                letterSpacing: -0.2,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              email,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _buildRoleBadge(role),
                                    ],
                                  ),

                                  const SizedBox(height: 20),

                                  // Stats Grid (Open, Pending, Closed)
                                  Row(
                                    children: [
                                      _buildStatCard(openCount.toString(), "Terbuka", isDark),
                                      const SizedBox(width: 10),
                                      _buildStatCard(pendingCount.toString(), "Diproses", isDark),
                                      const SizedBox(width: 10),
                                      _buildStatCard(closedCount.toString(), "Selesai", isDark),
                                    ],
                                  ),

                                  const SizedBox(height: 20),

                                  // Action Banner
                                  _buildActionBanner(role, isDark),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Centered Avatar Overlap with GestureDetector & Online Indicator
                      Positioned(
                        top: 0,
                        child: GestureDetector(
                          onTap: () => _showAvatarPickerSheet(context, isDark),
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.12),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: isDark ? Theme.of(context).colorScheme.primary : Colors.white,
                                    width: 3.5,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: _buildAvatarWidget(name, isDark),
                              ),
                              // Edit badge indicator
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.edit_rounded,
                                    size: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              // Online Status Indicator
                              Positioned(
                                bottom: 2,
                                right: 2,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981), // Neon Green
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF10B981).withValues(alpha: 0.4),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Options List
                  _buildOptionsCard(isDark, themeProvider, authProvider),

                  const SizedBox(height: 28),

                  // Footer
                  Text(
                    "IT Helpdesk System  •  v1.2.0",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    IconData icon;
    String label;
    Gradient gradient;

    switch (role.toLowerCase()) {
      case 'admin':
        icon = Icons.shield_outlined;
        label = 'Admin VIP';
        gradient = const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
        );
        break;
      case 'helpdesk':
        icon = Icons.headset_mic_rounded;
        label = 'Support';
        gradient = const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
        );
        break;
      default:
        icon = Icons.person_rounded;
        label = 'User Pro';
        gradient = const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
        );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String number, String label, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
            width: 1.0,
          ),
        ),
        child: Column(
          children: [
            Text(
              number,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBanner(String role, bool isDark) {
    final isUser = role.toLowerCase() == 'user';
    final title = isUser ? "Butuh Bantuan Cepat?" : "Pantau Antrean Tiket";
    final subtitle = isUser
        ? "Buat tiket baru untuk mendapatkan respon cepat."
        : "Kelola tiket masuk dan tingkatkan SLA.";
    final buttonText = isUser ? "Buat Tiket" : "Dashboard";
    final targetIndex = isUser ? 2 : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star_rounded,
              color: Color(0xFFFBBF24),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              TabSwitchNotification(targetIndex).dispatch(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0F172A),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsCard(bool isDark, ThemeProvider themeProvider, AuthProvider authProvider) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
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
        children: [
          _buildOptionRow(
            icon: Icons.badge_outlined,
            title: "Detail Akun",
            subtitle: "Informasi profil & role Anda",
            isDark: isDark,
            onTap: () => _showAccountDetails(context, authProvider, isDark),
          ),
          _buildDivider(isDark),
          _buildOptionRow(
            icon: Icons.settings_outlined,
            title: "Pengaturan",
            subtitle: "Setelan & preferensi sistem",
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
          _buildDivider(isDark),
          _buildOptionRow(
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
          _buildDivider(isDark),
          _buildOptionRow(
            icon: Icons.logout_rounded,
            title: "Logout",
            subtitle: "Keluar dari aplikasi",
            isDark: isDark,
            isDestructive: true,
            onTap: () => _showLogoutConfirmation(context, authProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    Widget? trailing,
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    final Color color = isDestructive
        ? const Color(0xFFEF4444)
        : isDark
            ? Colors.white
            : const Color(0xFF1E293B);

    final Color subtitleColor = isDestructive
        ? const Color(0xFFF87171)
        : isDark
            ? const Color(0xFF94A3B8)
            : const Color(0xFF64748B);

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
                color: isDestructive
                    ? const Color(0xFFEF4444).withValues(alpha: 0.1)
                    : isDark
                        ? const Color(0xFF334155).withValues(alpha: 0.5)
                        : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isDestructive ? const Color(0xFFEF4444) : Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: subtitleColor,
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
                color: isDestructive
                    ? const Color(0xFFEF4444).withValues(alpha: 0.7)
                    : isDark
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8),
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

  void _showAccountDetails(BuildContext context, AuthProvider authProvider, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                "Detail Akun",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 16),
              _buildDetailTile(
                label: "Nama Lengkap",
                value: authProvider.name ?? "-",
                isDark: isDark,
              ),
              _buildDetailTile(
                label: "Email",
                value: authProvider.email ?? "-",
                isDark: isDark,
              ),
              _buildDetailTile(
                label: "Role",
                value: (authProvider.role ?? "user").toUpperCase(),
                isDark: isDark,
              ),
              _buildDetailTile(
                label: "User ID",
                value: authProvider.userId ?? "-",
                isDark: isDark,
                onCopy: () {
                  if (authProvider.userId != null) {
                    Clipboard.setData(ClipboardData(text: authProvider.userId!));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
                            SizedBox(width: 8),
                            Text("User ID berhasil disalin ke clipboard!"),
                          ],
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailTile({
    required String label,
    required String value,
    required bool isDark,
    VoidCallback? onCopy,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
            if (onCopy != null)
              IconButton(
                icon: Icon(
                  Icons.copy_rounded,
                  size: 16,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
                onPressed: onCopy,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFEF4444),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Konfirmasi Keluar",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Apakah Anda yakin ingin keluar dari akun Anda?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                            ),
                          ),
                        ),
                        child: Text(
                          "Batal",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(dialogContext); // Close dialog using dialogContext

                          if (context.mounted) {
                            context.read<NotificationProvider>().clear();
                            context.read<TicketProvider>().clear();
                            context.read<TicketHistoryProvider>().clear();
                          }
                          await authProvider.logout();

                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Keluar",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}