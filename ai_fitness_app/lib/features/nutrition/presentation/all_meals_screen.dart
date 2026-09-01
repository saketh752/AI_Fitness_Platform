import 'package:flutter/material.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../models/meal.dart';
import '../state/nutrition_state.dart';

class AllMealsScreen extends StatelessWidget {
  const AllMealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final meals = NutritionState.meals;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _backButton(context),
                  const SizedBox(width: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC9F6EF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Meals',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Your Meal Plan',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Personalized for your goals',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              ...meals.asMap().entries.map((entry) {
                final index = entry.key;
                final meal = entry.value;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == meals.length - 1 ? 0 : 16,
                  ),
                  child: _mealCard(context, meal: meal),
                );
              }),
              const SizedBox(height: 30),
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text(
                  'Total : 1,750',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
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

  Widget _mealCard(BuildContext context, {required Meal meal}) {
    return Material(
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.mealDetails, arguments: meal);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _emojiForMeal(meal.type),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      meal.type.label,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFFC9F6EF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _allMealsName(meal),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${meal.calories} kcal · ${meal.protein}g Protein',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _allMealsName(Meal meal) {
    if (meal.type == MealType.lunch) {
      return 'Grilled Chicken & Rice';
    }

    return meal.name;
  }

  String _emojiForMeal(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return '🍳';
      case MealType.lunch:
        return '🍛';
      case MealType.dinner:
        return '🍲';
      case MealType.snack:
        return '🥣';
    }
  }
}
