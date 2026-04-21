import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/ticket_model.dart';
import '../providers/ticket_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  bool isLoading = false;

  Uint8List? selectedImageBytes;

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        selectedImageBytes = result.files.single.bytes!;
      });
      print("IMAGE PICKED: ${selectedImageBytes!.length}");
    } else {
      print("NO IMAGE SELECTED");
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().role ?? "user";
    final isDark = Theme.of(context).brightness == Brightness.dark;

    /// Hanya USER yang boleh create ticket
    if (role != "user") {
      return Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0F1117) : const Color(0xFFF4F6FA),
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF161B2E) : Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Create Ticket',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF111827),
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E2438)
                        : const Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    size: 32,
                    color: Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Access Restricted',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Only users can create tickets.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
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
          'Create Ticket',
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
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ── INFO BANNER ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF2563EB).withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Fill in the details below to submit a new support ticket.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFF93C5FD)
                            : const Color(0xFF1D4ED8),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// ── FORM CARD ───────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TITLE field
                  _FieldLabel(label: 'Ticket Title', isDark: isDark),
                  const SizedBox(height: 8),
                  _StyledTextField(
                    controller: titleController,
                    hintText: 'e.g. Cannot access email on mobile',
                    prefixIcon: Icons.title_rounded,
                    isDark: isDark,
                  ),

                  const SizedBox(height: 20),

                  /// DESCRIPTION field
                  _FieldLabel(label: 'Description', isDark: isDark),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descController,
                    maxLines: 5,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF111827),
                    ),
                    decoration: InputDecoration(
                      hintText:
                          'Describe the issue in detail so our team can help you faster...',
                      hintStyle: TextStyle(
                        color: isDark
                            ? Colors.white30
                            : const Color(0xFFBFC8D7),
                        fontSize: 13,
                        height: 1.5,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF0F1117)
                          : const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? const Color(0xFF2D3554)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? const Color(0xFF2D3554)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF3B82F6),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// ── ATTACHMENT CARD ─────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel(label: 'Attachment', isDark: isDark),
                  const SizedBox(height: 4),
                  Text(
                    'Optional — attach a screenshot to help describe the issue.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white30 : const Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 14),

                  /// IMAGE PREVIEW
                  if (selectedImageBytes != null) ...[
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            selectedImageBytes!,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedImageBytes = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.55),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  /// IMAGE BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton.icon(
                      onPressed: pickImage,
                      icon: Icon(
                        selectedImageBytes != null
                            ? Icons.swap_horiz_rounded
                            : Icons.upload_rounded,
                        size: 18,
                      ),
                      label: Text(
                        selectedImageBytes != null
                            ? 'Change Image'
                            : 'Upload Image',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2563EB),
                        side: BorderSide(
                          color: isDark
                              ? const Color(0xFF2D3554)
                              : const Color(0xFF2563EB),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            /// ── SUBMIT BUTTON ────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  String title = titleController.text.trim();
                  String desc = descController.text.trim();

                  /// VALIDASI
                  if (title.isEmpty || desc.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Title and description are required"),
                      ),
                    );
                    return;
                  }

                  setState(() => isLoading = true);

                  try {
                    String? imageUrl;
                    if (selectedImageBytes != null) {
                      imageUrl = await context
                          .read<TicketProvider>()
                          .uploadImageBytes(selectedImageBytes!);
                    }

                    final ticket = TicketModel(
                      id: '', // dummy, nanti dari database
                      title: title,
                      description: desc,
                      status: "Open",
                      userId:
                          Supabase.instance.client.auth.currentUser?.id ?? '',
                      assignedTo: null,
                    );

                    await context
                        .read<TicketProvider>()
                        .createTicket(ticket, imageUrl: imageUrl);

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Ticket saved"),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Error: $e"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() => isLoading = false);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send_rounded, size: 18),
                    SizedBox(width: 10),
                    Text(
                      'Submit Ticket',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Private helper widgets ───────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool isDark;

  const _FieldLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF374151),
        letterSpacing: 0.1,
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool isDark;

  const _StyledTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: isDark ? Colors.white : const Color(0xFF111827),
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: isDark ? Colors.white30 : const Color(0xFFBFC8D7),
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: Icon(
            prefixIcon,
            size: 18,
            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          ),
        ),
        prefixIconConstraints:
            const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor:
            isDark ? const Color(0xFF0F1117) : const Color(0xFFF8FAFC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? const Color(0xFF2D3554)
                : const Color(0xFFE2E8F0),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? const Color(0xFF2D3554)
                : const Color(0xFFE2E8F0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF3B82F6),
            width: 2,
          ),
        ),
      ),
    );
  }
}