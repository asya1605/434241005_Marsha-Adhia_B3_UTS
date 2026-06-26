import 'dart:convert';
import 'dart:io';

const String supabaseUrl = 'https://htjkrrsmdusxwfdvcxgt.supabase.co';
const String anonKey = 'sb_publishable_IBnKnq1-hnt_cssP517eAw_0_fnwMCw';

Future<void> main() async {
  print('--- Starting Pure HTTP Database Diagnostic ---');
  final client = HttpClient();

  final email = 'diagnostic_http_${DateTime.now().millisecondsSinceEpoch}@example.com';
  final password = 'Password123!';

  try {
    // 1. Sign Up a new user using Supabase Auth REST API
    print('Signing up user: $email');
    final authRequest = await client.postUrl(Uri.parse('$supabaseUrl/auth/v1/signup'));
    authRequest.headers.set('apikey', anonKey);
    authRequest.headers.set('content-type', 'application/json');
    authRequest.write(jsonEncode({
      'email': email,
      'password': password,
    }));
    
    final authResponse = await authRequest.close();
    final authBody = await authResponse.transform(utf8.decoder).join();
    
    if (authResponse.statusCode != 200 && authResponse.statusCode != 201) {
      print('Auth Error (Status ${authResponse.statusCode}): $authBody');
      return;
    }

    final authJson = jsonDecode(authBody) as Map<String, dynamic>;
    final String? accessToken = authJson['access_token']?.toString();
    final Map<String, dynamic>? userMap = authJson['user'] as Map<String, dynamic>?;
    final String? userId = userMap?['id']?.toString();

    if (accessToken == null || userId == null) {
      print('ERROR: Failed to obtain session or user ID from Auth response');
      return;
    }

    print('Successfully authenticated. User ID: $userId');

    // 2. Create User Profile
    print('Creating user profile...');
    final profileRequest = await client.postUrl(Uri.parse('$supabaseUrl/rest/v1/user_profiles'));
    profileRequest.headers.set('apikey', anonKey);
    profileRequest.headers.set('Authorization', 'Bearer $accessToken');
    profileRequest.headers.set('content-type', 'application/json');
    profileRequest.headers.set('Prefer', 'resolution=merge-duplicates');
    profileRequest.write(jsonEncode({
      'id': userId,
      'name': 'Diagnostic HTTP User',
      'email': email,
      'role': 'user',
      'is_active': true,
    }));
    
    final profileResponse = await profileRequest.close();
    final profileBody = await profileResponse.transform(utf8.decoder).join();
    print('Profile response status: ${profileResponse.statusCode}');

    // 3. Create a Ticket via REST API
    final ticketTitle = 'Diagnostic HTTP Ticket ${DateTime.now().millisecondsSinceEpoch}';
    print('Inserting ticket: "$ticketTitle"');
    
    final ticketRequest = await client.postUrl(Uri.parse('$supabaseUrl/rest/v1/tickets'));
    ticketRequest.headers.set('apikey', anonKey);
    ticketRequest.headers.set('Authorization', 'Bearer $accessToken');
    ticketRequest.headers.set('content-type', 'application/json');
    ticketRequest.headers.set('Prefer', 'return=representation');
    ticketRequest.write(jsonEncode({
      'title': ticketTitle,
      'description': 'Empirical test for database trigger.',
      'category': 'Network',
      'priority': 'Low',
      'status': 'Open',
      'user_id': userId,
    }));

    final ticketResponse = await ticketRequest.close();
    final ticketBody = await ticketResponse.transform(utf8.decoder).join();
    
    if (ticketResponse.statusCode != 201) {
      print('Ticket Insertion Error (Status ${ticketResponse.statusCode}): $ticketBody');
      return;
    }

    final ticketJsonList = jsonDecode(ticketBody) as List;
    if (ticketJsonList.isEmpty) {
      print('ERROR: Ticket response body is empty');
      return;
    }

    final ticketMap = ticketJsonList.first as Map<String, dynamic>;
    final String ticketId = ticketMap['id'].toString();
    print('Ticket created successfully with ID: $ticketId');

    // 4. Query the ticket_history table immediately
    print('Querying ticket_history for ticket ID: $ticketId...');
    final historyRequest = await client.getUrl(Uri.parse('$supabaseUrl/rest/v1/ticket_history?ticket_id=eq.$ticketId'));
    historyRequest.headers.set('apikey', anonKey);
    historyRequest.headers.set('Authorization', 'Bearer $accessToken');
    
    final historyResponse = await historyRequest.close();
    final historyBody = await historyResponse.transform(utf8.decoder).join();
    print('History response status: ${historyResponse.statusCode}');
    print('History body: $historyBody');

    final historyList = jsonDecode(historyBody) as List;
    
    print('\n==================================================');
    if (historyList.isNotEmpty) {
      print('RESULT: YES! THE DATABASE HAS AN AUTOMATIC TRIGGER!');
      print('A ticket history record was automatically created by the database trigger.');
      for (var item in historyList) {
        print(' - Action: ${item['action']}');
        print(' - Old Value: ${item['old_value']}');
        print(' - New Value: ${item['new_value']}');
        print(' - Changed By: ${item['changed_by']}');
        print(' - Created At: ${item['created_at']}');
      }
    } else {
      print('RESULT: NO TRIGGER DETECTED.');
      print('No history record was created automatically in the database.');
    }
    print('==================================================\n');

    // 5. Test if manual client-side insert is allowed for 'user' role
    print('Testing manual client-side insert into ticket_history...');
    final manualRequest = await client.postUrl(Uri.parse('$supabaseUrl/rest/v1/ticket_history'));
    manualRequest.headers.set('apikey', anonKey);
    manualRequest.headers.set('Authorization', 'Bearer $accessToken');
    manualRequest.headers.set('content-type', 'application/json');
    manualRequest.write(jsonEncode({
      'ticket_id': ticketId,
      'action': 'CREATED',
      'new_value': 'Open',
      'changed_by': userId,
    }));

    final manualResponse = await manualRequest.close();
    final manualBody = await manualResponse.transform(utf8.decoder).join();
    
    if (manualResponse.statusCode == 201 || manualResponse.statusCode == 200) {
      print('Manual insert SUCCEEDED! (Status ${manualResponse.statusCode})');
    } else {
      print('Manual insert FAILED (this confirms RLS blocks normal users from direct writes):');
      print('Status: ${manualResponse.statusCode}');
      print('Body: $manualBody');
    }

    // Cleanup
    print('Cleaning up diagnostic ticket...');
    final deleteRequest = await client.deleteUrl(Uri.parse('$supabaseUrl/rest/v1/tickets?id=eq.$ticketId'));
    deleteRequest.headers.set('apikey', anonKey);
    deleteRequest.headers.set('Authorization', 'Bearer $accessToken');
    final deleteResponse = await deleteRequest.close();
    print('Cleanup status: ${deleteResponse.statusCode}');

  } catch (e, st) {
    print('Exception during HTTP diagnostic: $e');
    print(st);
  } finally {
    client.close();
    print('--- Pure HTTP Diagnostic Completed ---');
  }
}
