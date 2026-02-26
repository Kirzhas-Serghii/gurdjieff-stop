import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/stop_overlay_screen.dart';
import 'services/notification_service.dart';
import 'services/trigger_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Глобальний навігаційний ключ для відкриття екрану з фону
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == TriggerService.taskName) {
      await NotificationService.showStopNotification();
      await TriggerService.scheduleNextTrigger();
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await NotificationService.initialize(
    flutterLocalNotificationsPlugin,
    onNotificationTap: _onNotificationTap,
  );
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

  runApp(const GurdjieffStopApp());
}

void _onNotificationTap(NotificationResponse response) {
  navigatorKey.currentState?.push(
    MaterialPageRoute(builder: (_) => const StopOverlayScreen()),
  );
}

class GurdjieffStopApp extends StatelessWidget {
  const GurdjieffStopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gurdjieff Stop',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.dark,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/statistics': (context) => const StatisticsScreen(),
      },
    );
  }
}
