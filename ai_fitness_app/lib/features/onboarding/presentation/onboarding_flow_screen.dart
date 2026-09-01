import 'package:flutter/material.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../auth/presentation/mock_auth_state.dart';
import 'onboarding_state.dart';

enum OnboardingScreen {
  introduction,
  fitnessGoal,
  fitnessContext,
  basicProfile,
  equipment,
}

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({required this.screen, super.key});

  final OnboardingScreen screen;

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  String? _selectedOption;
  final Set<String> _equipment = OnboardingData.equipment;
  bool _otherEquipmentSelected = false;
  String _gender = OnboardingData.gender;
  final _otherEquipmentController = TextEditingController();
  final _ageController = TextEditingController(text: '28');
  final _heightController = TextEditingController(text: '175 cm');
  final _weightController = TextEditingController(text: '70 kg');
  String? _selectionError;
  @override
  void initState() {
    super.initState();
    _selectedOption = switch (widget.screen) {
      OnboardingScreen.fitnessGoal =>
        OnboardingData.goal == 'Not selected' ? null : OnboardingData.goal,
      OnboardingScreen.fitnessContext =>
        OnboardingData.fitnessLevel == 'Not selected'
            ? null
            : OnboardingData.fitnessLevel,
      _ => null,
    };
    _ageController.text = OnboardingData.age;
    _heightController.text = OnboardingData.height;
    _weightController.text = OnboardingData.weight;
    const listedEquipment = {
      'Full Gym',
      'Dumbbells',
      'Barbell',
      'Resistance Bands',
      'Bodyweight Only',
    };
    final customEquipment = _equipment.difference(listedEquipment);
    _otherEquipmentSelected = customEquipment.isNotEmpty;
    if (customEquipment.isNotEmpty) {
      _otherEquipmentController.text = customEquipment.first;
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _otherEquipmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIntro = widget.screen == OnboardingScreen.introduction;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isIntro) _backButton(),
              if (!isIntro) const SizedBox(height: 16),
              _progress(),
              const SizedBox(height: 12),
              Text(_stepLabel(), style: _body(fontWeight: FontWeight.w600)),
              const SizedBox(height: 22),
              Expanded(
                child: SingleChildScrollView(
                  child: isIntro ? _intro() : _content(),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                child: _selectionError == null
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          _selectionError!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.errorText,
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                      ),
              ),
              _actionButton(isIntro),
            ],
          ),
        ),
      ),
    );
  }

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
      icon: const Icon(
        Icons.chevron_left_rounded,
        color: AppColors.textPrimary,
      ),
    ),
  );

  Widget _progress() {
    final value = switch (widget.screen) {
      OnboardingScreen.introduction => .06,
      OnboardingScreen.fitnessGoal => .30,
      OnboardingScreen.fitnessContext => .45,
      OnboardingScreen.basicProfile => .15,
      OnboardingScreen.equipment => .60,
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

  String _stepLabel() => switch (widget.screen) {
    OnboardingScreen.introduction => 'Getting started',
    OnboardingScreen.fitnessGoal => 'Step 2 of 7',
    OnboardingScreen.fitnessContext => 'Step 3 of 7',
    OnboardingScreen.basicProfile => 'Step 1 of 7',
    OnboardingScreen.equipment => 'Step 4 of 7',
  };

  Widget _intro() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Your plan starts with\nyou.', style: _title()),
      const SizedBox(height: 12),
      Text(
        'Answer a few quick questions and we’ll tailor\nyour fitness experience.',
        style: _body(),
      ),
      const SizedBox(height: 54),
      Container(
        width: double.infinity,
        height: 224,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Personalized training\nthat fits real life.',
              textAlign: TextAlign.center,
              style: _body(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _content() => switch (widget.screen) {
    OnboardingScreen.fitnessGoal => _choices(
      'What’s your main goal?',
      'Choose the focus that feels most motivating right\nnow.',
      ['Build Muscle', 'Lose Fat', 'Maintain Fitness'],
    ),
    OnboardingScreen.fitnessContext => _choices(
      'Where are you starting\nfrom?',
      'Pick the level that best reflects your current\ntraining experience.',
      ['Beginner', 'Intermediate', 'Advanced'],
    ),
    OnboardingScreen.basicProfile => _profile(),
    OnboardingScreen.equipment => _equipmentContent(),
    _ => const SizedBox.shrink(),
  };

  Widget _choices(String title, String description, List<String> options) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: _title()),
          const SizedBox(height: 44),
          Text(description, style: _body()),
          const SizedBox(height: 32),
          ...options.map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _option(
                option,
                _selectedOption == option,
                () => setState(() {
                  _selectedOption = option;
                  _selectionError = null;
                }),
              ),
            ),
          ),
        ],
      );

  Widget _profile() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Let’s get the basics.', style: _title()),
      const SizedBox(height: 44),
      Text(
        'This helps us make your plan feel personal from\nday one.',
        style: _body(),
      ),
      const SizedBox(height: 38),
      _profileField('Age', _ageController),
      _genderField(),
      _profileField('Height', _heightController),
      _profileField('Weight', _weightController),
    ],
  );

  Widget _equipmentContent() {
    const options = [
      'Full Gym',
      'Dumbbells',
      'Barbell',
      'Resistance Bands',
      'Bodyweight Only',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What equipment do you\nhave?', style: _title()),
        const SizedBox(height: 12),
        Text(
          'Select everything you can use. You can update\nthis later.',
          style: _body(),
        ),
        const SizedBox(height: 32),
        ...options.map(
          (option) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _option(
              option,
              _equipment.contains(option),
              () => setState(() {
                _equipment.contains(option)
                    ? _equipment.remove(option)
                    : _equipment.add(option);
                _selectionError = null;
              }),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _option(
            'Other equipment',
            _otherEquipmentSelected,
            () => setState(() {
              _otherEquipmentSelected = !_otherEquipmentSelected;
              _selectionError = null;
            }),
          ),
        ),
        if (_otherEquipmentSelected)
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 8),
            child: TextField(
              controller: _otherEquipmentController,
              autofocus: true,
              onChanged: (_) {
                if (_selectionError != null) {
                  setState(() => _selectionError = null);
                }
              },
              decoration: InputDecoration(
                hintText: 'Type any other equipment you have',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _option(String text, bool selected, VoidCallback onTap) => InkWell(
    borderRadius: BorderRadius.circular(18),
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 21),
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
        style: _body(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      ),
    ),
  );

  Widget _profileField(String label, TextEditingController controller) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: _body(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 7),
            SizedBox(
              width: 162,
              height: 48,
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _genderField() => Padding(
    padding: const EdgeInsets.only(bottom: 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: _body(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 7),
        SizedBox(
          width: 220,
          height: 48,
          child: DropdownButtonFormField<String>(
            initialValue: _gender,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'Male', child: Text('Male')),
              DropdownMenuItem(value: 'Female', child: Text('Female')),
              DropdownMenuItem(value: 'Other', child: Text('Other')),
              DropdownMenuItem(
                value: 'Prefer not to say',
                child: Text('Prefer not to say'),
              ),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _gender = value);
            },
          ),
        ),
      ],
    ),
  );

  Widget _actionButton(bool isIntro) => SizedBox(
    width: double.infinity,
    height: 52,
    child: ElevatedButton(
      onPressed: _continue,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        elevation: 0,
      ),
      child: Text(
        isIntro ? 'Let’s begin' : 'Continue',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );

  void _continue() {
    if (widget.screen == OnboardingScreen.fitnessGoal &&
        _selectedOption == null) {
      setState(() => _selectionError = 'Please select your main fitness goal.');
      return;
    }
    if (widget.screen == OnboardingScreen.fitnessContext &&
        _selectedOption == null) {
      setState(() => _selectionError = 'Please select your fitness level.');
      return;
    }
    final hasCustomEquipment =
        _otherEquipmentSelected &&
        _otherEquipmentController.text.trim().isNotEmpty;
    if (widget.screen == OnboardingScreen.equipment &&
        _equipment.isEmpty &&
        !hasCustomEquipment) {
      setState(
        () => _selectionError = _otherEquipmentSelected
            ? 'Please enter your other equipment or choose a listed option.'
            : 'Please select at least one equipment option.',
      );
      return;
    }
    setState(() => _selectionError = null);
    final step = switch (widget.screen) {
      OnboardingScreen.introduction => 0,
      OnboardingScreen.fitnessGoal => 1,
      OnboardingScreen.fitnessContext => 2,
      OnboardingScreen.basicProfile => 3,
      OnboardingScreen.equipment => 4,
    };
    if (widget.screen == OnboardingScreen.fitnessGoal &&
        _selectedOption != null) {
      OnboardingData.goal = _selectedOption!;
    }
    if (widget.screen == OnboardingScreen.fitnessContext &&
        _selectedOption != null) {
      OnboardingData.fitnessLevel = _selectedOption!;
    }
    if (widget.screen == OnboardingScreen.basicProfile) {
      OnboardingData.gender = _gender;
      OnboardingData.age = _ageController.text.trim();
      OnboardingData.height = _heightController.text.trim();
      OnboardingData.weight = _weightController.text.trim();
    }
    if (widget.screen == OnboardingScreen.equipment) {
      _equipment.removeWhere(
        (item) => !{
          'Full Gym',
          'Dumbbells',
          'Barbell',
          'Resistance Bands',
          'Bodyweight Only',
        }.contains(item),
      );
      final customEquipment = _otherEquipmentController.text.trim();
      if (_otherEquipmentSelected && customEquipment.isNotEmpty) {
        _equipment.add(customEquipment);
      }
    }
    MockAuthState.completeOnboardingStep(step);
    final nextRoute = switch (widget.screen) {
      OnboardingScreen.introduction => AppRoutes.onboardingFitnessGoal,
      OnboardingScreen.fitnessGoal => AppRoutes.onboardingFitnessContext,
      OnboardingScreen.fitnessContext => AppRoutes.onboardingBasicProfile,
      OnboardingScreen.basicProfile => AppRoutes.onboardingAvailableEquipment,
      OnboardingScreen.equipment => AppRoutes.onboardingFoodAvailability,
    };
    MockAuthState.setResumeRoute(nextRoute);
    Navigator.pushNamed(context, nextRoute);
  }

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
    height: 1.45,
    fontWeight: fontWeight,
  );
}
