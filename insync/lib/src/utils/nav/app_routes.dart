import 'package:flutter/material.dart';
import 'package:insync/src/pages/insights_screen/insights_screen.dart';
import 'package:insync/src/pages/splash_screen/splash_screen.dart';
import 'package:insync/src/pages/welcome_screen/welcome_screen.dart';
import 'package:insync/src/pages/login_screen/login_screen.dart';
import 'package:insync/src/pages/register_screen/register_screen.dart';
import 'package:insync/src/pages/home_screen/home_screen.dart';
import 'package:insync/src/pages/habit_create_screen/habit_create_screen.dart';
import 'package:insync/src/pages/habit_list_screen/habit_list_screen.dart';
import 'package:insync/src/pages/habit_edit_screen/habit_edit_screen.dart';
import 'package:insync/src/backend/api_requests/models/api_habit_model.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String habitCreate = '/habit/create';
  static const String habitList = '/habit/list';
  static const String habitEdit = '/habit/edit';
  static const String profile = '/profile';
  static const String insights = '/insights';

  static Map<String, Widget Function(BuildContext)> routes = {
    splash: (context) => const SplashScreen(),
    welcome: (context) => const WelcomeScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    habitCreate: (context) => const HabitCreateScreen(),
    habitList: (context) => const HabitListScreen(),
    insights: (context) => const InsightsScreen(),
  };

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(
          builder: (context) => const WelcomeScreen(),
        );
      case login:
        return MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        );
      case register:
        return MaterialPageRoute(
          builder: (context) => const RegisterScreen(),
        );
      case home:
        final selectedDate = settings.arguments as DateTime?;
        return MaterialPageRoute(
          builder: (context) => HomeScreen(selectedDate: selectedDate),
        );
      case habitCreate:
        return MaterialPageRoute(
          builder: (context) => const HabitCreateScreen(),
        );
      case habitList:
        return MaterialPageRoute(
          builder: (context) => const HabitListScreen(),
        );
      case habitEdit:
        final habit = settings.arguments as ApiHabitModel;
        return MaterialPageRoute(
          builder: (context) => HabitEditScreen(habit: habit),
        );
      case insights:
        return MaterialPageRoute(
          builder: (context) => const InsightsScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => const SplashScreen(),
        );
    }
  }
}
