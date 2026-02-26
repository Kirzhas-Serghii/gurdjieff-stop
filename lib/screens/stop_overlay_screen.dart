import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import '../models/stats_service.dart';
import '../models/app_settings.dart';

class StopOverlayScreen extends StatefulWidget {
  const StopOverlayScreen({super.key});

  @override
  State<StopOverlayScreen> createState() => _StopOverlayScreenState();
}

class _StopOverlayScreenState extends State<StopOverlayScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  AppSettings _settings = AppSettings();
  String _quote = '';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _load();
  }

  Future<void> _load() async {
    final settings = await AppSettings.load();
    setState(() {
      _settings = settings;
      _quote = settings.customQuote.isNotEmpty
          ? settings.customQuote
          : 'Зупини все. Відчуй своє тіло. Згадай себе.';
    });

    // Вібрація при появі
    if (settings.notificationMode == 'vibration' ||
        settings.notificationMode == 'both') {
      final hasVibrator = await Vibration.hasVibrator() ?? false;
      if (hasVibrator) {
        Vibration.vibrate(pattern: [0, 500, 200, 500, 200, 500]);
      }
    }
  }

  Future<void> _onRemembered() async {
    await StatsService.recordSession();

    // Підтверджуюча вібрація
    final hasVibrator = await Vibration.hasVibrator() ?? false;
    if (hasVibrator) {
      Vibration.vibrate(pattern: [0, 100, 50, 100]);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _onSnooze() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Відкладено на 5 хвилин'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
    // TODO: schedule 5 min reminder
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // Анімований символ СТОП
              ScaleTransition(
                scale: _pulseAnimation,
                child: const Text(
                  'С Т О П',
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.w100,
                    color: Colors.white,
                    letterSpacing: 12,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Роздільна лінія
              Container(
                height: 1,
                width: 80,
                color: Colors.grey.shade800,
              ),

              const SizedBox(height: 40),

              // Цитата / Інструкція
              Text(
                _quote,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  height: 1.6,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                '— Гурджієв',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),

              const Spacer(),

              // Кнопка "Я згадав"
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _onRemembered,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text(
                    'Я ЗГАДАВ',
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Кнопка відкладення
              TextButton(
                onPressed: _onSnooze,
                child: const Text(
                  'Відкласти на 5 хв',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
