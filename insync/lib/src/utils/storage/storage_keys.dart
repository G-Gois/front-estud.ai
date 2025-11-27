enum AppStorageKey {
  token,
  tokenExpiry,
  email,
  password,
  userId,
  userName,
  userAvatar,
  themeMode,
}

extension AppStorageKeyExtension on AppStorageKey {
  String get key {
    switch (this) {
      case AppStorageKey.token:
        return 'auth_token';
      case AppStorageKey.tokenExpiry:
        return 'auth_token_expiry';
      case AppStorageKey.email:
        return 'user_email';
      case AppStorageKey.password:
        return 'user_password';
      case AppStorageKey.userId:
        return 'user_id';
      case AppStorageKey.userName:
        return 'user_name';
      case AppStorageKey.userAvatar:
        return 'user_avatar';
      case AppStorageKey.themeMode:
        return 'theme_mode';
    }
  }
}
