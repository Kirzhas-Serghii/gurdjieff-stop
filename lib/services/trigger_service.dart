import 'dart:math';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TriggerService {
  static const String taskName = 'gurdjieff_stop_trigger';
  static const String uniqueTaskName = 'stop_reminder';

  static Future<void> scheduleNextTrigger() async {
    final prefs = await SharedPreferences.getInstance();
    final isActive = prefs.getBool('isActive') ?? false;

    if (!isActive) return;

    final minMinutes = prefs.getInt('minInterval') ?? 15;
    final maxMinutes = prefs.getInt('maxInterval') ?? 45;
    final useActiveHours = prefs.getBool('useActiveHours') ?? true;
    final activeStart = prefs.getInt('activeHourStart') ?? 7;
    final activeEnd = prefs.getInt('activeHourEnd') ?? 23;

    // Перевірка активних годин
    if (useActiveHours) {
      final now = DateTime.now();
      final hour = now.hour;
      if (hour < activeStart || hour >= activeEnd) {
        // Поза активними годинами — плануємо на початок наступного активного вікна
        final tomorrow = DateTime(now.year, now.month, now.day + 1, activeStart);
        final today = DateTime(now.year, now.month, now.day, activeStart);
        final nextActive = now.hour < activeStart ? today : tomorrow;
        final delayMinutes = nextActive.difference(now).inMinutes + minMinutes;

        await Workmanager().registerOneOffTask(
          uniqueTaskName,
          taskName,
          initialDelay: Duration(minutes: delayMinutes),
          constraints: Constraints(networkType: NetworkType.not_required),
          existingWorkPolicy: ExistingWorkPolicy.replace,
        );
        return;
      }
    }

    // Випадковий інтервал
    final random = Random();
    final delayMinutes = minMinutes + random.nextInt(maxMinutes - minMinutes + 1);

    await Workmanager().registerOneOffTask(
      uniqueTaskName,
      taskName,
      initialDelay: Duration(minutes: delayMinutes),
      constraints: Constraints(networkType: NetworkType.not_required),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  static Future<void> cancelAll() async {
    await Workmanager().cancelByUniqueName(uniqueTaskName);
  }

  static Future<void> start() async {
    await cancelAll();
    await scheduleNextTrigger();
  }

  static Future<void> stop() async {
    await cancelAll();
  }
}
