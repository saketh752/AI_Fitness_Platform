import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ai_fitness_app/app/theme/app_colors.dart';

import '../../../app/routes/app_routes.dart';
import '../../auth/domain/auth_session_store.dart';

enum SplashState { loading, slowLoading, error }

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  SplashState _state = SplashState.loading;
  Timer? _timer;
  Timer? _slowLoadingTimer;

  @override
  void initState() {
    super.initState();
    _startLoadingTimer();
  }

  void _startLoadingTimer() {
    _timer?.cancel();
    _slowLoadingTimer?.cancel();

    _timer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        if (_state == SplashState.loading) {
          _state = SplashState.slowLoading;
        }
      });

      _slowLoadingTimer = Timer(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        _navigateFromSplash();
      });
    });
  }

  void _navigateFromSplash() {
    if (AuthSessionStore.isLoggedIn) {
      final targetRoute = AuthSessionStore.onboardingComplete
          ? AppRoutes.home
          : AuthSessionStore.resumeRoute;
      Navigator.pushReplacementNamed(context, targetRoute);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.welcome);
    }
  }

  void _onRetry() {
    setState(() {
      _state = SplashState.loading;
    });
    _startLoadingTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _slowLoadingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(flex: 2, child: SizedBox()),

            // Centered branding group
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildLogo(),
                const SizedBox(height: 12),
                Text(
                  'AI Fitness',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Fitness built around your real life.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),

            const Expanded(flex: 5, child: SizedBox()),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Center(child: _buildBottomArea()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.fitness_center,
          size: 32,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildBottomArea() {
    switch (_state) {
      case SplashState.loading:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                color: AppColors.primary,
              ),
            ),
          ],
        );

      case SplashState.slowLoading:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Preparing your experience...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );

      case SplashState.error:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.errorBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Unable to start the app',
                    style: TextStyle(
                      color: AppColors.errorText,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Something went wrong. Please check your connection and try again.',
                    style: TextStyle(
                      color: AppColors.errorText,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorButton,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _onRetry,
                child: const Text('Retry'),
              ),
            ),
          ],
        );
    }
  }
}