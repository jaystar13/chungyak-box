import 'package:chungyak_box/presentation/screens/terms/terms_screen.dart';
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

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
        child: _LoginBody(
          formKey: _formKey,
          emailController: _emailController,
          passwordController: _passwordController,
        ),
      ),
    );
  }
}

class _LoginBody extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const _LoginBody({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        if (state is LoginLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return Form(
          key: formKey,
          child: SingleChildScrollView(
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
                _EmailInput(controller: emailController),
                const SizedBox(height: AppSizes.padding),
                _PasswordInput(controller: passwordController),
                const SizedBox(height: AppSizes.padding * 1.5),
                ElevatedButton(
                  onPressed: () => _onLoginButtonPressed(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                  ),
                  child: const Text('로그인'),
                ),
                const SizedBox(height: AppSizes.padding * 2),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.padding,
                      ),
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
                  onPressed: () => context.read<LoginBloc>().add(
                    const GoogleLoginRequested(),
                  ),
                ),
                const SizedBox(height: AppSizes.padding),
                _SocialLoginButton(
                  assetName: 'assets/icons/naver_icon.svg',
                  text: '네이버 계정으로 시작하기',
                  onPressed: () => context.read<LoginBloc>().add(
                    const NaverLoginRequested(),
                  ),
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
                        Navigator.of(context).pushNamed(Routes.signup);
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
          ),
        );
      },
    );
  }

  void _onLoginButtonPressed(BuildContext context) {
    if (formKey.currentState == null || !formKey.currentState!.validate()) {
      return;
    }

    context.read<LoginBloc>().add(
      EmailPasswordLoginRequested(
        email: emailController.text,
        password: passwordController.text,
      ),
    );
  }
}

class _EmailInput extends StatelessWidget {
  final TextEditingController controller;

  const _EmailInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: '이메일',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '이메일을 입력해주세요.';
        }
        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
        if (!emailRegex.hasMatch(value)) {
          return '올바른 이메일 형식이 아닙니다.';
        }
        return null;
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  final TextEditingController controller;

  const _PasswordInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: '비밀번호',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '비밀번호를 입력해주세요.';
        }
        return null;
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
