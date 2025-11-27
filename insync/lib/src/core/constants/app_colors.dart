import 'package:flutter/material.dart';
import 'package:insync/src/core/exntesions/build_context_extension.dart';

class AppColors {
  AppColors._();

  // inSync Color Palette - Light Theme
  static const Color lightPureBlack = Color(0xFF000000);
  static const Color lightPureWhite = Color(0xFFFFFFFF);
  static const Color lightCharcoalGray = Color(0xFF2d3436);
  static const Color lightBackgroundGray = Color(0xFFf8f9fa);
  static const Color lightSuccessGreen = Color(0xFF00b894);
  static const Color lightCalmBlue = Color(0xFF74b9ff);
  static const Color lightGentlePink = Color(0xFFfd79a8);
  static const Color lightWarmOrange = Color(0xFFfdcb6e);
  static const Color lightNeutralGray = Color(0xFF636e72);
  static const Color lightSubtleGray = Color(0xFFe9ecef);
  static const Color lightSoftRed = Color(0xFFe17055);

  // inSync Color Palette - Dark Theme
  static const Color darkPureBlack = Color(0xFF000000);
  static const Color darkPureWhite = Color(0xFFFFFFFF);
  static const Color darkCharcoalGray = Color(0xFF2d3436);
  static const Color darkBackgroundGray = Color(0xFF1a1a1a);
  static const Color darkCardBackground = Color(0xFF2d3436);
  static const Color darkSuccessGreen = Color(0xFF00b894);
  static const Color darkCalmBlue = Color(0xFF74b9ff);
  static const Color darkGentlePink = Color(0xFFfd79a8);
  static const Color darkWarmOrange = Color(0xFFfdcb6e);
  static const Color darkNeutralGray = Color(0xFF636e72);
  static const Color darkSubtleGray = Color(0xFF3d3d3d);
  static const Color darkSoftRed = Color(0xFFe17055);

  // Gradient Colors
  static const Color lightGradientRedBold = Color(0xffe17055);
  static const Color lightGradientRedMedium = Color(0xfff0a08a);
  static const Color lightGradientRedRegular = Color(0xfff9dcd6);

  static const Color lightGradientOrangeBold = Color(0xfffa984e);
  static const Color lightGradientOrangeMedium = Color(0xfffcba8e);
  static const Color lightGradientOrangeRegular = Color(0xfffeeedd);

  static const Color lightGradientYellowBold = Color(0xfffdcb6e);
  static const Color lightGradientYellowMedium = Color(0xfffeda9a);
  static const Color lightGradientYellowRegular = Color(0xfffef4e2);

  static const Color lightGradientMintBold = Color(0xff6accbf);
  static const Color lightGradientMintMedium = Color(0xff9bded6);
  static const Color lightGradientMintRegular = Color(0xffdcfefb);

  static const Color lightGradientGreenBold = Color(0xff5cbfaa);
  static const Color lightGradientGreenMedium = Color(0xff8cdaca);
  static const Color lightGradientGreenRegular = Color(0xffdbf0e6);

  static const Color darkGradientRedBold = Color(0xffe17055);
  static const Color darkGradientRedMedium = Color(0xfff0a08a);
  static const Color darkGradientRedRegular = Color(0xffa16a6a);

  static const Color darkGradientOrangeBold = Color(0xfffa984e);
  static const Color darkGradientOrangeMedium = Color(0xfffcba8e);
  static const Color darkGradientOrangeRegular = Color(0xffb88c6f);

  static const Color darkGradientYellowBold = Color(0xfffdcb6e);
  static const Color darkGradientYellowMedium = Color(0xfffeda9a);
  static const Color darkGradientYellowRegular = Color(0xffbda77b);

  static const Color darkGradientMintBold = Color(0xff6accbf);
  static const Color darkGradientMintMedium = Color(0xff9bded6);
  static const Color darkGradientMintRegular = Color(0xff73a69f);

  static const Color darkGradientGreenBold = Color(0xff5cbfaa);
  static const Color darkGradientGreenMedium = Color(0xff8cdaca);
  static const Color darkGradientGreenRegular = Color(0xff6e9c8a);

  static getLightBoldGradient(int index) {
    switch (index) {
      case 0:
        return lightGradientRedBold;
      case 1:
        return lightGradientOrangeBold;
      case 2:
        return lightGradientYellowBold;
      case 3:
        return lightGradientMintBold;
      case 4:
        return lightGradientGreenBold;
      default:
        return lightGradientRedBold;
    }
  }

  static getLightMediumGradient(int index) {
    switch (index) {
      case 0:
        return lightGradientRedMedium;
      case 1:
        return lightGradientOrangeMedium;
      case 2:
        return lightGradientYellowMedium;
      case 3:
        return lightGradientMintMedium;
      case 4:
        return lightGradientGreenMedium;
      default:
        return lightGradientRedMedium;
    }
  }

  static getLightRegularGradient(int index) {
    switch (index) {
      case 0:
        return lightGradientRedRegular;
      case 1:
        return lightGradientOrangeRegular;
      case 2:
        return lightGradientYellowRegular;
      case 3:
        return lightGradientMintRegular;
      case 4:
        return lightGradientGreenRegular;
      default:
        return lightGradientRedRegular;
    }
  }

  static getDarkBoldGradient(int index) {
    switch (index) {
      case 0:
        return darkGradientRedBold;
      case 1:
        return darkGradientOrangeBold;
      case 2:
        return darkGradientYellowBold;
      case 3:
        return darkGradientMintBold;
      case 4:
        return darkGradientGreenBold;
      default:
        return darkGradientRedBold;
    }
  }

  static getDarkMediumGradient(int index) {
    switch (index) {
      case 0:
        return darkGradientRedMedium;
      case 1:
        return darkGradientOrangeMedium;
      case 2:
        return darkGradientYellowMedium;
      case 3:
        return darkGradientMintMedium;
      case 4:
        return darkGradientGreenMedium;
      default:
        return darkGradientRedMedium;
    }
  }

  static getDarkRegularGradient(int index) {
    switch (index) {
      case 0:
        return darkGradientRedRegular;
      case 1:
        return darkGradientOrangeRegular;
      case 2:
        return darkGradientYellowRegular;
      case 3:
        return darkGradientMintRegular;
      case 4:
        return darkGradientGreenRegular;
      default:
        return darkGradientRedRegular;
    }
  }

  static getBoldGradient(BuildContext context, int index) {
    final colorScheme = context.colorScheme;
    if (colorScheme.brightness == Brightness.dark) {
      return getDarkBoldGradient(index);
    }
    return getLightBoldGradient(index);
  }

  static getMediumGradient(BuildContext context, int index) {
    final colorScheme = context.colorScheme;
    if (colorScheme.brightness == Brightness.dark) {
      return getDarkMediumGradient(index);
    }
    return getLightMediumGradient(index);
  }

  static getRegularGradient(BuildContext context, int index) {
    final colorScheme = context.colorScheme;
    if (colorScheme.brightness == Brightness.dark) {
      return getDarkRegularGradient(index);
    }
    return getLightRegularGradient(index);
  }
}
