import 'package:shared_preferences/shared_preferences.dart';

class StatsService {
  static Future<void> recordSession() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayKey = 'stats_${now.year}_${now.month}_${now.day}';
    final total = prefs.getInt('stats_total') ?? 0;
    final todayCount = prefs.getInt(todayKey) ?? 0;

    await prefs.setInt('stats_total', total + 1);
    await prefs.setInt(todayKey, todayCount + 1);

    // Зберігаємо список дат для тижневої статистики
    final sessions = prefs.getStringList('session_dates') ?? [];
    sessions.add(now.toIso8601String());
    // Залишаємо тільки останні 1000 сесій
    if (sessions.length > 1000) {
      sessions.removeRange(0, sessions.length - 1000);
    }
    await prefs.setStringList('session_dates', sessions);
  }

  static Future<int> getTodayCount() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayKey = 'stats_${now.year}_${now.month}_${now.day}';
    return prefs.getInt(todayKey) ?? 0;
  }

  static Future<int> getWeekCount() async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = prefs.getStringList('session_dates') ?? [];
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    int count = 0;
    for (final s in sessions) {
      final date = DateTime.tryParse(s);
      if (date != null && date.isAfter(weekAgo)) count++;
    }
    return count;
  }

  static Future<int> getTotalCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('stats_total') ?? 0;
  }

  static Future<Map<String, int>> getDailyStats() async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = prefs.getStringList('session_dates') ?? [];
    final Map<String, int> daily = {};
    for (final s in sessions) {
      final date = DateTime.tryParse(s);
      if (date != null) {
        final key = '${date.day}.${date.month}';
        daily[key] = (daily[key] ?? 0) + 1;
      }
    }
    return daily;
  }
}
