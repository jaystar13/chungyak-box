import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chungyak_box/core/app_constants.dart';
import 'package:chungyak_box/di/injection.dart';
import 'package:chungyak_box/presentation/viewmodels/login_bloc.dart';
import 'package:chungyak_box/presentation/viewmodels/login_event.dart';
import 'package:chungyak_box/presentation/viewmodels/login_state.dart';
import 'package:chungyak_box/routes/app_routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LoginBloc>(),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.message)));
          }
          if (state is LoginSuccess) {
            // Show success message
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(const SnackBar(content: Text('로그인에 성공했습니다!')));

            // Navigate to home and remove all previous routes
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(Routes.home, (route) => false);
          }
        },
        child: const _LoginBody(),
      ),
    );
  }
}

class _LoginBody extends StatelessWidget {
  const _LoginBody();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        if (state is LoginLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.padding * 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Log in',
                textAlign: TextAlign.center,
                style: textTheme.headlineLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.padding / 2),
              Text(
                '청약계산소의 모든 기능을 사용해보세요!',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSizes.padding * 2.5),
              const _EmailInput(),
              const SizedBox(height: AppSizes.padding),
              const _PasswordInput(),
              const SizedBox(height: AppSizes.padding * 1.5),
              ElevatedButton(
                onPressed: () {
                  print('Email/Password login button pressed (TODO)');
                },
                child: const Text('로그인', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: AppSizes.padding * 2),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSizes.padding),
                    child: Text(
                      'SNS 계정으로 시작하기',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: AppSizes.padding * 2),
              _SocialLoginButton(
                assetName: 'assets/icons/google_logo.svg',
                text: 'Google 계정으로 시작하기',
                onPressed: () =>
                    context.read<LoginBloc>().add(const GoogleLoginRequested()),
              ),
              const SizedBox(height: AppSizes.padding),
              _SocialLoginButton(
                assetName: 'assets/icons/naver_logo.svg',
                text: '네이버 계정으로 시작하기',
                onPressed: () {
                  print('Naver login button pressed (TODO)');
                },
              ),
              const SizedBox(height: AppSizes.padding * 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      print('비밀번호 찾기 link pressed (TODO)');
                    },
                    child: const Text(
                      '비밀번호 찾기',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  const Text(
                    '|',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  TextButton(
                    onPressed: () {
                      print('회원가입 link pressed (TODO)');
                    },
                    child: const Text(
                      '회원가입',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmailInput extends StatelessWidget {
  const _EmailInput();

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: '이메일',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
      ),
    );
  }
}

class _PasswordInput extends StatelessWidget {
  const _PasswordInput();

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: true,
      decoration: InputDecoration(
        labelText: '비밀번호',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final String assetName;
  final String text;
  final VoidCallback onPressed;

  const _SocialLoginButton({
    required this.assetName,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: SvgPicture.asset(assetName, width: 20, height: 20),
      label: Text(text, style: const TextStyle(color: AppColors.textPrimary)),
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
    );
  }
}
