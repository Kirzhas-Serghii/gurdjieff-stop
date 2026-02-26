import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../services/audio_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AppSettings _settings = AppSettings();
  bool _loading = true;
  final _quoteController = TextEditingController();

  final List<Map<String, String>> _sounds = [
    {'key': 'bell', 'label': 'Дзвін'},
    {'key': 'tibetan_bowl', 'label': 'Тибетська чаша'},
    {'key': 'soft_chime', 'label': 'М\'який дзвінок'},
    {'key': 'gong', 'label': 'Гонг'},
    {'key': 'wind_bell', 'label': 'Вітряний дзвінок'},
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await AppSettings.load();
    setState(() {
      _settings = settings;
      _quoteController.text = settings.customQuote;
      _loading = false;
    });
  }

  Future<void> _save() async {
    _settings.customQuote = _quoteController.text;
    await _settings.save();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Збережено'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  void dispose() {
    _quoteController.dispose();
    super.dispose();
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          color: Colors.grey,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _divider() => Divider(color: Colors.grey.shade900, height: 1);

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
        title: const Text('Налаштування', style: TextStyle(letterSpacing: 1)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'Зберегти',
              style: TextStyle(color: Colors.white, letterSpacing: 1),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          // ІНТЕРВАЛ
          _sectionTitle('Інтервал'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade900),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Мінімум (хв)',
                        style: TextStyle(color: Colors.white)),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, color: Colors.grey, size: 20),
                          onPressed: () => setState(() {
                            if (_settings.minIntervalMinutes > 1)
                              _settings.minIntervalMinutes--;
                          }),
                        ),
                        Text(
                          '${_settings.minIntervalMinutes}',
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.grey, size: 20),
                          onPressed: () => setState(() {
                            if (_settings.minIntervalMinutes <
                                _settings.maxIntervalMinutes - 1)
                              _settings.minIntervalMinutes++;
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
                _divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Максимум (хв)',
                        style: TextStyle(color: Colors.white)),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, color: Colors.grey, size: 20),
                          onPressed: () => setState(() {
                            if (_settings.maxIntervalMinutes >
                                _settings.minIntervalMinutes + 1)
                              _settings.maxIntervalMinutes--;
                          }),
                        ),
                        Text(
                          '${_settings.maxIntervalMinutes}',
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.grey, size: 20),
                          onPressed: () => setState(() {
                            if (_settings.maxIntervalMinutes < 480)
                              _settings.maxIntervalMinutes++;
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // АКТИВНІ ГОДИНИ
          _sectionTitle('Активні години'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade900),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Тільки в активний час',
                        style: TextStyle(color: Colors.white)),
                    Switch(
                      value: _settings.useActiveHours,
                      onChanged: (v) =>
                          setState(() => _settings.useActiveHours = v),
                      activeColor: Colors.white,
                      activeTrackColor: Colors.grey.shade700,
                    ),
                  ],
                ),
                if (_settings.useActiveHours) ...[
                  _divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          const Text('Від',
                              style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove,
                                    color: Colors.grey, size: 18),
                                onPressed: () => setState(() {
                                  if (_settings.activeHourStart > 0)
                                    _settings.activeHourStart--;
                                }),
                              ),
                              Text(
                                '${_settings.activeHourStart}:00',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add,
                                    color: Colors.grey, size: 18),
                                onPressed: () => setState(() {
                                  if (_settings.activeHourStart <
                                      _settings.activeHourEnd - 1)
                                    _settings.activeHourStart++;
                                }),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('До',
                              style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove,
                                    color: Colors.grey, size: 18),
                                onPressed: () => setState(() {
                                  if (_settings.activeHourEnd >
                                      _settings.activeHourStart + 1)
                                    _settings.activeHourEnd--;
                                }),
                              ),
                              Text(
                                '${_settings.activeHourEnd}:00',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add,
                                    color: Colors.grey, size: 18),
                                onPressed: () => setState(() {
                                  if (_settings.activeHourEnd < 24)
                                    _settings.activeHourEnd++;
                                }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // РЕЖИМ СПОВІЩЕНЬ
          _sectionTitle('Режим сповіщень'),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade900),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _modeOption('vibration', Icons.vibration, 'Тільки вібрація'),
                _divider(),
                _modeOption('sound', Icons.music_note, 'Тільки звук'),
                _divider(),
                _modeOption('both', Icons.notifications_active,
                    'Вібрація + звук'),
              ],
            ),
          ),

          // ЗВУК
          _sectionTitle('Звук'),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade900),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: _sounds.asMap().entries.map((entry) {
                final sound = entry.value;
                final isLast = entry.key == _sounds.length - 1;
                return Column(
                  children: [
                    ListTile(
                      title: Text(
                        sound['label']!,
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.play_circle_outline,
                                color: Colors.grey, size: 22),
                            onPressed: () => AudioService.preview(
                                sound['key']!, _settings.volume),
                          ),
                          if (_settings.selectedSound == sound['key'])
                            const Icon(Icons.check, color: Colors.white, size: 18),
                        ],
                      ),
                      onTap: () => setState(
                          () => _settings.selectedSound = sound['key']!),
                    ),
                    if (!isLast) _divider(),
                  ],
                );
              }).toList(),
            ),
          ),

          // ГУЧНІСТЬ
          _sectionTitle('Гучність'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade900),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.volume_down, color: Colors.grey, size: 20),
                Expanded(
                  child: Slider(
                    value: _settings.volume,
                    onChanged: (v) => setState(() => _settings.volume = v),
                    activeColor: Colors.white,
                    inactiveColor: Colors.grey.shade800,
                  ),
                ),
                const Icon(Icons.volume_up, color: Colors.grey, size: 20),
              ],
            ),
          ),

          // ПОСТУПОВЕ ЗБІЛЬШЕННЯ ГУЧНОСТІ
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade900),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Поступове збільшення гучності',
                    style: TextStyle(color: Colors.white)),
                Switch(
                  value: _settings.fadeIn,
                  onChanged: (v) => setState(() => _settings.fadeIn = v),
                  activeColor: Colors.white,
                  activeTrackColor: Colors.grey.shade700,
                ),
              ],
            ),
          ),

          // ЦИТАТА
          _sectionTitle('Власна цитата на екрані'),
          TextField(
            controller: _quoteController,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: InputDecoration(
              hintText:
                  'Зупини все. Відчуй своє тіло. Згадай себе. (за замовчуванням)',
              hintStyle: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade900),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _modeOption(String mode, IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey, size: 20),
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 15)),
      trailing: _settings.notificationMode == mode
          ? const Icon(Icons.check, color: Colors.white, size: 18)
          : null,
      onTap: () => setState(() => _settings.notificationMode = mode),
    );
  }
}
