import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../models/stats_service.dart';
import '../services/trigger_service.dart';
import '../services/notification_service.dart';
import 'stop_overlay_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppSettings _settings = AppSettings();
  int _todayCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await AppSettings.load();
    final today = await StatsService.getTodayCount();
    setState(() {
      _settings = settings;
      _todayCount = today;
      _loading = false;
    });
  }

  Future<void> _toggleActive(bool value) async {
    setState(() => _settings.isActive = value);
    await _settings.save();

    if (value) {
      await NotificationService.requestPermissions();
      await TriggerService.start();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Активовано! Перший сигнал через ${_settings.minIntervalMinutes}–${_settings.maxIntervalMinutes} хв',
            ),
            backgroundColor: Colors.green.shade900,
          ),
        );
      }
    } else {
      await TriggerService.stop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Зупинено'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Gurdjieff Stop',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w300,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.white),
            onPressed: () =>
                Navigator.pushNamed(context, '/statistics').then((_) => _load()),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () =>
                Navigator.pushNamed(context, '/settings').then((_) => _load()),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Головний символ
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _settings.isActive ? Colors.white : Colors.grey.shade800,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    'СТОП',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w100,
                      letterSpacing: 4,
                      color: _settings.isActive ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Перемикач активності
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _settings.isActive ? 'АКТИВНО' : 'НЕАКТИВНО',
                    style: TextStyle(
                      fontSize: 14,
                      letterSpacing: 3,
                      color: _settings.isActive ? Colors.white : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Switch(
                    value: _settings.isActive,
                    onChanged: _toggleActive,
                    activeColor: Colors.white,
                    activeTrackColor: Colors.grey.shade700,
                    inactiveThumbColor: Colors.grey.shade600,
                    inactiveTrackColor: Colors.grey.shade900,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Інформація про інтервал
              if (_settings.isActive)
                Text(
                  'Сигнал кожні ${_settings.minIntervalMinutes}–${_settings.maxIntervalMinutes} хв',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),

              const Spacer(),

              // Статистика сьогодні
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade900),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          '$_todayCount',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w100,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'сьогодні',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Кнопка тест
              TextButton(
                onPressed: () async {
                  await StatsService.recordSession();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StopOverlayScreen(),
                    ),
                  ).then((_) => _load());
                },
                child: const Text(
                  'Тест сигналу',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    letterSpacing: 2,
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
