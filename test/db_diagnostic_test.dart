import 'package:supabase/supabase.dart';

void main() async {
  print('--- Starting Pure Dart Database Diagnostic ---');

  // 1. Instantiate pure Dart SupabaseClient (no Flutter dependencies, no SharedPreferences)
  final supabase = SupabaseClient(
    'https://htjkrrsmdusxwfdvcxgt.supabase.co',
    'sb_publishable_IBnKnq1-hnt_cssP517eAw_0_fnwMCw',
  );

  final email = 'diagnostic_${DateTime.now().millisecondsSinceEpoch}@example.com';
  final password = 'Password123!';
  
  try {
    // 2. Register/Login a temporary user to get an authenticated session
    print('Registering diagnostic user: $email');
    final authResponse = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    final userId = authResponse.user?.id;
    if (userId == null) {
      print('ERROR: Failed to register diagnostic user');
      return;
    }
    print('Successfully registered user: $userId');

    // Create user profile (in case of foreign key constraints or role checks)
    try {
      await supabase.from('user_profiles').insert({
        'id': userId,
        'name': 'Diagnostic User',
        'email': email,
        'role': 'user',
        'is_active': true,
      });
      print('Created user profile successfully');
    } catch (e) {
      print('Profile creation error (might be handled by db trigger or already exists): $e');
    }

    // 3. Insert a ticket
    final ticketTitle = 'Diagnostic Ticket ${DateTime.now().millisecondsSinceEpoch}';
    print('Inserting ticket: "$ticketTitle"');
    
    final ticketResponse = await supabase.from('tickets').insert({
      'title': ticketTitle,
      'description': 'Checking for automatic database triggers.',
      'category': 'Network',
      'priority': 'Low',
      'status': 'Open',
      'user_id': userId,
    }).select().single();

    final String ticketId = ticketResponse['id'].toString();
    print('Ticket created successfully with ID: $ticketId');

    // 4. Query the ticket_history table immediately to see if a trigger automatically created a record
    print('Querying ticket_history for ticket ID: $ticketId...');
    final historyResponse = await supabase
        .from('ticket_history')
        .select()
        .eq('ticket_id', ticketId);

    print('History records found in database:');
    print(historyResponse);

    final historyList = historyResponse as List;
    if (historyList.isNotEmpty) {
      print('DIAGNOSIS SUCCESS: A database trigger automatically created ${historyList.length} history records!');
      for (var item in historyList) {
        print(' - Action: ${item['action']}, New Value: ${item['new_value']}, Changed By: ${item['changed_by']}');
      }
    } else {
      print('DIAGNOSIS: No history records were automatically created. No trigger is active.');
    }

    // 5. Test if manual client-side insert is allowed for 'user' role
    print('Testing manual client-side insert into ticket_history...');
    try {
      await supabase.from('ticket_history').insert({
        'ticket_id': ticketId,
        'action': 'CREATED',
        'new_value': 'Open',
        'changed_by': userId,
      });
      print('Manual client-side insert SUCCEEDED!');
    } catch (e) {
      print('Manual client-side insert FAILED (this is expected if RLS prevents it): $e');
    }

    // Cleanup
    try {
      await supabase.from('tickets').delete().eq('id', ticketId);
      print('Cleaned up diagnostic ticket');
    } catch (e) {
      print('Cleanup error: $e');
    }

  } catch (e, st) {
    print('Unexpected error during diagnostic: $e');
    print(st);
  } finally {
    print('--- Diagnostic Completed ---');
  }
}
