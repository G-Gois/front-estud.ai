class AppAssets {
  const AppAssets._();

  // Base paths
  static const String _baseSvg = 'assets/svg';
  static const String _basePng = 'assets/png';
  static const String _baseLottie = 'assets/lottie';
  static const String _baseIcon = 'assets/icon';

  // SVG Icons
  static const String iconLogo = '$_baseSvg/logo.svg';

  // PNG Images
  static const String imagePlaceholder = '$_basePng/placeholder.png';

  // Lottie Animations
  static const String lottieLoading = '$_baseLottie/loading.json';
  static const String lottieSuccess = '$_baseLottie/success.json';
  static const String lottieError = '$_baseLottie/error.json';
  static const String lottieEmpty = '$_baseLottie/empty.json';

  // App Icons
  static const String appIcon = '$_baseIcon/icon.png';
}
