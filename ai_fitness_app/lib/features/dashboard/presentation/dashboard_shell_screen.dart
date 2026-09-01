import 'package:flutter/material.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../auth/domain/auth_session_store.dart';
import '../../nutrition/presentation/nutrition_overview_screen.dart';
import '../../onboarding/presentation/onboarding_state.dart';
import '../../progress/presentation/progress_overview_screen.dart';
import '../../workouts/presentation/workout_overview_screen.dart';
import '../data/dashboard_api_service.dart';
import 'ai_coach_card.dart';
import 'dashboard_data.dart';
import '../../profile/presentation/profile_overview_screen.dart';

class DashboardShellScreen extends StatefulWidget {
  const DashboardShellScreen({super.key});

  @override
  State<DashboardShellScreen> createState() => _DashboardShellScreenState();
}

class _DashboardShellScreenState extends State<DashboardShellScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final _dashboardApiService = DashboardApiService();

  late final AnimationController _entryController;
  Map<String, dynamic>? _liveData;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final data = await _dashboardApiService.getDashboardData();
      if (mounted) {
        setState(() {
          _liveData = data;
        });
      }
    } catch (_) {
      // Graceful fallback to cached state
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: _bodyForSelectedTab()),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          if (index != _selectedIndex) {
            setState(() {
              _selectedIndex = index;
            });
            if (index == 0) {
              _loadDashboardData();
            }
          }
        },
        backgroundColor: Colors.white,
        indicatorColor: Colors.transparent,
        height: 68,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.monitor_heart_outlined),
            selectedIcon: Icon(Icons.monitor_heart_rounded),
            label: 'Workouts',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu_rounded),
            label: 'Nutrition',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up_rounded),
            selectedIcon: Icon(Icons.trending_up_rounded),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _bodyForSelectedTab() {
    switch (_selectedIndex) {
      case 0:
        return _home();

      case 1:
        return const WorkoutOverviewScreen();

      case 2:
        return const NutritionOverviewScreen();

      case 3:
        return const ProgressOverviewScreen();

      case 4:
        return const ProfileOverviewScreen();

      default:
        return _home();
    }
  }

  Widget _home() {
    final userName = _liveData?['userName'] ??
        (AuthSessionStore.name.isNotEmpty
            ? AuthSessionStore.name.split(' ')[0]
            : (OnboardingData.name == 'Your name' ? 'Athlete' : OnboardingData.name));

    final greeting = _liveData?['greeting'] ?? 'Good Morning';
    final currentWorkout = _liveData?['currentWorkout'];
    final workoutName = currentWorkout?['name'] ?? DashboardData.currentWorkout;
    final workoutDuration = currentWorkout?['duration'] ?? DashboardData.workoutDuration;
    final workoutDay = currentWorkout?['workoutDay'] ?? DashboardData.workoutDay;

    final weeklyCompletion = _liveData?['weeklyCompletion'];
    final completedDays = weeklyCompletion?['completed'] ?? 3;
    final targetDays = weeklyCompletion?['target'] ?? 4;
    final weeklyPct = (weeklyCompletion?['percentage'] as num?)?.toDouble() ?? (completedDays / (targetDays > 0 ? targetDays : 1));

    final stats = _liveData?['stats'];
    final caloriesBurned = stats?['caloriesBurned'] ?? DashboardData.caloriesBurned;
    final activeMinutes = stats?['activeMinutes'] ?? DashboardData.activeMinutes;
    final streak = stats?['streak'] ?? DashboardData.streak;

    final upcomingMeal = _liveData?['upcomingMeal'];
    final mealName = upcomingMeal?['name'] ?? DashboardData.upcomingMeal;
    final mealDetails = upcomingMeal?['details'] ?? DashboardData.mealDetails;

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _reveal(0, _header(greeting, userName)),
            const SizedBox(height: 20),
            _reveal(
              1,
              AICoachCard(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.aiCoach);
                },
              ),
            ),
            const SizedBox(height: 20),
            _reveal(2, _weeklyCard(completedDays, targetDays, weeklyPct)),
            const SizedBox(height: 20),
            _reveal(
              3,
              Column(
                children: [
                  _workoutCard(workoutName, workoutDuration, workoutDay),
                  const SizedBox(height: 16),
                  _primaryButton('Start Workout', () {
                    Navigator.pushNamed(context, AppRoutes.workoutDetails);
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _reveal(
              4,
              Row(
                children: [
                  _statCard(
                    caloriesBurned,
                    'Burned',
                    Icons.local_fire_department_outlined,
                  ),
                  const SizedBox(width: 12),
                  _statCard(
                    activeMinutes,
                    'Active',
                    Icons.access_time_rounded,
                  ),
                  const SizedBox(width: 12),
                  _statCard(streak, 'Streak', Icons.bolt_rounded),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _reveal(5, _mealCard(mealName, mealDetails)),
          ],
        ),
      ),
    );
  }

  Widget _header(String greeting, String userName) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, $userName 👋',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text('Your AI-personalized program is ready', style: _body()),
            ],
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            setState(() {
              _selectedIndex = 4;
            });
          },
          child: const CircleAvatar(
            radius: 21,
            backgroundColor: AppColors.primaryLight,
            child: Icon(Icons.person_rounded, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _workoutCard(String name, String duration, String day) {
    return _card(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.workoutDetails);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _tag("TODAY'S WORKOUT"),
              Text(day, style: _body(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 18),
          Text(name, style: _title(fontSize: 21)),
          const SizedBox(height: 5),
          Text(
            '$duration · Targeted Routine · AI Form Ready',
            style: _body(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _weeklyCard(int completed, int target, double percentage) {
    return _card(
      onTap: () {
        setState(() {
          _selectedIndex = 1;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Completion',
                style: _body(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '$completed / $target days',
                style: _body(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AnimatedBuilder(
            animation: _entryController,
            builder: (context, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: (percentage * _entryController.value).clamp(0.0, 1.0),
                  minHeight: 7,
                  backgroundColor: const Color(0xFFF0F0F0),
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label, IconData icon) {
    return Expanded(
      child: _card(
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 21),
            const SizedBox(height: 6),
            Text(value, style: _title(fontSize: 16)),
            const SizedBox(height: 2),
            Text(label, style: _body(fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _mealCard(String name, String details) {
    return _card(
      onTap: () {
        setState(() {
          _selectedIndex = 2;
        });
      },
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.restaurant_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NUTRITION TARGET',
                  style: _body(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: _body(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(details, style: _body(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _reveal(int index, Widget child) {
    final start = (index * .12).clamp(0.0, .55);
    final end = (start + .45).clamp(0.0, 1.0);

    final animation = CurvedAnimation(
      parent: _entryController,
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

  Widget _card({required Widget child, VoidCallback? onTap}) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(padding: const EdgeInsets.all(18), child: child),
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: .4,
        ),
      ),
    );
  }

  Widget _primaryButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
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
