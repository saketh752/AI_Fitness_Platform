class AuthSessionStore {
  AuthSessionStore._();

  static bool _isLoggedIn = false;
  static String? _token;
  static String? _userId;
  static String _email = '';
  static String _name = '';
  static bool _onboardingComplete = false;
  static String _resumeRoute = '/onboarding/introduction';

  static bool get isLoggedIn => _isLoggedIn;
  static String? get token => _token;
  static String? get userId => _userId;
  static String get email => _email;
  static String get name => _name;
  static bool get onboardingComplete => _onboardingComplete;
  static String get resumeRoute => _resumeRoute;

  static void saveSession({
    required String email,
    required String name,
    String? token,
    String? userId,
    bool onboardingComplete = false,
    String resumeRoute = '/onboarding/introduction',
  }) {
    _isLoggedIn = true;
    _email = email.trim();
    _name = name.trim().isEmpty ? 'Alex' : name.trim();
    _token = token;
    _userId = userId;
    _onboardingComplete = onboardingComplete;
    _resumeRoute = resumeRoute;
  }

  static void markOnboardingComplete() {
    _onboardingComplete = true;
  }

  static void setResumeRoute(String route) {
    _resumeRoute = route;
  }

  static void clearSession() {
    _isLoggedIn = false;
    _token = null;
    _userId = null;
    _email = '';
    _name = '';
    _onboardingComplete = false;
    _resumeRoute = '/onboarding/introduction';
  }
}

