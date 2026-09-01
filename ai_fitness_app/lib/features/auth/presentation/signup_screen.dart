import 'package:flutter/material.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../data/auth_api_service.dart';
import 'mock_auth_state.dart';
import '../../onboarding/presentation/onboarding_state.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authApiService = AuthApiService();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _showDuplicateEmailError = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _returnToWelcome();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () => Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  AppRoutes.welcome,
                                  (route) => false,
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: AppColors.textPrimary,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Create your account',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 38,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Let's start building a fitness plan around you.",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 26),
                        _buildField(
                          label: 'Full Name',
                          controller: _fullNameController,
                          hintText: 'Alex Carter',
                          obscureText: false,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Full name is required'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'Email',
                          controller: _emailController,
                          hintText: 'alex@example.com',
                          obscureText: false,
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                          onChanged: (_) {
                            if (_showDuplicateEmailError) {
                              setState(() => _showDuplicateEmailError = false);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'Password',
                          controller: _passwordController,
                          hintText: '.......',
                          obscureText: !_passwordVisible,
                          validator: _validatePassword,
                          suffixIcon: IconButton(
                            splashRadius: 18,
                            onPressed: () => setState(
                              () => _passwordVisible = !_passwordVisible,
                            ),
                            icon: Icon(
                              _passwordVisible
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: AppColors.textSecondary,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'Confirm Password',
                          controller: _confirmPasswordController,
                          hintText: '.......',
                          obscureText: !_confirmPasswordVisible,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Confirm password is required';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                          suffixIcon: IconButton(
                            splashRadius: 18,
                            onPressed: () => setState(
                              () => _confirmPasswordVisible =
                                  !_confirmPasswordVisible,
                            ),
                            icon: Icon(
                              _confirmPasswordVisible
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: AppColors.textSecondary,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _createAccount,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Create Account',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 180),
                          child: _errorMessage == null
                              ? const SizedBox.shrink()
                              : Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color: AppColors.errorText,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 22),
                        Center(
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 15,
                                height: 1.4,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Already have an account? ',
                                ),
                                WidgetSpan(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.login,
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                        vertical: 2,
                                      ),
                                      child: Text(
                                        'Log In',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _returnToWelcome() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.welcome,
      (route) => false,
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.topCenter,
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
            decoration: InputDecoration(
              isDense: true,
              hintText: hintText,
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.7),
                fontSize: 15,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 15,
              ),
              suffixIcon: suffixIcon,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1.2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.primary, width: 1.2),
              ),
              errorStyle: TextStyle(
                color: AppColors.errorText,
                fontSize: 11,
                height: 1.2,
              ),
              errorMaxLines: 3,
            ),
            validator: validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailPattern.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    if (_showDuplicateEmailError && MockAuthState.isRegisteredEmail(value)) {
      return 'This email is already registered. Please log in.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    final isStrong =
        value.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(value) &&
        RegExp(r'[a-z]').hasMatch(value) &&
        RegExp(r'\d').hasMatch(value);
    return isStrong
        ? null
        : 'Password must be at least 8 characters and include uppercase, lowercase, and a number.';
  }

  Future<void> _createAccount() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _showDuplicateEmailError = false;
      _errorMessage = null;
    });

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      await _authApiService.signup(
        fullName: _fullNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      OnboardingData.reset();
      OnboardingData.name = _fullNameController.text.trim();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Account created successfully! Let\'s personalize your plan.',
            ),
          ),
        );

      Navigator.pushNamed(context, AppRoutes.onboardingIntroduction);
    } catch (e) {
      if (!mounted) return;
      final err = e.toString();
      if (err.toLowerCase().contains('email already in use') ||
          err.toLowerCase().contains('already registered')) {
        setState(() => _showDuplicateEmailError = true);
        _formKey.currentState?.validate();
      } else {
        setState(() => _errorMessage = err);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
