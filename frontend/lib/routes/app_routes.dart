import 'package:chungyak_box/data/datasources/admob_services.dart';
import 'package:chungyak_box/di/injection.dart';
import 'package:chungyak_box/presentation/layouts/main_layout.dart';
import 'package:chungyak_box/presentation/screens/calculator/calculator_screen.dart';
import 'package:chungyak_box/presentation/screens/calculator/calculator_result_screen.dart';
import 'package:chungyak_box/presentation/screens/home_screen.dart';
import 'package:chungyak_box/presentation/screens/login_screen.dart';
import 'package:chungyak_box/presentation/screens/my_page_screen.dart';
import 'package:chungyak_box/presentation/screens/my_subscription_screen.dart';
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
  static const String mySubscriptions = '/my-subscriptions';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => const MainLayout(
            bottomNavigationBar: SafeArea(child: BannerAdWidget()),
            child: HomeScreen(),
          ),
        );
      case calculator:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) => getIt<CalculatorBloc>(),
            child: const MainLayout(
              title: '청약 납입 계산기',
              bottomNavigationBar: SafeArea(child: BannerAdWidget()),
              child: CalculatorScreen(),
            ),
          ),
          settings: settings,
        );
      case calculatorResult:
        return MaterialPageRoute(
          builder: (_) => const MainLayout(
            title: '계산 결과',
            bottomNavigationBar: SafeArea(child: BannerAdWidget()),
            child: CalculatorResultScreen(),
          ),
          settings: settings, // Forward settings to the route
        );
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case myPage:
        return MaterialPageRoute(
          builder: (_) => const MainLayout(
            title: '마이페이지',
            bottomNavigationBar: SafeArea(child: BannerAdWidget()),
            child: MyPageScreen(),
          ),
        );
      case mySubscriptions:
        return MaterialPageRoute(
          builder: (_) => const MainLayout(
            title: '나의 청약 내역',
            bottomNavigationBar: SafeArea(child: BannerAdWidget()),
            child: MySubscriptionScreen(),
          ),
        );
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
