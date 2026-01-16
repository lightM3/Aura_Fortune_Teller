import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Bildirimleri başlat
  Future<void> initialize() async {
    // Local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _localNotifications.initialize(initializationSettings);

    // Firebase notifications
    await _firebaseMessaging.requestPermission();

    // FCM token al
    final fcmToken = await _firebaseMessaging.getToken();
    print('FCM Token: $fcmToken');

    // Bildirim dinleyicileri
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
  }

  // Ön planda bildirim
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      _showLocalNotification(
        title: notification.title ?? 'Fal Uygulaması',
        body: notification.body ?? 'Yeni bildiriminiz var',
        payload: message.data.toString(),
      );
    }
  }

  // Arka planda bildirim
  void _handleBackgroundMessage(RemoteMessage message) {
    print('Background message opened: ${message.messageId}');
  }

  // Local bildirim göster
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'fal_notifications',
          'Fal Bildirimleri',
          channelDescription: 'Fal uygulaması bildirimleri',
          importance: Importance.max,
          priority: Priority.high,
          color: Color(0xFFffd700),
          ledColor: Color(0xFFffd700),
          ledOnMs: 1000,
          ledOffMs: 500,
          icon: '@mipmap/ic_launcher',
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // Fal hazır bildirimi
  Future<void> notifyFortuneReady(String userId, String fortuneId) async {
    await _localNotifications.show(
      1,
      'Falınız Hazır! 🎉',
      'Falcınız falınızı yorumladı, hemen görüntüleyin!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'fal_notifications',
          'Fal Bildirimleri',
          channelDescription: 'Fal uygulaması bildirimleri',
          importance: Importance.max,
          priority: Priority.high,
          color: Color(0xFFffd700),
        ),
      ),
    );

    // Firestore'a bildirim kaydı
    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': userId,
      'type': 'fortune_ready',
      'title': 'Falınız Hazır!',
      'body': 'Falcınız falınızı yorumladı',
      'fortuneId': fortuneId,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  // Kredi bitti bildirimi
  Future<void> notifyCreditsLow(String userId) async {
    await _localNotifications.show(
      2,
      'Krediniz Tükendi! ⚠️',
      'Yeni fal bakmak için kredi yükleyin',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'fal_notifications',
          'Fal Bildirimleri',
          channelDescription: 'Fal uygulaması bildirimleri',
          importance: Importance.high,
          priority: Priority.high,
          color: Color(0xFFff6b6b),
        ),
      ),
    );

    // Firestore'a bildirim kaydı
    await FirebaseFirestore.instance.collection('notifications').add({
      'userId': userId,
      'type': 'credits_low',
      'title': 'Krediniz Tükendi!',
      'body': 'Yeni fal bakmak için kredi yükleyin',
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  // Promosyon bildirimi
  Future<void> notifyPromotion(String title, String body) async {
    await _localNotifications.show(
      3,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'fal_notifications',
          'Fal Bildirimleri',
          channelDescription: 'Fal uygulaması bildirimleri',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          color: Color(0xFF4ecdc4),
        ),
      ),
    );
  }

  // Toplu bildirim gönder (admin için)
  Future<void> sendBulkNotification({
    required String title,
    required String body,
    List<String>? userIds,
  }) async {
    if (userIds == null) {
      // Tüm kullanıcılara gönder
      final users = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'user')
          .get();

      for (var user in users.docs) {
        await _localNotifications.show(
          4,
          title,
          body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'fal_notifications',
              'Fal Bildirimleri',
              channelDescription: 'Fal uygulaması bildirimleri',
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
            ),
          ),
        );
      }
    } else {
      // Belirli kullanıcılara gönder
      for (String userId in userIds) {
        await _localNotifications.show(
          4,
          title,
          body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'fal_notifications',
              'Fal Bildirimleri',
              channelDescription: 'Fal uygulaması bildirimleri',
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
            ),
          ),
        );
      }
    }
  }

  // Bildirimleri temizle
  Future<void> clearNotifications() async {
    await _localNotifications.cancelAll();
  }

  // Bekleyen bildirimleri kontrol et
  Future<List<Map<String, dynamic>>> getUnreadNotifications(
    String userId,
  ) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  // Bildirimi okundu olarak işaretle
  Future<void> markAsRead(String notificationId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }
}
