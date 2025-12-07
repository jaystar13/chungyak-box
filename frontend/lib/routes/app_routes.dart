import 'package:chungyak_box/di/injection.dart';
import 'package:chungyak_box/presentation/screens/calculator/calculator_screen.dart';
import 'package:chungyak_box/presentation/screens/calculator/calculator_result_screen.dart';
import 'package:chungyak_box/presentation/screens/home_screen.dart';
import 'package:chungyak_box/presentation/screens/login_screen.dart';
import 'package:chungyak_box/presentation/screens/my_page_screen.dart';
import 'package:chungyak_box/presentation/screens/signup_screen.dart';
import 'package:chungyak_box/presentation/screens/terms/terms_screen.dart';
import 'package:chungyak_box/presentation/viewmodels/calculator_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Routes {
  static const String home = '/';
  static const String calculator = '/calculator';
  static const String calculatorResult = '/calculator/result';
  static const String login = '/login';
  static const String myPage = '/myPage';
  static const String terms = '/terms';
  static const String signup = '/signup';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case calculator:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<CalculatorBloc>(),
            child: const CalculatorScreen(),
          ),
        );
      case calculatorResult:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<CalculatorBloc>(),
            child: const CalculatorResultScreen(),
          ),
          settings: settings, // Forward settings to the route
        );
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case myPage:
        return MaterialPageRoute(builder: (_) => const MyPageScreen());
      case terms:
        return MaterialPageRoute(builder: (_) => const TermsScreen());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
