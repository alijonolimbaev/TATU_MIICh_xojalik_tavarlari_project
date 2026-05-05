import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'xojalik_channel',
    "Xo'jalik Tavarlari",
    description: "Xo'jalik Tavarlari ilovasi bildirisnnomalari",
    importance: Importance.high,
    playSound: true,
  );

  Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  Future<void> requestPermission() async {
    await Permission.notification.request();
  }

  Future<void> showWelcomeNotification() async {
    await _plugin.show(
      0,
      "🏪 Xo'jalik Tavarlari",
      'Ilovaga xush kelibsiz! Qulay xarid qiling.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id, _channel.name,
          importance: Importance.high,
          priority: Priority.high,
          color: Color(0xFF2E7D32),
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  Future<void> showCartNotification(String productName) async {
    await _plugin.show(
      1,
      "🛒 Savatga qo'shildi!",
      "$productName savatga muvaffaqiyatli qo'shildi.",
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id, _channel.name,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  Future<void> showFavoriteNotification(String productName) async {
    await _plugin.show(
      2,
      "❤️ Sevimlilarga qo'shildi!",
      "$productName sevimlilar ro'yxatiga qo'shildi.",
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id, _channel.name,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  Future<void> showOrderNotification(int itemCount, String total) async {
    await _plugin.show(
      3,
      '✅ Buyurtma qabul qilindi!',
      "$itemCount ta mahsulot, jami: $total so'm.",
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id, _channel.name,
          importance: Importance.high,
          priority: Priority.high,
          color: Color(0xFF2E7D32),
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(
            "$itemCount ta mahsulot buyurtma qilindi. Jami: $total so'm. Kuryer tez orada siz bilan bog'lanadi.",
          ),
        ),
      ),
    );
  }
}