import 'package:flutter/material.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../auth/domain/auth_session_store.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
              const SizedBox(height: 18),
              _sectionTitle('APP'),
              _settingItem(
                title: 'Notifications',
                onTap: () {
                  _showComingSoon(context);
                },
              ),
              _settingItem(
                title: 'Workout Reminders',
                onTap: () {
                  _showComingSoon(context);
                },
              ),
              _settingItem(
                title: 'Units',
                onTap: () {
                  _showComingSoon(context);
                },
              ),
              const SizedBox(height: 22),
              _sectionTitle('AI & PERSONALIZATION'),
              _settingItem(
                title: 'AI Preferences',
                onTap: () {
                  _showComingSoon(context);
                },
              ),
              _settingItem(
                title: 'Personalized Plans',
                onTap: () {
                  _showComingSoon(context);
                },
              ),
              const SizedBox(height: 22),
              _sectionTitle('PRIVACY & DATA'),
              _settingItem(
                title: 'Privacy',
                onTap: () {
                  _showComingSoon(context);
                },
              ),
              _settingItem(
                title: 'Data & Storage',
                onTap: () {
                  _showComingSoon(context);
                },
              ),
              const SizedBox(height: 22),
              _sectionTitle('ACCOUNT'),
              const SizedBox(height: 6),
              _buildLogoutButton(context),
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
            'Settings',
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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _settingItem({required String title, required VoidCallback onTap}) {
    return SizedBox(
      height: 41,
      child: Material(
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
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

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 42,
      child: ElevatedButton(
        onPressed: () {
          _showLogoutConfirmation(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF3B40),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        child: const Text(
          'Logout',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Logout?',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                AuthSessionStore.clearSession();
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text('Logged out successfully'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.welcome,
                  (route) => false,
                );
              },
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Color(0xFFFF3B40),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showComingSoon(
    BuildContext context, {
    String message = 'This setting will be available soon.',
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }
}
