import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:helpdesk_ticket/features/ticket/presentation/providers/ticket_history_provider.dart';

void main() async {
  print('--- Testing TicketHistoryProvider with Real Authentication ---');

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://htjkrrsmdusxwfdvcxgt.supabase.co',
    anonKey: 'sb_publishable_IBnKnq1-hnt_cssP517eAw_0_fnwMCw',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  final client = Supabase.instance.client;

  // Log in
  print('Logging in user@mail.com...');
  final authRes = await client.auth.signInWithPassword(
    email: 'user@mail.com',
    password: '123456',
  );
  print('Logged in successfully! User ID: ${authRes.user?.id}');

  // Test TicketHistoryProvider
  final provider = TicketHistoryProvider();
  
  print('\nCalling provider.loadHistory() for ticket d5c676ca-f808-4bb9-a87c-a4eb783c372e...');
  try {
    await provider.loadHistory('d5c676ca-f808-4bb9-a87c-a4eb783c372e');
    print('loadHistory completed. Provider history length: ${provider.history.length}');
    for (var h in provider.history) {
      print(' - History Item -> ID: ${h.id}, Action: ${h.action}, New: ${h.newValue}');
    }
  } catch (e, st) {
    print('Exception caught during loadHistory: $e');
    print(st);
  }

  print('\n--- Test Completed ---');
}
