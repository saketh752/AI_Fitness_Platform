import '../domain/auth_session_store.dart';

class MockAuthState {
  MockAuthState._();

  static String _email = 'alex@example.com';
  static int _passwordHash = _hash('Password1');
  static String _name = 'Alex';
  static int _onboardingStep = 0;
  static bool _onboardingComplete = false;
  static String _resumeRoute = '/onboarding/introduction';

  static bool isRegisteredEmail(String email) {
    return email.trim().toLowerCase() == _email.toLowerCase();
  }

  static bool register({
    required String email,
    required String password,
    String name = 'Alex',
  }) {
    if (isRegisteredEmail(email)) return false;
    _email = email.trim();
    _passwordHash = _hash(password);
    _name = name.trim().isEmpty ? 'Alex' : name.trim();
    _onboardingStep = 0;
    _onboardingComplete = false;
    _resumeRoute = '/onboarding/introduction';

    AuthSessionStore.saveSession(
      email: _email,
      name: _name,
      token: 'jwt_mock_token_${DateTime.now().millisecondsSinceEpoch}',
      onboardingComplete: false,
      resumeRoute: _resumeRoute,
    );

    return true;
  }

  static bool login({
    required String email,
    required String password,
  }) {
    if (!matchesEmail(email) || !matchesPassword(password)) {
      return false;
    }

    AuthSessionStore.saveSession(
      email: _email,
      name: _name,
      token: 'jwt_mock_token_${DateTime.now().millisecondsSinceEpoch}',
      onboardingComplete: _onboardingComplete,
      resumeRoute: onboardingRoute,
    );
    return true;
  }

  static bool resetPassword({
    required String email,
    required String newPassword,
  }) {
    if (!matchesEmail(email)) return false;
    _passwordHash = _hash(newPassword);
    return true;
  }

  static bool matchesEmail(String email) {
    return email.trim().toLowerCase() == _email.toLowerCase();
  }

  static bool matchesPassword(String password) {
    return _hash(password) == _passwordHash;
  }

  static String get email => _email;

  static String get name => _name;

  static bool get onboardingComplete => _onboardingComplete;

  static String get onboardingRoute {
    if (_onboardingStep >= 5) return _resumeRoute;
    const routes = [
      '/onboarding/introduction',
      '/onboarding/fitness-goal',
      '/onboarding/fitness-context',
      '/onboarding/basic-profile',
      '/onboarding/available-equipment',
    ];
    final step = _onboardingStep < routes.length
        ? _onboardingStep
        : routes.length - 1;
    return routes[step];
  }

  static void completeOnboardingStep(int completedStep) {
    _onboardingStep = completedStep + 1;
  }

  static void markOnboardingComplete() {
    _onboardingComplete = true;
    _onboardingStep = 5;
    AuthSessionStore.markOnboardingComplete();
  }

  static void setResumeRoute(String route) {
    _resumeRoute = route;
    AuthSessionStore.setResumeRoute(route);
  }

  static void logout() {
    AuthSessionStore.clearSession();
  }

  static int _hash(String value) {
    var hash = 17;
    for (final character in value.codeUnits) {
      hash = 31 * hash + character;
    }
    return hash;
  }
}
