import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:chungyak_box/routes/app_routes.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _goToCalculator(BuildContext context) {
    // Close the drawer first
    Navigator.pop(context);
    // Navigate to the calculator screen
    Navigator.pushNamed(context, Routes.calculator);
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
    final colors = Theme.of(context).colorScheme;

    return Drawer(
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
          ListTile(
            leading: Icon(Icons.calculate, color: colors.onSurface),
            title: Text(
              '청약 인정회차 계산기',
              style: TextStyle(color: colors.onSurface, fontSize: 16.sp),
            ),
            onTap: () => _goToCalculator(context),
          ),
          ListTile(
            leading: Icon(Icons.email, color: colors.onSurface),
            title: Text(
              '문의하기',
              style: TextStyle(color: colors.onSurface, fontSize: 16.sp),
            ),
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
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      );
                    } else {
                      return Text(
                        '버전 확인 중...',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      );
                    }
                  },
                ),
                SizedBox(height: 4.h),
                Text(
                  '© 2025 Chungyak Box',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
