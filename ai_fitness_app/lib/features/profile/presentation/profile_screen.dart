import 'package:flutter/material.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import 'profile_data.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 102),
              _buildFitnessProfileCard(),
              const SizedBox(height: 26),
              _buildNavigationCard(
                title: 'Edit Profile',
                onTap: () async {
                  await Navigator.pushNamed(context, AppRoutes.editProfile);

                  if (mounted) {
                    setState(() {});
                  }
                },
              ),
              const SizedBox(height: 28),
              _buildNavigationCard(
                title: 'Settings',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.settings);
                },
              ),
              const SizedBox(height: 28),
              _buildNavigationCard(
                title: 'AI Preferences',
                onTap: () {
                  _showComingSoonMessage(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        _backButton(context),
        const SizedBox(width: 18),
        Container(
          width: 182,
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

  Widget _backButton(BuildContext context) {
    return Material(
      color: const Color(0xFFC9F6EF),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          Navigator.pop(context);
        },
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            Icons.chevron_left_rounded,
            color: AppColors.textPrimary,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildFitnessProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YOUR FITNESS PROFILE',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          _profileRow(label: 'Goal', value: ProfileData.fitnessGoal),
          const SizedBox(height: 16),
          _profileRow(label: 'Fitness Level', value: ProfileData.fitnessLevel),
          const SizedBox(height: 16),
          _profileRow(label: 'Equipment', value: ProfileData.equipment),
        ],
      ),
    );
  }

  Widget _profileRow({required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationCard({
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textPrimary,
                size: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoonMessage(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('AI Preferences will be available soon.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
