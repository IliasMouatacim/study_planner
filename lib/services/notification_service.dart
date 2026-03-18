// lib/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../utils/constants.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  Future<void> init() async {
    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    // FIXED: Removed 'initializationSettings' parameter name and 'settings' parameter
    // CORRECT for version 20.0.0
await _notifications.initialize(
  settings: initSettings,  // ← Named parameter 'settings'
  onDidReceiveNotificationResponse: _onNotificationTapped,
);
    
    // Request permissions for iOS
    await _requestPermissions();
  }
  
  Future<void> _requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }
    
    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    
    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }
  
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    // You can navigate to specific screens here if needed
  }
  
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'pomodoro_channel',
      'Pomodoro Timer',
      channelDescription: 'Notifications for Pomodoro timer',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    // FIXED: Removed parameter names 'id', 'title', 'body', 'notificationDetails'
    // CORRECT for version 20.0.0
await _notifications.show(
  id: AppConstants.pomodoroNotificationId,  // ← Named parameter 'id'
  title: title,                               // ← Named parameter 'title'
  body: body,                                 // ← Named parameter 'body'
  notificationDetails: details,               // ← Named parameter 'notificationDetails'
  payload: payload,
);
  }
  
  Future<void> showWorkSessionComplete() async {
    await showNotification(
      title: 'Session Terminée! 🎉',
      body: 'Temps de faire une pause!',
    );
  }
  
  Future<void> showBreakComplete() async {
    await showNotification(
      title: 'Pause Terminée! ⚡',
      body: 'Prêt à reprendre le travail?',
    );
  }
  
  Future<void> showLongBreakComplete() async {
    await showNotification(
      title: 'Longue Pause Terminée! 🌟',
      body: 'Vous avez bien récupéré! Retour au travail?',
    );
  }
  
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
  
  Future<void> cancel(int id) async {
    // CORRECT for version 20.0.0
await _notifications.cancel(id: id);  // ← Named parameter 'id'
  }
}