import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../models/meal.dart';
import '../state/nutrition_state.dart';

class MealDetailsScreen extends StatefulWidget {
  final Meal meal;

  const MealDetailsScreen({super.key, required this.meal});

  @override
  State<MealDetailsScreen> createState() => _MealDetailsScreenState();
}

class _MealDetailsScreenState extends State<MealDetailsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _markAsEaten() async {
    if (_isSaving || widget.meal.isEaten) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 350));

    if (!mounted) {
      return;
    }

    NutritionState.markAsEaten(widget.meal.id);

    setState(() {
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: FadeTransition(
            opacity: _controller,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.03),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: _controller, curve: Curves.easeOut),
                  ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _backButton(context),
                  const SizedBox(height: 22),
                  _mealTypePill(meal.type.label),
                  const SizedBox(height: 16),
                  Text(
                    meal.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '${meal.calories} kcal · ${meal.protein}g Protein',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _imagePlaceholder(),
                  const SizedBox(height: 24),
                  _nutritionCard(meal),
                  if (meal.ingredients.isNotEmpty) ...[
                    const SizedBox(height: 26),
                    _ingredientsSection(meal.ingredients),
                  ],
                  const SizedBox(height: 28),
                  _markAsEatenButton(meal),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _backButton(BuildContext context) {
    return Material(
      color: const Color(0xFFC9F6EF),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => Navigator.pop(context),
        child: const SizedBox(
          width: 46,
          height: 46,
          child: Icon(
            Icons.chevron_left_rounded,
            color: AppColors.textPrimary,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _mealTypePill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFC9F6EF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 190,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F3),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(
        child: Icon(
          Icons.restaurant_rounded,
          color: AppColors.primary,
          size: 58,
        ),
      ),
    );
  }

  Widget _nutritionCard(Meal meal) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NUTRITION',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _nutritionRow('Calories', '${meal.calories} Kcal'),
          _nutritionRow('Protein', '${meal.protein} g'),
          _nutritionRow('Carbs', meal.carbs == null ? '—' : '${meal.carbs} g'),
          _nutritionRow(
            'Fat',
            meal.fat == null ? '—' : '${meal.fat} g',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _nutritionRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _ingredientsSection(List<String> ingredients) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'INGREDIENTS',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ...ingredients.map(
          (ingredient) => Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Text(
              ingredient,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _markAsEatenButton(Meal meal) {
    final eaten = meal.isEaten;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: AnimatedScale(
        scale: _isSaving ? 0.98 : 1,
        duration: const Duration(milliseconds: 120),
        child: ElevatedButton(
          onPressed: eaten || _isSaving ? null : _markAsEaten,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: const Color(0xFFB9E9E1),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 0,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _isSaving
                ? const SizedBox(
                    key: ValueKey('saving'),
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : eaten
                ? const Row(
                    key: ValueKey('eaten'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_rounded, size: 20),
                      SizedBox(width: 7),
                      Text(
                        'Eaten',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  )
                : const Text(
                    'Mark as Eaten',
                    key: ValueKey('mark'),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
          ),
        ),
      ),
    );
  }
}
