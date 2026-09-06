import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../data/progress_api_service.dart';
import 'progress_data.dart';

class ProgressOverviewScreen extends StatefulWidget {
  const ProgressOverviewScreen({super.key, this.data = ProgressData.mock});

  final ProgressData data;

  @override
  State<ProgressOverviewScreen> createState() => _ProgressOverviewScreenState();
}

class _ProgressOverviewScreenState extends State<ProgressOverviewScreen> {
  final _progressApiService = ProgressApiService();
  Map<String, dynamic>? _summary;
  List<Map<String, dynamic>> _weightHistory = [];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final summary = await _progressApiService.getSummary();
      final weights = await _progressApiService.getWeightHistory();
      if (mounted) {
        setState(() {
          _summary = summary;
          _weightHistory = weights;
        });
      }
    } catch (_) {
      // Graceful fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final streak = _summary?['currentStreak'] ?? widget.data.currentStreakDays;
    final totalWorkouts = _summary?['totalWorkoutsCompleted'] ?? widget.data.totalCompletedWorkouts;
    final totalCalories = _summary?['totalCaloriesBurned'] ?? 1450;
    final totalMinutes = _summary?['totalActiveMinutes'] ?? 180;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadProgress,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Your Fitness Journey', style: _title(fontSize: 24)),
                    IconButton(
                      icon: const CircleAvatar(
                        backgroundColor: AppColors.primary,
                        radius: 16,
                        child: Icon(Icons.add, color: Colors.white, size: 20),
                      ),
                      tooltip: 'Log Weight',
                      onPressed: _showLogWeightDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _currentStreakCard(streak),
                const SizedBox(height: 16),
                _workoutProgressCard(totalWorkouts),
                const SizedBox(height: 16),
                _fitnessSummaryCard(totalCalories, totalMinutes),
                const SizedBox(height: 16),
                _weightLogCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        Material(
          color: AppColors.primaryLight,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            child: const SizedBox(
              width: 46,
              height: 46,
              child: Icon(
                Icons.trending_up_rounded,
                color: AppColors.primary,
                size: 26,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'PROGRESS',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _currentStreakCard(int streak) {
    return _card(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text('CURRENT STREAK', style: _sectionLabel()),
          ),
          const SizedBox(height: 18),
          Text(
            '🔥 $streak Days',
            textAlign: TextAlign.center,
            style: _title(fontSize: 26),
          ),
          const SizedBox(height: 6),
          Text(
            'Keep it going every day!',
            textAlign: TextAlign.center,
            style: _body(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _workoutProgressCard(int completedWorkouts) {
    final totalTarget = widget.data.weeklyWorkoutTarget;
    final progress = totalTarget > 0 ? (completedWorkouts / totalTarget).clamp(0.0, 1.0) : 0.0;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('WORKOUT PROGRESS', style: _sectionLabel()),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$completedWorkouts Workouts Completed', style: _title(fontSize: 17)),
              Text('${(progress * 100).toInt()}%', style: _title(fontSize: 17, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFF0F0F0),
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fitnessSummaryCard(int totalCalories, int totalMinutes) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TOTAL METRICS', style: _sectionLabel()),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$totalCalories kcal', style: _title(fontSize: 20)),
                    const SizedBox(height: 2),
                    Text('Total Burned', style: _body(fontSize: 12)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$totalMinutes min', style: _title(fontSize: 20)),
                    const SizedBox(height: 2),
                    Text('Active Time', style: _body(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _weightLogCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('WEIGHT LOGS', style: _sectionLabel()),
              TextButton(
                onPressed: _showLogWeightDialog,
                child: const Text('+ Log', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_weightHistory.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text('No weights logged yet. Tap "+ Log" to record your body weight!', style: _body(fontSize: 13)),
              ),
            )
          else
            ..._weightHistory.reversed.take(5).map((w) {
              final weight = w['weightKg']?.toString() ?? '--';
              final date = w['logDate']?.toString() ?? '';
              final notes = w['notes']?.toString() ?? '';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$weight kg', style: _title(fontSize: 16)),
                    Text('$date ${notes.isNotEmpty ? "($notes)" : ""}', style: _body(fontSize: 12)),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  void _showLogWeightDialog() {
    final weightController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Log Body Weight', style: _title(fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Weight (kg)',
                hintText: 'e.g. 75.5',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'e.g. Morning fasting',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final weight = double.tryParse(weightController.text.trim());
              if (weight != null && weight > 0) {
                Navigator.pop(context);
                await _progressApiService.logWeight(
                  weightKg: weight,
                  notes: notesController.text.trim(),
                );
                _loadProgress();
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(padding: const EdgeInsets.all(18), child: child),
    );
  }

  TextStyle _sectionLabel() => const TextStyle(
    color: AppColors.primary,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
  );

  TextStyle _title({double fontSize = 18, Color color = AppColors.textPrimary}) =>
      TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: fontSize);

  TextStyle _body({
    Color color = AppColors.textSecondary,
    double fontSize = 13,
  }) => TextStyle(color: color, fontSize: fontSize, height: 1.35);
}
