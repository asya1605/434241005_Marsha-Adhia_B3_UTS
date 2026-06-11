import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/ticket_model.dart';
import '../../data/models/comment_model.dart';
import '../../data/repositories/ticket_repository.dart';
import '../providers/comment_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class TicketDetailScreen extends StatefulWidget {
  final TicketModel ticket;

  const TicketDetailScreen({
    super.key,
    required this.ticket,
  });

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final TextEditingController commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String selectedStatus = "Open";
  String? selectedHelpdeskId;
  String? selectedHelpdeskName;
  String? _savedStatus;
  String? _savedHelpdeskId;
  bool isSaving = false;
  List<Map<String, dynamic>> helpdeskList = [];

  final List<String> statusList = ["Open", "Process", "Done"];

  // Local caches to resolve profile details for commenters
  final Map<String, String> _commenterNames = {};
  final Map<String, String> _commenterRoles = {};
  final Map<String, String> _commenterEmails = {};
  String _creatorEmail = "user@mail.com";
  String? _agentEmail;

  // Custom visual state variables
  int _activeTab = 0; // 0 = Riwayat status, 1 = Diskusi
  bool _isTimelineExpanded = false;

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.ticket.status;
    selectedHelpdeskId = widget.ticket.assignedTo;
    selectedHelpdeskName = widget.ticket.assignedName;
    _savedStatus = widget.ticket.status;
    _savedHelpdeskId = widget.ticket.assignedTo;

    // Load initial metadata asynchronously
    _fetchCreatorName();
    _fetchHelpdeskUsers();
    _fetchAgentEmail();
  }

  @override
  void dispose() {
    commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Stable hashing of the UUID to dynamically compute deterministic category and priority
  int _stableHash(String value) {
    int hash = 0;
    for (int i = 0; i < value.length; i++) {
      hash = value.codeUnitAt(i) + ((hash << 5) - hash);
    }
    return hash.abs();
  }

  String _getMockCategory(String id) {
    final categories = ["Hardware", "Software", "Network"];
    return categories[_stableHash(id) % categories.length];
  }

  String _getMockPriority(String id) {
    final priorities = ["Low", "Medium", "High"];
    return priorities[(_stableHash(id) ~/ 3) % priorities.length];
  }

  // Fetch ticket creator's name and email
  Future<void> _fetchCreatorName() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('user_profiles')
          .select('name')
          .eq('id', widget.ticket.userId)
          .single();
      if (mounted) {
        setState(() {
          _creatorEmail = response['name']?.toString() ?? 'user@mail.com';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _creatorEmail = "user@mail.com";
        });
      }
    }
  }

  // Fetch agent's email
  Future<void> _fetchAgentEmail() async {
    if (selectedHelpdeskId == null) {
      if (mounted) {
        setState(() {
          _agentEmail = null;
        });
      }
      return;
    }
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('user_profiles')
          .select('name')
          .eq('id', selectedHelpdeskId!)
          .single();
      if (mounted) {
        setState(() {
          _agentEmail = response['name']?.toString() ?? 'helpdesk@mail.com';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _agentEmail = 'helpdesk@mail.com';
        });
      }
    }
  }

  // Fetch helpdesk list for assignment dropdown
  Future<void> _fetchHelpdeskUsers() async {
    try {
      final repo = TicketRepository();
      final data = await repo.getHelpdeskUsers();
      if (mounted) {
        setState(() {
          helpdeskList = data;
          // Resolve name and email if only ID was loaded
          if (selectedHelpdeskId != null) {
            final agent = helpdeskList.firstWhere(
              (e) => e['id']?.toString() == selectedHelpdeskId,
              orElse: () => <String, dynamic>{},
            );
            if (agent.isNotEmpty) {
              selectedHelpdeskName = agent['name']?.toString();
              _agentEmail = agent['name']?.toString();
            }
          }
        });
        if (_agentEmail == null && selectedHelpdeskId != null) {
          _fetchAgentEmail();
        }
      }
    } catch (e) {
      debugPrint("Error loading helpdesk users: $e");
    }
  }

  // Save status and assignment changes to the repository
  Future<void> _saveChanges() async {
    if (selectedStatus == _savedStatus && selectedHelpdeskId == _savedHelpdeskId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "No changes to save",
            style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
          ),
          backgroundColor: AppColors.statusProcess,
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final repo = TicketRepository();
      
      // Update status if it changed
      if (selectedStatus != _savedStatus) {
        await repo.updateStatus(widget.ticket.id, selectedStatus);
        _savedStatus = selectedStatus;
      }
      
      // Update assigned agent if it changed
      if (selectedHelpdeskId != _savedHelpdeskId) {
        await repo.assignTicket(widget.ticket.id, selectedHelpdeskId);
        _savedHelpdeskId = selectedHelpdeskId;
        _fetchAgentEmail();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Changes saved successfully",
              style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
            ),
            backgroundColor: AppColors.statusClosed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Failed to save changes: $e",
              style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
            ),
            backgroundColor: AppColors.priorityHigh,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // Fetch profiles dynamically for commenter user_ids to display real names and emails
  Future<void> _fetchCommenterProfiles(List<Comment> comments) async {
    final userIds = comments.map((c) => c.userId).toSet().toList();
    if (userIds.isEmpty) return;

    final missingIds = userIds.where((id) => !_commenterNames.containsKey(id)).toList();
    if (missingIds.isEmpty) return;

    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('user_profiles')
          .select('id, name, role')
          .inFilter('id', missingIds);

      if (mounted) {
        setState(() {
          for (var row in response) {
            final id = row['id']?.toString() ?? '';
            final name = row['name']?.toString() ?? 'User';
            final role = row['role']?.toString() ?? 'user';
            final email = name; // Under our DB schema, name column contains the email address.
            _commenterNames[id] = name;
            _commenterRoles[id] = role;
            _commenterEmails[id] = email;
          }
        });
      }
    } catch (e) {
      debugPrint("Error loading commenter profiles: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final role = authProvider.role ?? "user";
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChangeNotifierProvider(
      create: (_) => CommentProvider()..loadComments(widget.ticket.id),
      child: Consumer<CommentProvider>(
        builder: (context, commentProvider, _) {
          // Trigger profile resolution after build frame
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _fetchCommenterProfiles(commentProvider.comments);
          });

          return Scaffold(
            backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
            appBar: AppBar(
              title: Text(
                'Ticket Details',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// 1. Header Ticket
                          _buildHeaderCard(isDark),
                          const SizedBox(height: 16),

                          /// 2. Kelola Tiket (Admin / Helpdesk only)
                          if (role != "user") ...[
                            _buildManagementCard(context, role, isDark),
                            const SizedBox(height: 16),
                          ],

                          /// 3. Lampiran
                          _buildAttachmentCard(isDark),
                          const SizedBox(height: 16),

                          /// 4. Aktivitas
                          _buildAktivitasCard(commentProvider, isDark),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  /// 6. Sticky Bottom Comment Input Bar
                  _buildCommentInputBar(context, commentProvider, role, isDark),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  double _getSlaProgress(String status) {
    if (status.toLowerCase() == 'done') return 1.0;
    final baseProgress = ((_stableHash(widget.ticket.id) % 30) + 45) / 100.0;
    return baseProgress;
  }

  Color _getSlaColor(double progress, String status) {
    if (status.toLowerCase() == 'done') return AppColors.statusClosed;
    if (progress > 0.8) return AppColors.priorityHigh;
    if (progress > 0.6) return AppColors.statusProcess;
    return AppColors.blue;
  }

  String _formatDateIndo(DateTime date) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildBadge({
    required String text,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    IconData icon;
    Color color;
    Color bgColor;

    switch (status.toLowerCase()) {
      case 'done':
        icon = Icons.check_rounded;
        color = AppColors.statusClosed;
        bgColor = AppColors.statusClosed.withOpacity(0.1);
        break;
      case 'process':
        icon = Icons.sync_rounded;
        color = AppColors.statusProcess;
        bgColor = AppColors.statusProcess.withOpacity(0.1);
        break;
      case 'pending':
        icon = Icons.pause_circle_outline_rounded;
        color = AppColors.statusPending;
        bgColor = AppColors.statusPending.withOpacity(0.1);
        break;
      case 'open':
      default:
        icon = Icons.fiber_new_rounded;
        color = AppColors.statusOpen;
        bgColor = AppColors.statusOpen.withOpacity(0.1);
        break;
    }

    return _buildBadge(
      text: status,
      icon: icon,
      color: color,
      bgColor: bgColor,
    );
  }

  Widget _buildPriorityBadge(String priority) {
    IconData icon;
    Color color;
    Color bgColor;

    switch (priority.toLowerCase()) {
      case 'high':
        icon = Icons.arrow_upward_rounded;
        color = AppColors.priorityHigh;
        bgColor = AppColors.priorityHigh.withOpacity(0.1);
        break;
      case 'medium':
        icon = Icons.drag_handle_rounded;
        color = AppColors.priorityMed;
        bgColor = AppColors.priorityMed.withOpacity(0.1);
        break;
      case 'low':
      default:
        icon = Icons.arrow_downward_rounded;
        color = AppColors.priorityLow;
        bgColor = AppColors.priorityLow.withOpacity(0.1);
        break;
    }

    return _buildBadge(
      text: priority,
      icon: icon,
      color: color,
      bgColor: bgColor,
    );
  }

  Widget _buildCategoryBadge(String category) {
    IconData icon;
    switch (category.toLowerCase()) {
      case 'hardware':
        icon = Icons.settings_outlined;
        break;
      case 'software':
        icon = Icons.code_rounded;
        break;
      case 'network':
      default:
        icon = Icons.wifi_rounded;
        break;
    }

    return _buildBadge(
      text: category,
      icon: icon,
      color: AppColors.blue,
      bgColor: AppColors.blue.withOpacity(0.1),
    );
  }

  Widget _buildHeaderCard(bool isDark) {
    final category = _getMockCategory(widget.ticket.id);
    final priority = _getMockPriority(widget.ticket.id);
    final shortId = widget.ticket.id.length > 5 
        ? widget.ticket.id.substring(0, 5).toUpperCase() 
        : widget.ticket.id.toUpperCase();

    final slaProgress = _getSlaProgress(selectedStatus);
    final slaColor = _getSlaColor(slaProgress, selectedStatus);
    final percentText = "${(slaProgress * 100).toInt()}% selesai";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ID ticket kecil dan muted
          Text(
            '#TCK-$shortId',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFF64748B) : AppColors.textHint,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),

          // Judul paling dominan
          Text(
            widget.ticket.title,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 12),

          // Badge status, priority, category dalam satu baris
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatusBadge(selectedStatus),
                const SizedBox(width: 8),
                _buildPriorityBadge(priority),
                const SizedBox(width: 8),
                _buildCategoryBadge(category),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Grid informasi 2 kolom
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                children: [
                  _buildMetaGridItem("DIBUAT OLEH", _creatorEmail, isDark),
                  _buildMetaGridItem("AGEN", selectedHelpdeskName != null ? _agentEmail ?? 'helpdesk@mail.com' : 'Unassigned', isDark),
                ],
              ),
              const TableRow(
                children: [
                  SizedBox(height: 14),
                  SizedBox(height: 14),
                ],
              ),
              TableRow(
                children: [
                  _buildMetaGridItem("DIBUAT", _formatDateIndo(widget.ticket.createdAt), isDark),
                  _buildMetaGridItem("SLA DEADLINE", _formatDateIndo(widget.ticket.createdAt.add(const Duration(days: 3))), isDark),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // SLA progress berada paling bawah
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "SLA Progress",
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark ? const Color(0xFF64748B) : AppColors.textHint,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                percentText,
                style: GoogleFonts.outfit(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: slaColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: slaProgress,
              minHeight: 8,
              backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(slaColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaGridItem(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isDark ? const Color(0xFF64748B) : AppColors.textHint,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : AppColors.textSecondary,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildManagementCard(BuildContext context, String role, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Kelola tiket",
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Status pengerjaan
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Status pengerjaan",
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: selectedStatus,
                      dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark ? AppColors.surface2Dark : const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.blue,
                            width: 1.5,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            width: 1,
                          ),
                        ),
                      ),
                      items: statusList.map((s) {
                        return DropdownMenuItem(value: s, child: Text(s));
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          selectedStatus = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // 2. Assign agen
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Assign agen",
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (role == "admin")
                      DropdownButtonFormField<String?>(
                        isExpanded: true,
                        initialValue: (selectedHelpdeskId == null || !helpdeskList.any((e) => e['id']?.toString() == selectedHelpdeskId))
                            ? null
                            : selectedHelpdeskId,
                        dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: "Unassigned",
                          hintStyle: GoogleFonts.outfit(
                            color: isDark ? Colors.white24 : AppColors.textHint,
                            fontSize: 13,
                          ),
                          filled: true,
                          fillColor: isDark ? AppColors.surface2Dark : const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? AppColors.borderDark : AppColors.borderLight,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.blue,
                              width: 1.5,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? AppColors.borderDark : AppColors.borderLight,
                              width: 1,
                            ),
                          ),
                        ),
                        items: [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text(
                              'Unassigned',
                              style: GoogleFonts.outfit(
                                color: isDark ? Colors.white30 : AppColors.textHint,
                              ),
                            ),
                          ),
                          ...helpdeskList.map((e) {
                            return DropdownMenuItem<String?>(
                              value: e['id']?.toString(),
                              child: Text(
                                e['name'] ?? 'No Name',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            );
                          }),
                        ],
                        selectedItemBuilder: (BuildContext context) {
                          return [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Unassigned',
                                    style: GoogleFonts.outfit(
                                      color: isDark ? Colors.white30 : AppColors.textHint,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                            ...helpdeskList.map((e) {
                              return Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      e['name'] ?? 'No Name',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ];
                        },
                        onChanged: (value) {
                          setState(() {
                            selectedHelpdeskId = value;
                            if (value == null) {
                              selectedHelpdeskName = null;
                            } else {
                              final agent = helpdeskList.firstWhere(
                                (e) => e['id']?.toString() == value,
                                orElse: () => <String, dynamic>{},
                              );
                              selectedHelpdeskName = agent['name']?.toString();
                            }
                          });
                        },
                      )
                    else
                      // If Helpdesk, show static assigned info box styled like input field
                      Container(
                        width: double.infinity,
                        height: 43,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surface2Dark : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          selectedHelpdeskName ?? 'Unassigned',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 3. Save Changes Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isSaving ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      "Simpan perubahan",
                      style: GoogleFonts.outfit(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isPdf(String url) {
    return url.toLowerCase().contains('.pdf') || url.toLowerCase().split('?').first.endsWith('.pdf');
  }

  String _getFileName(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        final last = pathSegments.last;
        return Uri.decodeComponent(last);
      }
    } catch (_) {}
    return "attachment";
  }

  Widget _buildAttachmentCard(bool isDark) {
    final hasAttachment = widget.ticket.imageUrl != null && widget.ticket.imageUrl!.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Lampiran",
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (!hasAttachment)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surface2Dark : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.attach_file_rounded,
                        size: 20,
                        color: AppColors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Tidak ada lampiran",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white70 : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surface2Dark : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Row(
                children: [
                  // Icon file / Image thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _isPdf(widget.ticket.imageUrl!)
                        ? Container(
                            width: 48,
                            height: 48,
                            color: Colors.red.withOpacity(0.1),
                            child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.red, size: 28),
                          )
                        : GestureDetector(
                            onTap: () => _openFullscreenImage(context),
                            child: Image.network(
                              widget.ticket.imageUrl!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (context, _, __) => Container(
                                width: 48,
                                height: 48,
                                color: Colors.grey.withOpacity(0.1),
                                child: const Icon(Icons.insert_drive_file_rounded, color: Colors.grey, size: 24),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getFileName(widget.ticket.imageUrl!),
                      style: GoogleFonts.outfit(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.download_rounded, size: 20, color: isDark ? Colors.white54 : AppColors.textSecondary),
                    onPressed: () {
                      if (!_isPdf(widget.ticket.imageUrl!)) {
                        _openFullscreenImage(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Membuka tautan PDF: ${_getFileName(widget.ticket.imageUrl!)}",
                              style: GoogleFonts.outfit(fontWeight: FontWeight.w500),
                            ),
                            backgroundColor: AppColors.blue,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _openFullscreenImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Image.network(widget.ticket.imageUrl!),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAktivitasCard(CommentProvider commentProvider, bool isDark) {
    final events = _getTimelineEvents(commentProvider.comments);
    final totalActivity = events.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Aktivitas [counter total]
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Aktivitas",
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  "$totalActivity total",
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tab buttons
          Row(
            children: [
              _buildTabItem(0, "Riwayat status", isDark),
              const SizedBox(width: 20),
              _buildTabItem(1, "Diskusi (${commentProvider.comments.length})", isDark),
            ],
          ),
          Container(
            height: 1,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
            color: isDark ? Colors.white.withOpacity(0.06) : AppColors.borderLight.withOpacity(0.6),
          ),

          // Content based on tab
          _activeTab == 0
              ? _buildTimelineFeed(events, isDark)
              : _buildDiscussionFeed(commentProvider, isDark),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label, bool isDark) {
    final isActive = _activeTab == index;
    return InkWell(
      onTap: () {
        setState(() {
          _activeTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? AppColors.blue : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive
                ? AppColors.blue
                : (isDark ? const Color(0xFF64748B) : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineFeed(List<_TimelineEvent> events, bool isDark) {
    final visibleEvents = _isTimelineExpanded || events.length <= 2
        ? events
        : events.sublist(0, 2);

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: visibleEvents.length,
            itemBuilder: (context, index) {
              final event = visibleEvents[index];
              final isLast = index == visibleEvents.length - 1;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline nodes & connector lines
                    Column(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: event.color.withOpacity(0.12),
                            shape: BoxShape.circle,
                            border: Border.all(color: event.color.withOpacity(0.3), width: 1.5),
                          ),
                          child: Center(
                            child: Icon(event.icon, size: 12, color: event.color),
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 1.5,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),

                    // Event details
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.title,
                              style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : AppColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              event.description,
                              style: GoogleFonts.outfit(
                                fontSize: 11.5,
                                color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _formatTimelineTime(event.timestamp),
                              style: GoogleFonts.outfit(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white30 : AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          if (events.length > 2) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                setState(() {
                  _isTimelineExpanded = !_isTimelineExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const SizedBox(width: 38), // Align with timeline content
                    Text(
                      _isTimelineExpanded 
                          ? "Sembunyikan aktivitas"
                          : "+${events.length - 2} aktivitas lainnya...",
                      style: GoogleFonts.outfit(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  List<_TimelineEvent> _getTimelineEvents(List<Comment> comments) {
    final List<_TimelineEvent> events = [];

    // 1. Ticket Submission Event
    events.add(_TimelineEvent(
      title: "Tiket dibuat",
      description: "Dikirim oleh $_creatorEmail",
      timestamp: widget.ticket.createdAt,
      icon: Icons.add_circle_outline_rounded,
      color: AppColors.statusOpen,
    ));

    // 2. Ticket Assignment Event
    if (selectedHelpdeskName != null) {
      events.add(_TimelineEvent(
        title: "Agen di-assign",
        description: "$_agentEmail ditugaskan",
        timestamp: widget.ticket.createdAt.add(const Duration(seconds: 1)),
        icon: Icons.person_add_alt_1_rounded,
        color: AppColors.blue,
      ));
    }

    for (var comment in comments) {
      final role = comment.role.toLowerCase();
      final email = _commenterEmails[comment.userId] ?? 
          (role == 'admin' ? 'admin@mail.com' : role == 'helpdesk' ? 'helpdesk@mail.com' : 'user@mail.com');

      String title = "User membalas";
      if (role == 'admin') {
        title = "Admin membalas";
      } else if (role == 'helpdesk') {
        title = "Agen membalas";
      }

      events.add(_TimelineEvent(
        title: title,
        description: email,
        timestamp: comment.createdAt,
        icon: Icons.chat_bubble_outline_rounded,
        color: role == 'admin' 
            ? AppColors.priorityHigh 
            : role == 'helpdesk' 
                ? AppColors.statusPending 
                : AppColors.blueLight,
      ));
    }

    // 4. Status updates events (derived based on current values)
    if (selectedStatus == "Process") {
      events.add(_TimelineEvent(
        title: "Status diubah ke Process",
        description: "Status diubah ke Process",
        timestamp: comments.isNotEmpty ? comments.first.createdAt.add(const Duration(minutes: 5)) : DateTime.now(),
        icon: Icons.sync_rounded,
        color: AppColors.statusProcess,
      ));
    } else if (selectedStatus == "Done" || selectedStatus == "Closed") {
      events.add(_TimelineEvent(
        title: "Tiket diselesaikan",
        description: "Status diubah ke Done",
        timestamp: comments.isNotEmpty ? comments.last.createdAt.add(const Duration(minutes: 10)) : DateTime.now(),
        icon: Icons.check_circle_outline_rounded,
        color: AppColors.statusClosed,
      ));
    }

    // Sort chronologically (oldest to newest)
    events.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return events;
  }

  Widget _buildDiscussionFeed(CommentProvider commentProvider, bool isDark) {
    if (commentProvider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final comments = commentProvider.comments;
    if (comments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface2Dark : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.forum_outlined,
              size: 38,
              color: isDark ? Colors.white24 : AppColors.textHint,
            ),
            const SizedBox(height: 8),
            Text(
              "No replies yet",
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white54 : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Send a message below to start the conversation.",
              style: GoogleFonts.outfit(
                fontSize: 11.5,
                color: isDark ? Colors.white24 : AppColors.textHint,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        final currentUserId = Supabase.instance.client.auth.currentUser?.id;
        final isCurrentUser = comment.userId == currentUserId;
        final senderName = _commenterNames[comment.userId] ?? "User";
        final senderRole = _commenterRoles[comment.userId] ?? comment.role;
        final senderEmail = _commenterEmails[comment.userId] ?? 
            (senderRole == 'admin' ? 'admin@mail.com' : senderRole == 'helpdesk' ? 'helpdesk@mail.com' : 'user@mail.com');

        return _buildChatBubble(comment, isCurrentUser, senderName, senderRole, senderEmail, isDark);
      },
    );
  }

  Widget _buildChatBubble(
    Comment comment,
    bool isCurrentUser,
    String senderName,
    String senderRole,
    String senderEmail,
    bool isDark,
  ) {
    final roleColor = senderRole.toLowerCase() == 'admin'
        ? AppColors.priorityHigh
        : senderRole.toLowerCase() == 'helpdesk'
            ? AppColors.statusPending
            : AppColors.blue;

    final initial = senderName.isNotEmpty ? senderName[0].toUpperCase() : 'U';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar Left
          if (!isCurrentUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: roleColor.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: roleColor.withOpacity(0.3), width: 1),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: roleColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Bubble Column
          Flexible(
            child: Column(
              crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Metadata Row
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: isCurrentUser
                      ? [
                          Text(
                            senderEmail,
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white30 : AppColors.textHint,
                            ),
                          ),
                          const SizedBox(width: 6),
                          _buildRoleBadge(senderRole),
                        ]
                      : [
                          _buildRoleBadge(senderRole),
                          const SizedBox(width: 6),
                          Text(
                            senderEmail,
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white30 : AppColors.textHint,
                            ),
                          ),
                        ],
                ),
                const SizedBox(height: 6),

                // Message Bubble
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isCurrentUser
                        ? AppColors.blue
                        : (isDark ? AppColors.surface2Dark : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: isCurrentUser ? const Radius.circular(12) : Radius.zero,
                      bottomRight: isCurrentUser ? Radius.zero : const Radius.circular(12),
                    ),
                    border: Border.all(
                      color: isCurrentUser
                          ? Colors.transparent
                          : (isDark ? AppColors.borderDark : AppColors.borderLight),
                    ),
                  ),
                  child: Text(
                    comment.message,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      height: 1.4,
                      color: isCurrentUser
                          ? Colors.white
                          : (isDark ? Colors.white70 : AppColors.textPrimary),
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // Timestamp
                Text(
                  _formatTimelineTime(comment.createdAt),
                  style: GoogleFonts.outfit(
                    fontSize: 9.5,
                    color: isDark ? Colors.white30 : AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),

          // Avatar Right
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: roleColor.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: roleColor.withOpacity(0.3), width: 1),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: roleColor,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    final roleColor = role.toLowerCase() == 'admin'
        ? AppColors.priorityHigh
        : role.toLowerCase() == 'helpdesk'
            ? AppColors.statusPending
            : AppColors.blue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: roleColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        role.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 8.5,
          fontWeight: FontWeight.w800,
          color: roleColor,
        ),
      ),
    );
  }

  String _formatTimelineTime(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final monthStr = months[date.month - 1];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day} $monthStr · $hour:$minute';
  }

  Widget _buildCommentInputBar(
    BuildContext context,
    CommentProvider commentProvider,
    String role,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surface2Dark : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: commentController,
                style: GoogleFonts.outfit(
                  fontSize: 13.5,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Tulis balasan...',
                  hintStyle: GoogleFonts.outfit(
                    color: isDark ? const Color(0xFF64748B) : AppColors.textHint,
                    fontSize: 13.5,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 48,
            width: 48,
            decoration: const BoxDecoration(
              color: AppColors.blue,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 18,
              ),
              onPressed: () async {
                final text = commentController.text.trim();
                if (text.isNotEmpty) {
                  commentController.clear();
                  
                  await commentProvider.sendComment(
                    widget.ticket.id,
                    text,
                    role,
                  );

                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (_scrollController.hasClients) {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                      );
                    }
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Private timeline event model helper class
class _TimelineEvent {
  final String title;
  final String description;
  final DateTime timestamp;
  final IconData icon;
  final Color color;

  _TimelineEvent({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.icon,
    required this.color,
  });
}