import 'package:chungyak_box/domain/entities/term_entity.dart';
import 'package:chungyak_box/presentation/viewmodels/login_bloc.dart';
import 'package:chungyak_box/presentation/viewmodels/login_event.dart';
import 'package:chungyak_box/presentation/viewmodels/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TermsMobileBody extends StatefulWidget {
  const TermsMobileBody({super.key});

  @override
  State<TermsMobileBody> createState() => _TermsMobileBodyState();
}

class _TermsMobileBodyState extends State<TermsMobileBody> {
  bool _isAllAgreed = false;
  bool _termsOfUseAgreed = false;
  bool _privacyPolicyAgreed = false;

  void _updateAllAgreed() {
    if (_termsOfUseAgreed && _privacyPolicyAgreed) {
      if (!_isAllAgreed) {
        setState(() {
          _isAllAgreed = true;
        });
      }
    } else {
      if (_isAllAgreed) {
        setState(() {
          _isAllAgreed = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        if (state is LoginLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is LoginRequiresTermsAgreement) {
          final isButtonEnabled = _termsOfUseAgreed && _privacyPolicyAgreed;
          final theme = Theme.of(context);
          final latestTerms = state.latestTerms;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 60.h),
                Text(
                  '서비스 이용을 위해\n약관에 동의해주세요.',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 40.h),
                _buildAgreementRow(
                  isAgreed: _isAllAgreed,
                  onChanged: (value) {
                    setState(() {
                      _isAllAgreed = value!;
                      _termsOfUseAgreed = value;
                      _privacyPolicyAgreed = value;
                    });
                  },
                  text: '전체 동의',
                  isBold: true,
                ),
                const Divider(),
                SizedBox(height: 12.h),
                if (latestTerms.termsOfUse != null)
                  _buildAgreementRow(
                    isAgreed: _termsOfUseAgreed,
                    onChanged: (value) {
                      setState(() {
                        _termsOfUseAgreed = value!;
                      });
                      _updateAllAgreed();
                    },
                    text: '[필수] 서비스 이용약관',
                    onView: () {
                      _showTermDialog(context, latestTerms.termsOfUse!);
                    },
                  ),
                SizedBox(height: 12.h),
                if (latestTerms.privacyPolicy != null)
                  _buildAgreementRow(
                    isAgreed: _privacyPolicyAgreed,
                    onChanged: (value) {
                      setState(() {
                        _privacyPolicyAgreed = value!;
                      });
                      _updateAllAgreed();
                    },
                    text: '[필수] 개인정보 처리방침',
                    onView: () {
                      _showTermDialog(context, latestTerms.privacyPolicy!);
                    },
                  ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: isButtonEnabled
                        ? () {
                            final agreedIds = <String>[];
                            if (_termsOfUseAgreed && latestTerms.termsOfUse != null) {
                              agreedIds.add(latestTerms.termsOfUse!.id);
                            }
                            if (_privacyPolicyAgreed && latestTerms.privacyPolicy != null) {
                              agreedIds.add(latestTerms.privacyPolicy!.id);
                            }
                            context
                                .read<LoginBloc>()
                                .add(TermsAccepted(agreedTermsIds: agreedIds));
                          }
                        : null,
                    child: const Text('동의하고 계속하기'),
                  ),
                ),
                SizedBox(height: 40.h),
              ],
            ),
          );
        }
        return const Center(
          child: Text('약관을 불러오는 중입니다...'),
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

  Widget _buildAgreementRow({
    required bool isAgreed,
    required ValueChanged<bool?> onChanged,
    required String text,
    bool isBold = false,
    VoidCallback? onView,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Checkbox(value: isAgreed, onChanged: onChanged),
        Text(
          text,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        if (onView != null) ...[
          const Spacer(),
          TextButton(onPressed: onView, child: const Text('보기')),
        ],
      ],
    );
  }
}
