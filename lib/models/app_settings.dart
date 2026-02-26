import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  bool isActive;
  int minIntervalMinutes;
  int maxIntervalMinutes;
  int activeHourStart; // година початку (наприклад 7)
  int activeHourEnd;   // година кінця (наприклад 23)
  bool useActiveHours;
  String notificationMode; // 'vibration', 'sound', 'both'
  String selectedSound;
  double volume;
  bool fadeIn;
  String customQuote;

  AppSettings({
    this.isActive = false,
    this.minIntervalMinutes = 15,
    this.maxIntervalMinutes = 45,
    this.activeHourStart = 7,
    this.activeHourEnd = 23,
    this.useActiveHours = true,
    this.notificationMode = 'both',
    this.selectedSound = 'bell',
    this.volume = 0.7,
    this.fadeIn = false,
    this.customQuote = '',
  });

  static Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      isActive: prefs.getBool('isActive') ?? false,
      minIntervalMinutes: prefs.getInt('minInterval') ?? 15,
      maxIntervalMinutes: prefs.getInt('maxInterval') ?? 45,
      activeHourStart: prefs.getInt('activeHourStart') ?? 7,
      activeHourEnd: prefs.getInt('activeHourEnd') ?? 23,
      useActiveHours: prefs.getBool('useActiveHours') ?? true,
      notificationMode: prefs.getString('notificationMode') ?? 'both',
      selectedSound: prefs.getString('selectedSound') ?? 'bell',
      volume: prefs.getDouble('volume') ?? 0.7,
      fadeIn: prefs.getBool('fadeIn') ?? false,
      customQuote: prefs.getString('customQuote') ?? '',
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isActive', isActive);
    await prefs.setInt('minInterval', minIntervalMinutes);
    await prefs.setInt('maxInterval', maxIntervalMinutes);
    await prefs.setInt('activeHourStart', activeHourStart);
    await prefs.setInt('activeHourEnd', activeHourEnd);
    await prefs.setBool('useActiveHours', useActiveHours);
    await prefs.setString('notificationMode', notificationMode);
    await prefs.setString('selectedSound', selectedSound);
    await prefs.setDouble('volume', volume);
    await prefs.setBool('fadeIn', fadeIn);
    await prefs.setString('customQuote', customQuote);
  }
}
