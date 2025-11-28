import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chungyak_box/presentation/viewmodels/auth_bloc.dart';
import 'package:chungyak_box/presentation/viewmodels/auth_state.dart';
import 'package:chungyak_box/presentation/viewmodels/login_bloc.dart';
import 'package:chungyak_box/presentation/viewmodels/login_event.dart';
import 'package:chungyak_box/routes/app_routes.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          // If logged out, navigate back to home or login screen
          Navigator.of(context).pushNamedAndRemoveUntil(
            Routes.home, // Or Routes.login, depending on desired flow
            (route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('마이페이지')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('마이페이지 화면 (구현 예정)'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Dispatch SignOutRequested to LoginBloc
                  context.read<LoginBloc>().add(const SignOutRequested());
                },
                child: const Text('로그아웃'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
