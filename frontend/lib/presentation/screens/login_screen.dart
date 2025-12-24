import 'package:chungyak_box/presentation/screens/terms/terms_screen.dart';
import 'package:chungyak_box/presentation/viewmodels/auth_bloc.dart';
import 'package:chungyak_box/presentation/viewmodels/auth_state.dart';
import 'package:chungyak_box/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chungyak_box/core/app_constants.dart';
import 'package:chungyak_box/di/injection.dart';
import 'package:chungyak_box/presentation/viewmodels/login_bloc.dart';
import 'package:chungyak_box/presentation/viewmodels/login_event.dart';
import 'package:chungyak_box/presentation/viewmodels/login_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<LoginBloc>()),
        BlocProvider.value(value: getIt<AuthBloc>()),
      ],
      child: const LoginView(),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<LoginBloc, LoginState>(
            listener: (context, state) {
              if (state is LoginFailure) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(state.message)));
              }
              if (state is LoginRequiresTermsAgreement) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<LoginBloc>(),
                      child: const TermsScreen(),
                    ),
                  ),
                );
              }
            },
          ),
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is Authenticated) {
                // Show success message
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(const SnackBar(content: Text('로그인에 성공했습니다!')));

                final args = ModalRoute.of(context)?.settings.arguments;
                if (args is Map &&
                    args.containsKey('from') &&
                    args['from'] is String) {
                  var poppedToLogin = false;
                  Navigator.of(context).popUntil((route) {
                    if (route.settings.name == Routes.login) {
                      poppedToLogin = true;
                      return true;
                    }
                    return false;
                  });
                  if (poppedToLogin) {
                    Navigator.of(context).pop(true);
                  } else {
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil(Routes.home, (route) => false);
                  }
                } else {
                  // Default navigation to home if no 'from' argument is provided
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(Routes.home, (route) => false);
                }
              }
            },
          ),
        ],
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
              _SocialLoginButton(
                assetName: 'assets/icons/google_logo.svg',
                text: 'Google 계정으로 시작하기',
                onPressed: () =>
                    context.read<LoginBloc>().add(const GoogleLoginRequested()),
              ),
              const SizedBox(height: AppSizes.padding),
              _SocialLoginButton(
                assetName: 'assets/icons/naver_icon.svg',
                text: '네이버 계정으로 시작하기',
                onPressed: () =>
                    context.read<LoginBloc>().add(const NaverLoginRequested()),
              ),
            ],
          ),
        );
      },
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
