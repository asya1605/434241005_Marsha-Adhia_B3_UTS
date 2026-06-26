import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

import 'core/theme/app_theme.dart';
import 'splash/splash_screen.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/presentation/pages/reset_password_screen.dart';

import 'features/ticket/presentation/providers/ticket_provider.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/dashboard/presentation/providers/dashboard_provider.dart';
import 'features/notification/presentation/providers/notification_provider.dart';
import 'features/ticket/presentation/providers/comment_provider.dart';
import 'features/ticket/presentation/providers/ticket_history_provider.dart';
import 'features/admin/presentation/providers/user_management_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// INIT SUPABASE
  await Supabase.initialize(
    url: 'https://htjkrrsmdusxwfdvcxgt.supabase.co', 
    anonKey: 'sb_publishable_IBnKnq1-hnt_cssP517eAw_0_fnwMCw', 
    authOptions: const FlutterAuthClientOptions(
    authFlowType: AuthFlowType.pkce,
    ),
  );

  // Check user session
  print("USER: ${Supabase.instance.client.auth.currentUser?.email}"); 
     
  runApp(
    MultiProvider(
      providers: [

        /// THEME
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),

        /// AUTH
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),

        /// TICKET
        ChangeNotifierProvider(
          create: (_) => TicketProvider(),
        ),

        /// DASHBOARD
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(),
        ),

        /// NOTIFICATION
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) => CommentProvider()
        ),

        ChangeNotifierProvider(
          create: (_) => TicketHistoryProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserManagementProvider(),
        ),

      ],
      child: const MyApp(),
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.passwordRecovery) {
        if (mounted) {
          context.read<AuthProvider>().setRecoveringPassword(true);

          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const ResetPasswordScreen(),
            ),
            (route) => false,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Helpdesk Ticket',
      debugShowCheckedModeBanner: false,

      /// LIGHT MODE
      theme: AppTheme.lightTheme,

      /// DARK MODE
      darkTheme: AppTheme.darkTheme,

      /// THEME MODE
      themeMode: themeProvider.themeMode,

      home: const SplashScreen(),
    );
  }
}