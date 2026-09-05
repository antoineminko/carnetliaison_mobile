import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationStorage {
  static const String _storageKey = 'local_notifications';

  static Future<void> saveNotification(Map<String, dynamic> notification) async {
    final prefs = await SharedPreferences.getInstance();
    
   
    List<Map<String, dynamic>> notifications = await getNotifications();
    
  
    notification['timestamp'] = DateTime.now().toIso8601String();
    notification['isRead'] = false;
    
    notifications.insert(0, notification);
    
    
    await prefs.setString(_storageKey, jsonEncode(notifications));
  }

  static Future<List<Map<String, dynamic>>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey);
    
    if (data == null) return [];
    
    try {
      List<dynamic> decoded = jsonDecode(data);
      List<Map<String, dynamic>> notifications = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      

      final now = DateTime.now();
      notifications.removeWhere((n) {
        if (n['timestamp'] == null) return true;
        try {
          final notifTime = DateTime.parse(n['timestamp']);
          return now.difference(notifTime).inHours >= 24;
        } catch (e) {
          return true; 
        }
      });
      
     
      await prefs.setString(_storageKey, jsonEncode(notifications));
      
      return notifications;
    } catch (e) {
      return [];
    }
  }

  static Future<void> markAllAsRead() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> notifications = await getNotifications();
    
    for (var n in notifications) {
      n['isRead'] = true;
    }
    
    await prefs.setString(_storageKey, jsonEncode(notifications));
  }

  static Future<void> removeNotification(int index) async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> notifications = await getNotifications();
    
    if (index >= 0 && index < notifications.length) {
      notifications.removeAt(index);
      await prefs.setString(_storageKey, jsonEncode(notifications));
    }
  }

  static Future<int> getUnreadCount() async {
    List<Map<String, dynamic>> notifications = await getNotifications();
    return notifications.where((n) => n['isRead'] != true).length;
  }
}
