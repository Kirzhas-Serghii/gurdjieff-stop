import 'package:flutter/material.dart';
import '../models/stats_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int _today = 0;
  int _week = 0;
  int _total = 0;
  Map<String, int> _daily = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final today = await StatsService.getTodayCount();
    final week = await StatsService.getWeekCount();
    final total = await StatsService.getTotalCount();
    final daily = await StatsService.getDailyStats();

    setState(() {
      _today = today;
      _week = week;
      _total = total;
      _daily = daily;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Статистика', style: TextStyle(letterSpacing: 1)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 16),

                // Три лічильники
                Row(
                  children: [
                    _statCard('$_today', 'сьогодні'),
                    const SizedBox(width: 12),
                    _statCard('$_week', 'тиждень'),
                    const SizedBox(width: 12),
                    _statCard('$_total', 'всього'),
                  ],
                ),

                const SizedBox(height: 40),

                if (_daily.isNotEmpty) ...[
                  const Text(
                    'ОСТАННЯ АКТИВНІСТЬ',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Проста гістограма
                  ..._daily.entries.toList().reversed.take(14).map((entry) {
                    final maxVal =
                        _daily.values.fold(0, (a, b) => a > b ? a : b);
                    final fraction = maxVal > 0 ? entry.value / maxVal : 0.0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 48,
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                            ),
                          ),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: fraction.toDouble(),
                                backgroundColor: Colors.grey.shade900,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                                minHeight: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${entry.value}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }),
                ] else
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text(
                        'Ще немає даних.\nАктивуйте нагадування на головному екрані.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, height: 1.6),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _statCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade900),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w100,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style:
                  const TextStyle(fontSize: 11, color: Colors.grey, letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }
}
