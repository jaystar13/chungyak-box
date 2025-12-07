import 'package:chungyak_box/core/result.dart';
import 'package:chungyak_box/domain/entities/latest_terms_entity.dart';
import 'package:chungyak_box/domain/entities/term_entity.dart';
import 'package:chungyak_box/domain/usecases/get_latest_terms_use_case.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chungyak_box/core/app_constants.dart';
import 'package:chungyak_box/di/injection.dart';
import 'package:chungyak_box/presentation/viewmodels/signup/signup_bloc.dart';
import 'package:chungyak_box/presentation/viewmodels/signup/signup_event.dart';
import 'package:chungyak_box/presentation/viewmodels/signup/signup_state.dart';
import 'package:chungyak_box/routes/app_routes.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SignupBloc>(),
      child: const SignupView(),
    );
  }
}

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  LatestTermsEntity? _latestTerms;
  bool _termsOfUseAgreed = false;
  bool _privacyPolicyAgreed = false;

  @override
  void initState() {
    super.initState();
    _fetchLatestTerms();
  }

  Future<void> _fetchLatestTerms() async {
    final getLatestTermsUseCase = getIt<GetLatestTermsUseCase>();
    final result = await getLatestTermsUseCase();

    if (!mounted) return;

    if (result is Success<LatestTermsEntity>) {
      setState(() {
        _latestTerms = result.data;
      });
    } else if (result is Error<LatestTermsEntity>) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
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
      body: BlocListener<SignupBloc, SignupState>(
        listener: (context, state) {
          if (state is SignupFailure) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.message)));
          }
          if (state is SignupSuccess) {
            // Show success dialog
            showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  title: const Text('회원가입 성공'),
                  content: const Text('회원가입이 완료되었습니다. 로그인 페이지로 이동합니다.'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('확인'),
                      onPressed: () {
                        Navigator.of(dialogContext).pop(); // Close the dialog
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          Routes.login,
                          (route) => false,
                        );
                      },
                    ),
                  ],
                );
              },
            );
          }
        },
        child: _SigninBody(
          formKey: _formKey,
          emailController: _emailController,
          nameController: _nameController,
          passwordController: _passwordController,
          passwordConfirmController: _passwordConfirmController,
          latestTerms: _latestTerms,
          termsOfUseAgreed: _termsOfUseAgreed,
          privacyPolicyAgreed: _privacyPolicyAgreed,
          onTermsOfUseChanged: (value) {
            setState(() {
              _termsOfUseAgreed = value ?? false;
            });
          },
          onPrivacyPolicyChanged: (value) {
            setState(() {
              _privacyPolicyAgreed = value ?? false;
            });
          },
        ),
      ),
    );
  }
}

class _SigninBody extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController nameController;
  final TextEditingController passwordController;
  final TextEditingController passwordConfirmController;
  final LatestTermsEntity? latestTerms;
  final bool termsOfUseAgreed;
  final bool privacyPolicyAgreed;
  final ValueChanged<bool?> onTermsOfUseChanged;
  final ValueChanged<bool?> onPrivacyPolicyChanged;

  const _SigninBody({
    required this.formKey,
    required this.emailController,
    required this.nameController,
    required this.passwordController,
    required this.passwordConfirmController,
    required this.latestTerms,
    required this.termsOfUseAgreed,
    required this.privacyPolicyAgreed,
    required this.onTermsOfUseChanged,
    required this.onPrivacyPolicyChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<SignupBloc, SignupState>(
      builder: (context, state) {
        if (state is SignupLoading) {
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
                  '회원 가입',
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
                const SizedBox(height: AppSizes.padding * 1.5),
                _NameInput(controller: nameController),
                const SizedBox(height: AppSizes.padding * 1.5),
                _PasswordInput(controller: passwordController),
                const SizedBox(height: AppSizes.padding * 1.5),
                _PasswordConfirmInput(controller: passwordConfirmController),
                const SizedBox(height: AppSizes.padding * 1.5),
                if (latestTerms != null) _buildTermsSection(context),
                const SizedBox(height: AppSizes.padding * 1.5),
                ElevatedButton(
                  onPressed: () {
                    _onSignupButtonPressed(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                  ),
                  child: const Text('회원 가입'),
                ),
                const SizedBox(height: AppSizes.padding * 2),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTermDialog(BuildContext context, TermEntity term) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(term.version),
        content: SingleChildScrollView(child: Text(term.content)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsSection(BuildContext context) {
    if (latestTerms == null) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        CheckboxListTile(
          title: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black),
              children: [
                const TextSpan(text: '이용약관 동의 (필수) '),
                TextSpan(
                  text: '내용보기',
                  style: const TextStyle(color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      if (latestTerms!.termsOfUse != null) {
                        _showTermDialog(context, latestTerms!.termsOfUse!);
                      }
                    },
                ),
              ],
            ),
          ),
          value: termsOfUseAgreed,
          onChanged: onTermsOfUseChanged,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black),
              children: [
                const TextSpan(text: '개인정보 처리방침 동의 (필수) '),
                TextSpan(
                  text: '내용보기',
                  style: const TextStyle(color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      if (latestTerms!.privacyPolicy != null) {
                        _showTermDialog(context, latestTerms!.privacyPolicy!);
                      }
                    },
                ),
              ],
            ),
          ),
          value: privacyPolicyAgreed,
          onChanged: onPrivacyPolicyChanged,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  void _onSignupButtonPressed(BuildContext context) {
    if (formKey.currentState == null || !formKey.currentState!.validate()) {
      return;
    }

    if (!termsOfUseAgreed || !privacyPolicyAgreed) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('필수 약관에 동의해주세요.')));
      return;
    }

    if (passwordController.text != passwordConfirmController.text) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')));
      return;
    }

    final agreedTermsIds = <String>[];
    if (termsOfUseAgreed && latestTerms?.termsOfUse?.id != null) {
      agreedTermsIds.add(latestTerms!.termsOfUse!.id);
    }
    if (privacyPolicyAgreed && latestTerms?.privacyPolicy?.id != null) {
      agreedTermsIds.add(latestTerms!.privacyPolicy!.id);
    }

    context.read<SignupBloc>().add(
      SignupRequested(
        email: emailController.text,
        fullName: nameController.text,
        password: passwordController.text,
        passwordConfirm: passwordConfirmController.text,
        agreedTermsIds: agreedTermsIds,
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

class _NameInput extends StatelessWidget {
  final TextEditingController controller;
  const _NameInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: '이름(별명)',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '이름(별명)을 입력해주세요.';
        }
        if (value.length > 50) {
          return '이름(별명)은 최대 50자까지 입력할 수 있습니다.';
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
      keyboardType: TextInputType.emailAddress,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      obscureText: true,
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
        if (value.length < 8) {
          return '비밀번호는 최소 8자 이상이어야 합니다.';
        }
        return null;
      },
    );
  }
}

class _PasswordConfirmInput extends StatelessWidget {
  final TextEditingController controller;
  const _PasswordConfirmInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      obscureText: true,
      decoration: InputDecoration(
        labelText: '비밀번호 확인',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '비밀번호 확인을 입력해주세요.';
        }
        return null;
      },
    );
  }
}
