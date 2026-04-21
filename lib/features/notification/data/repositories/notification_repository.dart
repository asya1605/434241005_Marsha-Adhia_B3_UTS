import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    return await _supabase
        .from('user_profiles')
        .select()
        .eq('id', userId)
        .single();
  }

  Stream<List<NotificationModel>> getNotifications(String userId, String role) {
    
    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) {

          List filtered = [];

          if (role == 'admin') {
            // admin lihat semua
            filtered = data;
          } else if (role == 'helpdesk') {
            // helpdesk hanya notif assigned ke dia
            filtered = data.where((e) => 
               e['user_id'] == userId && e['title'] == 'Ticket Assigned'
            ).toList();
          } else {
            // user biasa tidak lihat assigned notif
            filtered = data.where((e) => 
               e['user_id'] == userId && e['title'] != 'Ticket Assigned'
            ).toList();
          }


          return filtered
              .map((map) => NotificationModel.fromMap(map))
              .toList();
        })
        .handleError((error) {
          debugPrint("REALTIME ERROR: $error");
        });
  }

}
