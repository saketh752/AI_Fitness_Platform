import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../data/nutrition_api_service.dart';

class NutritionOverviewScreen extends StatefulWidget {
  const NutritionOverviewScreen({super.key});

  @override
  State<NutritionOverviewScreen> createState() =>
      _NutritionOverviewScreenState();
}

class _NutritionOverviewScreenState extends State<NutritionOverviewScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final _nutritionApiService = NutritionApiService();

  Map<String, dynamic>? _summary;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _loadNutritionData();
  }

  Future<void> _loadNutritionData() async {
    try {
      final summary = await _nutritionApiService.getTodaySummary();
      if (mounted) {
        setState(() {
          _summary = summary;
        });
      }
    } catch (_) {
      // Graceful fallback
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final targetCalories = _summary?['targetCalories'] ?? 2200;
    final consumedCalories = _summary?['consumedCalories'] ?? 0;
    final remainingCalories = _summary?['remainingCalories'] ?? (targetCalories - consumedCalories);

    final targetProtein = _summary?['targetProteinGrams'] ?? 140;
    final consumedProtein = _summary?['consumedProteinGrams'] ?? 0;
    final proteinPct = targetProtein > 0 ? (consumedProtein / targetProtein) : 0.0;

    final targetCarbs = _summary?['targetCarbsGrams'] ?? 240;
    final consumedCarbs = _summary?['consumedCarbsGrams'] ?? 0;
    final carbsPct = targetCarbs > 0 ? (consumedCarbs / targetCarbs) : 0.0;

    final targetFat = _summary?['targetFatGrams'] ?? 65;
    final consumedFat = _summary?['consumedFatGrams'] ?? 0;
    final fatPct = targetFat > 0 ? (consumedFat / targetFat) : 0.0;

    final calProgress = targetCalories > 0 ? (consumedCalories / targetCalories).clamp(0.0, 1.0) : 0.0;
    final todayMeals = (_summary?['todayMeals'] as List?) ?? [];

    return RefreshIndicator(
      onRefresh: _loadNutritionData,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _reveal(0, _header()),
            const SizedBox(height: 20),
            _reveal(1, _targetCard(targetCalories, consumedCalories, remainingCalories, calProgress)),
            const SizedBox(height: 20),
            _reveal(2, _macroCard(consumedProtein, targetProtein, proteinPct, consumedCarbs, targetCarbs, carbsPct, consumedFat, targetFat, fatPct)),
            const SizedBox(height: 20),
            _reveal(3, _mealsSection(todayMeals)),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "TODAY'S NUTRITION",
              style: _body(
                fontSize: 11,
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text('Nutrition', style: _title(fontSize: 26)),
            const SizedBox(height: 4),
            Text('Your personalized nutrition plan', style: _body()),
          ],
        ),
        IconButton(
          onPressed: _showLogMealDialog,
          icon: const CircleAvatar(
            backgroundColor: AppColors.primary,
            radius: 18,
            child: Icon(Icons.add, color: Colors.white, size: 22),
          ),
          tooltip: 'Log Meal',
        ),
      ],
    );
  }

  Widget _targetCard(int target, int consumed, int remaining, double progress) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TODAY'S TARGET",
            style: _body(
              fontSize: 11,
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$target', style: _title(fontSize: 30)),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text('kcal', style: _body(fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: (progress * _controller.value).clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: const Color(0xFFF0F0F0),
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Consumed: $consumed kcal',
                style: _body(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Remaining: $remaining kcal',
                style: _body(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _macroCard(
    int consumedP, int targetP, double pctP,
    int consumedC, int targetC, double pctC,
    int consumedF, int targetF, double pctF,
  ) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TODAY'S MACROS",
            style: _body(
              fontSize: 11,
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          _macroRow(
            label: 'Protein',
            value: '${consumedP}g / ${targetP}g',
            percentage: pctP,
            percentageText: '${(pctP * 100).toInt()}%',
          ),
          const SizedBox(height: 18),
          _macroRow(
            label: 'Carbs',
            value: '${consumedC}g / ${targetC}g',
            percentage: pctC,
            percentageText: '${(pctC * 100).toInt()}%',
          ),
          const SizedBox(height: 18),
          _macroRow(
            label: 'Fat',
            value: '${consumedF}g / ${targetF}g',
            percentage: pctF,
            percentageText: '${(pctF * 100).toInt()}%',
          ),
        ],
      ),
    );
  }

  Widget _macroRow({
    required String label,
    required String value,
    required double percentage,
    required String percentageText,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: _body(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: _body(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  percentageText,
                  style: _body(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 7),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: (percentage * _controller.value).clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: const Color(0xFFF0F0F0),
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _mealsSection(List todayMeals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "TODAY'S MEALS",
              style: _body(
                fontSize: 11,
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton.icon(
              onPressed: _showLogMealDialog,
              icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
              label: const Text('Log Meal', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (todayMeals.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: Text(
                'No meals logged today yet. Tap "+ Log Meal" above to record your nutrition!',
                textAlign: TextAlign.center,
                style: _body(fontSize: 13),
              ),
            ),
          )
        else
          ...todayMeals.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _liveMealCard(Map<String, dynamic>.from(m as Map)),
              )),
      ],
    );
  }

  Widget _liveMealCard(Map<String, dynamic> meal) {
    final name = meal['name']?.toString() ?? 'Meal';
    final type = meal['mealType']?.toString() ?? 'SNACK';
    final cal = meal['calories'] ?? 0;
    final protein = meal['proteinGrams'] ?? 0;
    final id = meal['id'] as int?;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.restaurant_menu_rounded, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(type, style: _body(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(name, style: _title(fontSize: 15)),
                  const SizedBox(height: 3),
                  Text('$cal kcal · ${protein}g protein', style: _body(fontSize: 12)),
                ],
              ),
            ),
            if (id != null)
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.grey, size: 20),
                onPressed: () async {
                  await _nutritionApiService.deleteMeal(id);
                  _loadNutritionData();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showLogMealDialog() {
    final nameController = TextEditingController();
    final calController = TextEditingController();
    final proteinController = TextEditingController();
    final carbsController = TextEditingController();
    final fatController = TextEditingController();
    String selectedType = 'LUNCH';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Log a Meal', style: _title(fontSize: 20)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    decoration: InputDecoration(
                      labelText: 'Meal Type',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'BREAKFAST', child: Text('Breakfast')),
                      DropdownMenuItem(value: 'LUNCH', child: Text('Lunch')),
                      DropdownMenuItem(value: 'DINNER', child: Text('Dinner')),
                      DropdownMenuItem(value: 'SNACK', child: Text('Snack')),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedType = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Meal Name (e.g. Chicken Rice Bowl)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: calController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Calories',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: proteinController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Protein (g)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: carbsController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Carbs (g)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: fatController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Fat (g)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        final name = nameController.text.trim();
                        final cal = int.tryParse(calController.text) ?? 0;
                        final protein = int.tryParse(proteinController.text) ?? 0;
                        final carbs = int.tryParse(carbsController.text) ?? 0;
                        final fat = int.tryParse(fatController.text) ?? 0;
                        if (name.isNotEmpty && cal > 0) {
                          Navigator.pop(context);
                          await _nutritionApiService.logMeal(
                            name: name,
                            mealType: selectedType,
                            calories: cal,
                            proteinGrams: protein,
                            carbsGrams: carbs,
                            fatGrams: fat,
                          );
                          _loadNutritionData();
                        }
                      },
                      child: const Text('Save Meal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _reveal(int index, Widget child) {
    final start = (index * .12).clamp(0.0, .55);
    final end = (start + .45).clamp(0.0, 1.0);

    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOut),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, .04),
          end: Offset.zero,
        ).animate(animation),
        child: child,
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

  TextStyle _title({double fontSize = 18}) => TextStyle(
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w700,
    fontSize: fontSize,
  );

  TextStyle _body({
    Color color = AppColors.textSecondary,
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w400,
  }) => TextStyle(
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: 1.35,
  );
}
