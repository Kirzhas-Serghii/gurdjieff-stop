import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static FlutterLocalNotificationsPlugin? _plugin;
  static const int stopNotificationId = 1;

  static Future<void> initialize(FlutterLocalNotificationsPlugin plugin) async {
    _plugin = plugin;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  static void _onNotificationTap(NotificationResponse response) {
    // Обробка натискання на сповіщення
  }

  static Future<void> requestPermissions() async {
    _plugin ??= FlutterLocalNotificationsPlugin();

    await _plugin!
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _plugin!
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  static Future<void> showStopNotification() async {
    _plugin ??= FlutterLocalNotificationsPlugin();

    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString('notificationMode') ?? 'both';
    final customQuote = prefs.getString('customQuote') ?? '';

    final body = customQuote.isNotEmpty
        ? customQuote
        : 'Зупини все. Відчуй своє тіло. Згадай себе.';

    AndroidNotificationDetails androidDetails;

    if (mode == 'vibration') {
      androidDetails = const AndroidNotificationDetails(
        'stop_channel',
        'СТОП сповіщення',
        channelDescription: 'Нагадування для практики Гурджієва',
        importance: Importance.max,
        priority: Priority.max,
        playSound: false,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 500, 200, 500, 200, 500]),
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
      );
    } else if (mode == 'sound') {
      androidDetails = const AndroidNotificationDetails(
        'stop_channel_sound',
        'СТОП сповіщення (звук)',
        channelDescription: 'Нагадування для практики Гурджієва',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: false,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
      );
    } else {
      androidDetails = const AndroidNotificationDetails(
        'stop_channel_both',
        'СТОП сповіщення (вібрація + звук)',
        channelDescription: 'Нагадування для практики Гурджієва',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
      );
    }

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin!.show(
      stopNotificationId,
      '🔴 СТОП!',
      body,
      details,
    );
  }

  static Future<void> cancelAll() async {
    _plugin ??= FlutterLocalNotificationsPlugin();
    await _plugin!.cancelAll();
  }
}
