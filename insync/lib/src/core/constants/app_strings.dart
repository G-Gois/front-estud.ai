class AppStrings {
  AppStrings._();

  static const app = _AppStrings();
  static const welcome = _WelcomeStrings();
  static const login = _LoginStrings();
  static const home = _HomeStrings();
  static const profile = _ProfileStrings();
  static const error = _ErrorStrings();
}

class _AppStrings {
  const _AppStrings();

  String get appName => 'InSync';
  String get loading => 'Loading...';
  String get cancel => 'Cancel';
  String get confirm => 'Confirm';
  String get save => 'Save';
  String get delete => 'Delete';
  String get edit => 'Edit';
  String get ok => 'OK';
  String get yes => 'Yes';
  String get no => 'No';
}

class _WelcomeStrings {
  const _WelcomeStrings();

  String get title => 'Welcome to InSync';
  String get subtitle => 'Sync and manage everything in one place';
  String get getStarted => 'Get Started';
  String get login => 'Login';
  String get register => 'Register';
}

class _LoginStrings {
  const _LoginStrings();

  String get title => 'Login';
  String get subtitle => 'Access your account';
  String get email => 'Email';
  String get emailHint => 'your@email.com';
  String get password => 'Password';
  String get passwordHint => '********';
  String get forgotPassword => 'Forgot my password';
  String get loginButton => 'Login';
  String get noAccount => 'Don\'t have an account?';
  String get signUp => 'Sign Up';
}

class _HomeStrings {
  const _HomeStrings();

  String get title => 'Home';
  String get welcome => 'Welcome';
  String get recentActivity => 'Recent Activity';
  String get viewAll => 'View All';
}

class _ProfileStrings {
  const _ProfileStrings();

  String get title => 'Profile';
  String get editProfile => 'Edit Profile';
  String get settings => 'Settings';
  String get logout => 'Logout';
  String get logoutConfirmation => 'Are you sure you want to logout?';
}

class _ErrorStrings {
  const _ErrorStrings();

  String get generic => 'An error occurred. Please try again.';
  String get network => 'Connection error. Check your internet.';
  String get unauthorized => 'Unauthorized. Please login again.';
  String get notFound => 'Resource not found.';
  String get serverError => 'Server error. Please try again later.';
}
