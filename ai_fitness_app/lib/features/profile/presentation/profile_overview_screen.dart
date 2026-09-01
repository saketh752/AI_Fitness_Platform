import 'package:flutter/material.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../auth/domain/auth_session_store.dart';
import '../data/profile_api_service.dart';

class ProfileOverviewScreen extends StatefulWidget {
  const ProfileOverviewScreen({super.key});

  @override
  State<ProfileOverviewScreen> createState() => _ProfileOverviewScreenState();
}

class _ProfileOverviewScreenState extends State<ProfileOverviewScreen> {
  final _profileApiService = ProfileApiService();
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileApiService.getProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
        });
      }
    } catch (_) {
      // Fallback to local session
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _profile?['fullName'] ?? (AuthSessionStore.name.isNotEmpty ? AuthSessionStore.name : 'Athlete');
    final email = _profile?['email'] ?? AuthSessionStore.email;
    final goal = _profile?['fitnessGoal'] ?? 'General Fitness';
    final weight = _profile?['currentWeightKg']?.toString() ?? '--';
    final height = _profile?['heightCm']?.toString() ?? '--';
    final activity = _profile?['activityLevel'] ?? 'Moderate';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadProfile,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                Center(
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 44,
                        backgroundColor: AppColors.primaryLight,
                        child: Icon(Icons.person_rounded, size: 48, color: AppColors.primary),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildFitnessProfileCard(goal, '$weight kg', '$height cm', activity),
                const SizedBox(height: 20),
                _buildActionCard(
                  context,
                  title: 'Edit Profile',
                  icon: Icons.edit_outlined,
                  onTap: () async {
                    await Navigator.pushNamed(
                      context,
                      AppRoutes.editProfile,
                    );
                    _loadProfile();
                  },
                ),
                const SizedBox(height: 14),
                _buildActionCard(
                  context,
                  title: 'Settings',
                  icon: Icons.settings_outlined,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.settings,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Material(
          color: const Color(0xFFC9F6EF),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.chevron_left_rounded,
                color: AppColors.textPrimary,
                size: 27,
              ),
            ),
          ),
        ),
        const SizedBox(width: 18),
        Container(
          width: 140,
          height: 35,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFC9F6EF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'PROFILE',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFitnessProfileCard(String goal, String weight, String height, String activity) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YOUR FITNESS PROFILE',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 16),
          _buildProfileRow('Fitness Goal', goal),
          const Divider(height: 20),
          _buildProfileRow('Weight', weight),
          const Divider(height: 20),
          _buildProfileRow('Height', height),
          const Divider(height: 20),
          _buildProfileRow('Activity Level', activity),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.shade300,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}