import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:chungyak_box/presentation/viewmodels/auth_bloc.dart';
import 'package:chungyak_box/presentation/viewmodels/auth_state.dart';
import 'package:chungyak_box/routes/app_routes.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _goTo(BuildContext context, String route) {
    Navigator.pop(context);
    Navigator.pushNamed(context, route);
  }

  void _openLogin(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    Navigator.pop(context);
    Navigator.pushNamed(
      context,
      Routes.login,
      arguments: {'from': currentRoute},
    );
  }

  Future<void> _sendEmail(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'rasccolii@gmail.com',
      query: 'subject=[문의사항]&body=안녕하세요, 청약 계산소 앱에 문의사항이 있어 연락드립니다.',
    );
    if (await canLaunchUrl(emailUri)) {
      // Close the drawer first
      Navigator.pop(context);
      await launchUrl(emailUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    // Define a breakpoint for tablet
    const tabletBreakpoint = 600;

    // Set drawer width based on screen size
    final double drawerWidth = screenWidth >= tabletBreakpoint ? 360 : 250;

    final TextStyle tileTextStyle = screenWidth >= tabletBreakpoint
        ? textTheme.titleLarge!
        : textTheme.titleMedium!;
    final double tileIconSize = 16.sp;
    final double tileLeadingWidth = 24.w;
    final double tileTitleGap = 10.w;

    return Drawer(
      width: drawerWidth,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: kToolbarHeight + MediaQuery.of(context).padding.top,
            color: colors.primaryContainer,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: MediaQuery.of(context).padding.top,
            ),
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is Authenticated) {
                return ListTile(
                  minLeadingWidth: tileLeadingWidth,
                  horizontalTitleGap: tileTitleGap,
                  leading: Icon(
                    Icons.person,
                    color: colors.onSurface,
                    size: tileIconSize,
                  ),
                  title: Text('마이페이지', style: tileTextStyle),
                  onTap: () => _goTo(context, Routes.myPage),
                );
              } else {
                return ListTile(
                  minLeadingWidth: tileLeadingWidth,
                  horizontalTitleGap: tileTitleGap,
                  leading: Icon(
                    Icons.login,
                    color: colors.onSurface,
                    size: tileIconSize,
                  ),
                  title: Text('로그인', style: tileTextStyle),
                  onTap: () => _openLogin(context),
                );
              }
            },
          ),
          ListTile(
            minLeadingWidth: tileLeadingWidth,
            horizontalTitleGap: tileTitleGap,
            leading: Icon(
              Icons.calculate,
              color: colors.onSurface,
              size: tileIconSize,
            ),
            title: Text(
              '청약 인정금액 계산기',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tileTextStyle,
            ),
            onTap: () => _goTo(context, Routes.calculator),
          ),
          ListTile(
            minLeadingWidth: tileLeadingWidth,
            horizontalTitleGap: tileTitleGap,
            leading: Icon(
              Icons.email,
              color: colors.onSurface,
              size: tileIconSize,
            ),
            title: Text('문의하기', style: tileTextStyle),
            onTap: () => _sendEmail(context),
          ),
          const Divider(),
          Padding(
            padding: EdgeInsets.all(16.0.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final info = snapshot.data!;
                      return Text(
                        '버전 ${info.version}',
                        style: tileTextStyle.copyWith(color: Colors.grey),
                      );
                    } else {
                      return Text(
                        '버전 확인 중...',
                        style: tileTextStyle.copyWith(color: Colors.grey),
                      );
                    }
                  },
                ),
                SizedBox(height: 8.h),
                Text(
                  '© 2025 Chungyak Box',
                  style: tileTextStyle.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
