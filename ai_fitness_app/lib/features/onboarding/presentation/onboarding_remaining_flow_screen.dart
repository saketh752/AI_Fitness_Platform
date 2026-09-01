import 'package:flutter/material.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../auth/presentation/mock_auth_state.dart';
import 'onboarding_state.dart';

enum RemainingOnboardingScreen { food, budget, time, review }

class OnboardingRemainingFlowScreen extends StatefulWidget {
  const OnboardingRemainingFlowScreen({required this.screen, super.key});

  final RemainingOnboardingScreen screen;

  @override
  State<OnboardingRemainingFlowScreen> createState() =>
      _OnboardingRemainingFlowScreenState();
}

class _OnboardingRemainingFlowScreenState
    extends State<OnboardingRemainingFlowScreen> {
  final _scrollController = ScrollController();
  final _customBudgetController = TextEditingController();
  final _otherFoodController = TextEditingController();
  final _customDurationController = TextEditingController();
  final Set<String> _foods = {...OnboardingData.foods};
  String? _budget = OnboardingData.budget == 'Not selected'
      ? null
      : OnboardingData.budget;
  String? _frequency = OnboardingData.workoutFrequency == 'Not selected'
      ? null
      : OnboardingData.workoutFrequency;
  String? _duration = OnboardingData.preferredDuration == 'Not selected'
      ? null
      : OnboardingData.preferredDuration;
  bool _generating = false;
  bool _buttonPressed = false;

  @override
  void initState() {
    super.initState();
    _customBudgetController.text = OnboardingData.customBudget;
    _otherFoodController.text = OnboardingData.otherFood;
    _customDurationController.text = OnboardingData.customDuration;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _customBudgetController.dispose();
    _otherFoodController.dispose();
    _customDurationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _backButton(),
              const SizedBox(height: 16),
              _progress(),
              const SizedBox(height: 12),
              Text(_stepLabel, style: _body(fontWeight: FontWeight.w600)),
              const SizedBox(height: 18),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: _content(),
                ),
              ),
              const SizedBox(height: 12),
              _actionButton(),
            ],
          ),
        ),
      ),
    );
  }

  String get _stepLabel => switch (widget.screen) {
    RemainingOnboardingScreen.food => 'Step 5 of 7',
    RemainingOnboardingScreen.budget => 'Step 6 of 7',
    RemainingOnboardingScreen.time => 'Step 7 of 7',
    RemainingOnboardingScreen.review => 'Getting started',
  };

  Widget _backButton() => Container(
    width: 40,
    height: 40,
    decoration: const BoxDecoration(
      color: AppColors.primaryLight,
      shape: BoxShape.circle,
    ),
    child: IconButton(
      padding: EdgeInsets.zero,
      onPressed: () => Navigator.pop(context),
      icon: const Icon(Icons.chevron_left_rounded),
    ),
  );

  Widget _progress() {
    final value = switch (widget.screen) {
      RemainingOnboardingScreen.food => .72,
      RemainingOnboardingScreen.budget => .86,
      RemainingOnboardingScreen.time => 1.0,
      RemainingOnboardingScreen.review => 1.0,
    };
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 6,
        backgroundColor: Colors.grey.shade300,
        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
      ),
    );
  }

  Widget _content() => switch (widget.screen) {
    RemainingOnboardingScreen.food => _foodContent(),
    RemainingOnboardingScreen.budget => _budgetContent(),
    RemainingOnboardingScreen.time => _timeContent(),
    RemainingOnboardingScreen.review => _reviewContent(),
  };

  Widget _foodContent() {
    const options = [
      'Eggs',
      'Milk & Dairy',
      'Rice & Grains',
      'Dal & Legumes',
      'Chicken / Meat',
      'Fruits',
      'Vegetables',
      'Other / Limited Options',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What food do you\nregularly have access\nto?', style: _title()),
        const SizedBox(height: 4),
        Text(
          'Select the foods you can realistically include in\nyour routine.',
          style: _body(),
        ),
        const SizedBox(height: 4),
        ...options.map(
          (option) => _choice(
            option,
            _foods.contains(option),
            () => _toggleFood(option),
          ),
        ),
        if (_foods.contains('Other / Limited Options'))
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 12),
            child: TextField(
              controller: _otherFoodController,
              onChanged: (value) {
                OnboardingData.otherFood = value.trim();
                setState(() {});
              },
              decoration: _inputDecoration(
                'Type other foods you regularly have',
              ),
            ),
          ),
      ],
    );
  }

  Widget _budgetContent() {
    const options = [
      'Under ₹1,000',
      '₹1,000–₹2,500',
      '₹2,500–₹5,000',
      'Above ₹5,000',
      'Custom Amount',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("What's your monthly\nfitness food budget?", style: _title()),
        const SizedBox(height: 12),
        Text(
          "We'll keep your nutrition recommendations\nrealistic for your budget.",
          style: _body(),
        ),
        const SizedBox(height: 30),
        ...options.map(
          (option) =>
              _choice(option, _budget == option, () => _selectBudget(option)),
        ),
        if (_budget == 'Custom Amount')
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 12),
            child: TextField(
              controller: _customBudgetController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: _inputDecoration('Enter monthly amount in ₹'),
            ),
          ),
      ],
    );
  }

  Widget _timeContent() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('How much time can you\nrealistically give?', style: _title()),
      const SizedBox(height: 8),
      Text('Choose what fits your regular schedule.', style: _body()),
      const SizedBox(height: 22),
      _sectionLabel('Workout frequency'),
      ...['2–3 days/week', '4–5 days/week', '6+ days/week'].map(
        (option) => _choice(
          option,
          _frequency == option,
          () => setState(() => _frequency = option),
        ),
      ),
      const SizedBox(height: 8),
      _sectionLabel('Preferred duration'),
      ...['30 min', '45 min', '60 min', 'Custom minutes'].map(
        (option) =>
            _choice(option, _duration == option, () => _selectDuration(option)),
      ),
      if (_duration == 'Custom minutes')
        Padding(
          padding: const EdgeInsets.only(top: 2, bottom: 12),
          child: TextField(
            controller: _customDurationController,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: _inputDecoration('Enter workout minutes only'),
          ),
        ),
    ],
  );

  Widget _reviewContent() {
    final rows = [
      (
        'Profile',
        '${OnboardingData.name}, ${OnboardingData.gender}',
        AppRoutes.onboardingBasicProfile,
      ),
      ('Goal', OnboardingData.goal, AppRoutes.onboardingFitnessGoal),
      (
        'Fitness Level',
        OnboardingData.fitnessLevel,
        AppRoutes.onboardingFitnessContext,
      ),
      (
        'Equipment',
        OnboardingData.equipmentLabel,
        AppRoutes.onboardingAvailableEquipment,
      ),
      (
        'Food Availability',
        OnboardingData.foodLabel,
        AppRoutes.onboardingFoodAvailability,
      ),
      ('Budget', OnboardingData.budgetLabel, AppRoutes.onboardingBudget),
      ('Time', OnboardingData.timeLabel, AppRoutes.onboardingTime),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your plan is ready\nto be personalized.', style: _title()),
        const SizedBox(height: 12),
        Text(
          'Review your information before we\ncreate your fitness plan.',
          style: _body(),
        ),
        const SizedBox(height: 10),
        ...rows.map((row) => _reviewRow(row.$1, row.$2, row.$3)),
      ],
    );
  }

  Widget _reviewRow(String label, String value, String route) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 13),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: _body(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: _body(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, route),
          child: const Text('Edit'),
        ),
      ],
    ),
  );

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: _body(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
    ),
  );

  Widget _choice(String text, bool selected, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 19),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade300,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Text(
          text,
          style: _body(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  );

  Widget _actionButton() {
    final enabled = _canContinue;
    final label = widget.screen == RemainingOnboardingScreen.review
        ? 'Generate My Plan'
        : 'Continue';
    return Listener(
      onPointerDown: enabled && !_generating
          ? (_) => setState(() => _buttonPressed = true)
          : null,
      onPointerUp: enabled && !_generating
          ? (_) => setState(() => _buttonPressed = false)
          : null,
      onPointerCancel: (_) => setState(() => _buttonPressed = false),
      child: AnimatedScale(
        scale: _buttonPressed ? .97 : 1,
        duration: const Duration(milliseconds: 120),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: enabled && !_generating ? _continue : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 0,
            ),
            child: _generating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  bool get _canContinue => switch (widget.screen) {
    RemainingOnboardingScreen.food => _foods.isNotEmpty,
    RemainingOnboardingScreen.budget =>
      _budget != null &&
          (_budget != 'Custom Amount' ||
              (int.tryParse(_customBudgetController.text.trim()) ?? 0) > 0),
    RemainingOnboardingScreen.time =>
      _frequency != null &&
          _duration != null &&
          (_duration != 'Custom minutes' ||
              (int.tryParse(_customDurationController.text.trim()) ?? 0) > 0),
    RemainingOnboardingScreen.review => true,
  };

  void _continue() {
    if (widget.screen == RemainingOnboardingScreen.review) {
      setState(() => _generating = true);
      Navigator.pushReplacementNamed(context, AppRoutes.planGenerationLoading);
      return;
    }
    if (widget.screen == RemainingOnboardingScreen.food) {
      OnboardingData.foods
        ..clear()
        ..addAll(_foods);
      OnboardingData.otherFood = _otherFoodController.text.trim();
    } else if (widget.screen == RemainingOnboardingScreen.budget) {
      OnboardingData.budget = _budget!;
      OnboardingData.customBudget = _customBudgetController.text.trim();
    } else {
      OnboardingData.workoutFrequency = _frequency!;
      OnboardingData.preferredDuration = _duration!;
      OnboardingData.customDuration = _customDurationController.text.trim();
    }
    final route = switch (widget.screen) {
      RemainingOnboardingScreen.food => AppRoutes.onboardingBudget,
      RemainingOnboardingScreen.budget => AppRoutes.onboardingTime,
      RemainingOnboardingScreen.time => AppRoutes.onboardingReview,
      RemainingOnboardingScreen.review => AppRoutes.home,
    };
    MockAuthState.setResumeRoute(route);
    Navigator.pushNamed(context, route);
  }

  void _toggleFood(String option) {
    final revealsInput =
        option == 'Other / Limited Options' && !_foods.contains(option);
    setState(() {
      _foods.contains(option) ? _foods.remove(option) : _foods.add(option);
    });
    OnboardingData.foods
      ..clear()
      ..addAll(_foods);
    if (revealsInput) _scrollToCustomInput();
  }

  void _selectBudget(String option) {
    setState(() => _budget = option);
    if (option == 'Custom Amount') _scrollToCustomInput();
  }

  void _selectDuration(String option) {
    setState(() => _duration = option);
    if (option == 'Custom minutes') _scrollToCustomInput();
  }

  void _scrollToCustomInput() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
  );

  TextStyle _title() => const TextStyle(
    color: AppColors.textPrimary,
    fontSize: 30,
    height: 1.15,
    fontWeight: FontWeight.w700,
  );
  TextStyle _body({
    double fontSize = 15,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textSecondary,
  }) => TextStyle(
    color: color,
    fontSize: fontSize,
    height: 1.4,
    fontWeight: fontWeight,
  );
}
