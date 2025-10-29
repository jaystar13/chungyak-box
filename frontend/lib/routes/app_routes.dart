import 'package:chungyak_box/presentation/screens/calculator_screen.dart';
import 'package:chungyak_box/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chungyak_box/di/injection.dart';
import 'package:chungyak_box/presentation/viewmodels/calculator_bloc.dart';

class Routes {
  static const String home = '/';
  static const String calculator = '/calculator';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case calculator:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<CalculatorBloc>(),
            child: const CalculatorScreen(),
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}