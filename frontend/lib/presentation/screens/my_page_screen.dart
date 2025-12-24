import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chungyak_box/presentation/viewmodels/auth_bloc.dart';
import 'package:chungyak_box/presentation/viewmodels/auth_event.dart';
import 'package:chungyak_box/presentation/viewmodels/auth_state.dart';
import 'package:chungyak_box/presentation/viewmodels/login_bloc.dart';
import 'package:chungyak_box/presentation/viewmodels/login_event.dart';
import 'package:chungyak_box/routes/app_routes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import ScreenUtil

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  Future<void> _confirmSignOut(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('로그아웃'),
          content: const Text('정말 로그아웃 하시겠어요?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('로그아웃'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true && context.mounted) {
      context.read<LoginBloc>().add(const SignOutRequested());
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('회원 탈퇴'),
          content: const Text('정말 계정을 삭제하시겠어요? 모든 데이터가 영구적으로 삭제되며 복구할 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('탈퇴하기'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && context.mounted) {
      context.read<AuthBloc>().add(const DeleteAccount());
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AccountDeletionSuccess) {
          // Show success message and navigate
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('회원 탈퇴가 완료되었습니다.')),
            );
          Navigator.of(context).pushNamedAndRemoveUntil(
            Routes.home,
            (route) => false,
          );
        } else if (state is Unauthenticated) {
          // Just navigate on regular logout
          Navigator.of(context).pushNamedAndRemoveUntil(
            Routes.home,
            (route) => false,
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text('오류: ${state.message}')),
            );
        }
      },
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '내 계정', // Section header
                style: textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp, // Use ScreenUtil for font size
                ),
              ),
              SizedBox(height: 8.h), // Use ScreenUtil for height
              if (state is Authenticated)
                Text(
                  state.user.email,
                  style: textTheme.bodyMedium!.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: 14.sp,
                  ),
                )
              else
                const SizedBox.shrink(),
              SizedBox(height: 16.h), // Use ScreenUtil for height
              // "나의 청약" menu item
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.bookmark_outline,
                  color: colorScheme.onSurface,
                ),
                title: Text(
                  '나의 청약',
                  style: textTheme.bodyLarge!.copyWith(fontSize: 16.sp),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16.sp,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                onTap: () {
                  Navigator.of(context).pushNamed(Routes.mySubscriptions);
                },
              ),
              Divider(height: 1.h), // Separator
              // Redesigned "로그아웃" menu item
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.logout, color: colorScheme.error),
                title: Text(
                  '로그아웃',
                  style: textTheme.bodyLarge!.copyWith(
                    fontSize: 16.sp,
                    color: colorScheme.error,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16.sp,
                  color: colorScheme.error.withValues(alpha: 0.6),
                ),
                onTap: () => _confirmSignOut(context),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.person_off, color: colorScheme.error),
                title: Text(
                  '탈퇴하기',
                  style: textTheme.bodyLarge!.copyWith(
                    fontSize: 16.sp,
                    color: colorScheme.error,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16.sp,
                  color: colorScheme.error.withValues(alpha: 0.6),
                ),
                onTap: () => _confirmDeleteAccount(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
