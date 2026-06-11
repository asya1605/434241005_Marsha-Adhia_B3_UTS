import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

import '../../../../navigation/admin_navigation.dart';
import '../../../../navigation/helpdesk_navigation.dart';
import '../../../../navigation/user_navigation.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F1117) : const Color(0xFFF4F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  /// HEADER (TIDAK DIUBAH)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                const Color(0xFF1A1F35),
                                const Color(0xFF0D1321)
                              ]
                            : [
                                const Color(0xFF1E40AF),
                                const Color(0xFF3B82F6)
                              ],
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(32, 48, 32, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'HelpDesk',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'Welcome back',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Sign in to your account to continue',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.72),
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// FORM
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color:
                            isDark ? const Color(0xFF161B2E) : Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(28, 36, 28, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Sign In",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(height: 24),

                          /// EMAIL
                          TextField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              labelText: "Email",
                              border: OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 20),

                          /// PASSWORD
                          TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: "Password",
                              border: OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 10),

                          /// FORGOT
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ForgotPasswordScreen(),
                                  ),
                                );
                              },
                              child: const Text("Forgot Password?"),
                            ),
                          ),

                          const SizedBox(height: 20),

                          /// LOGIN BUTTON
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () async {
                                String email =
                                    emailController.text.trim();
                                String password =
                                    passwordController.text.trim();

                                if (email.isEmpty ||
                                    password.isEmpty) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          "Email dan Password wajib diisi"),
                                    ),
                                  );
                                  return;
                                }

                                bool success = await context
                                    .read<AuthProvider>()
                                    .login(email, password);

                                 if (success) {
                                   final provider = context.read<AuthProvider>();

                                   // SIMULASI REMINDER PASSWORD DEFAULT (Demo Purpose)
                                   if (password == "123456") {
                                     ScaffoldMessenger.of(context)
                                         .showSnackBar(
                                       const SnackBar(
                                         content: Text(
                                             "Silakan ganti password default Anda"),
                                         backgroundColor: Colors.orange,
                                       ),
                                     );
                                   }

                                   if (provider.role == "admin") {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const AdminNavigation(),
                                      ),
                                    );
                                  } else if (provider.role == "helpdesk") {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const HelpdeskNavigation(),
                                      ),
                                    );
                                  } else {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const UserNavigation(),
                                      ),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Login gagal"),
                                    ),
                                  );
                                }
                              },
                              child: authProvider.isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text("Login"),
                            ),
                          ),

                          const SizedBox(height: 10),

                          /// REGISTER
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const RegisterScreen(),
                                ),
                              );
                            },
                            child: const Text(
                                "Don't have an account? Register"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}