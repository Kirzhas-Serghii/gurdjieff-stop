import 'dart:math';
import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../models/stats_service.dart';
import '../services/trigger_service.dart';
import '../services/notification_service.dart';

const List<Map<String, String>> kQuotes = [
  {'text': 'Людина не може нічого зробити, але вона може стати іншою.', 'author': 'Гурджієв'},
  {'text': 'Усвідом себе. Де ти? Що ти робиш? Що ти думаєш?', 'author': 'Гурджієв'},
  {'text': 'Без самоспостереження немає самопізнання.', 'author': 'Гурджієв'},
  {'text': 'Людина спить. Вона повинна прокинутись.', 'author': 'Гурджієв'},
  {'text': 'Тіло — це інструмент. Навчися ним користуватись усвідомлено.', 'author': 'Гурджієв'},
  {'text': 'Справжнє зусилля — це зусилля проти себе.', 'author': 'Гурджієв'},
  {'text': 'Знай себе — і ти пізнаєш Всесвіт і Богів.', 'author': 'Піфагор'},
  {'text': 'Я знаю, що нічого не знаю.', 'author': 'Сократ'},
  {'text': 'Будь тут і зараз. Це єдине місце, де ти існуєш.', 'author': 'Рам Дасс'},
  {'text': 'Дивись на своє дихання. Воно завжди з тобою.', 'author': 'Будда'},
  {'text': 'Той, хто дивиться назовні — спить. Той, хто дивиться всередину — прокидається.', 'author': 'Юнг'},
  {'text': 'Не думай про минуле і майбутнє. Будь присутнім.', 'author': 'Екхарт Толле'},
  {'text': 'Увага — це найрідкісніша і найчистіша форма щедрості.', 'author': 'Сімона Вейль'},
  {'text': 'Весь людський нещасний лише тому, що не вміє спокійно сидіти у своїй кімнаті.', 'author': 'Паскаль'},
  {'text': 'Мудрість починається з подиву.', 'author': 'Сократ'},
  {'text': 'Стоп. Відчуй своє тіло. Ти живий прямо зараз.', 'author': 'Практика'},
  {'text': 'Де твоя увага — там твоє життя.', 'author': 'Гурджієв'},
  {'text': 'Не дозволяй розуму блукати. Повернись.', 'author': 'Марк Аврелій'},
  {'text': 'Кожна мить — це двері. Увійди усвідомлено.', 'author': 'Дзен'},
  {'text': 'Зупинись. Подихай. Ти вдома.', 'author': 'Тіч Нят Хань'},
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  AppSettings _settings = AppSettings();
  int _todayCount = 0;
  bool _loading = true;
  Map<String, String>? _currentQuote;
  bool _showQuote = false;
  late AnimationController _quoteAnimController;
  late Animation<double> _quoteAnim;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _quoteAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _quoteAnim = CurvedAnimation(
      parent: _quoteAnimController,
      curve: Curves.easeOut,
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _load();
  }

  @override
  void dispose() {
    _quoteAnimController.dispose();
    _pulseController.dispose();
    super.dispose();
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

  Future<void> _onStopTap() async {
    // Анімація натискання
    await _pulseController.forward();
    await _pulseController.reverse();

    // Випадкова цитата
    final random = Random();
    final quote = kQuotes[random.nextInt(kQuotes.length)];

    // Зарахувати сесію
    await StatsService.recordSession();
    final today = await StatsService.getTodayCount();

    setState(() {
      _currentQuote = quote;
      _showQuote = true;
      _todayCount = today;
    });
    _quoteAnimController.forward(from: 0);
  }

  void _dismissQuote() {
    _quoteAnimController.reverse().then((_) {
      setState(() => _showQuote = false);
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
              const SizedBox(height: 32),

              // Головна кнопка — знак СТОП
              ScaleTransition(
                scale: _pulseAnim,
                child: GestureDetector(
                  onTap: _onStopTap,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/images/stop_sign.png',
                        width: 180,
                        height: 180,
                        color: _settings.isActive ? null : Colors.grey.shade800,
                        colorBlendMode: _settings.isActive ? null : BlendMode.srcIn,
                      ),
                      Positioned(
                        bottom: 8,
                        child: Text(
                          'натисни',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 2,
                            color: Colors.white.withOpacity(
                                _settings.isActive ? 0.5 : 0.2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Цитата (з'являється після натискання)
              if (_showQuote)
                FadeTransition(
                  opacity: _quoteAnim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.2),
                      end: Offset.zero,
                    ).animate(_quoteAnim),
                    child: GestureDetector(
                      onTap: _dismissQuote,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade800),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _currentQuote!['text']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                                height: 1.6,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '— ${_currentQuote!['author']}',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'торкніться щоб закрити',
                              style: TextStyle(
                                color: Colors.grey.shade800,
                                fontSize: 11,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              const Spacer(),

              // Перемикач активності
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _settings.isActive ? 'АКТИВНО' : 'НЕАКТИВНО',
                    style: TextStyle(
                      fontSize: 13,
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

              if (_settings.isActive)
                Text(
                  'Сигнал кожні ${_settings.minIntervalMinutes}–${_settings.maxIntervalMinutes} хв',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    letterSpacing: 1,
                  ),
                ),

              const SizedBox(height: 24),

              // Статистика
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
                          'зупинок сьогодні',
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

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
