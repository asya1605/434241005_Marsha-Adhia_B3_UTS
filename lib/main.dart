import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'splash/splash_screen.dart';
import 'core/theme/theme_provider.dart';

import 'features/ticket/presentation/providers/ticket_provider.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/dashboard/presentation/providers/dashboard_provider.dart';
import 'features/notification/presentation/providers/notification_provider.dart';
import 'features/ticket/presentation/providers/comment_provider.dart';

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

  /// LOGOUT USER 
  await Supabase.instance.client.auth.signOut();

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

      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Helpdesk Ticket',
      debugShowCheckedModeBanner: false,

      /// LIGHT MODE
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFFE91E8C),
        scaffoldBackgroundColor: Colors.white,
      ),

      /// DARK MODE
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFE91E8C),
      ),

      /// THEME MODE
      themeMode: themeProvider.themeMode,

      home: const SplashScreen(),
    );
  }
}