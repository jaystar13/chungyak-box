import 'package:flutter/material.dart';
import 'package:chungyak_box/services/admob_services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:chungyak_box/ui/routes.dart';

class MobileLayout extends StatelessWidget {
  const MobileLayout({super.key});

  void _goToCalculator(BuildContext context) {
    Navigator.pushNamed(context, Routes.calculator);
  }

  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'rasccolii@gmail.com',
      query: 'subject=[문의사항]&body=안녕하세요, 청약 계산소 앱에 문의사항이 있어 연락드립니다.',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(Icons.menu, color: colors.onPrimaryContainer),
            );
          },
        ),
        elevation: 2,
        backgroundColor: colors.primaryContainer,
      ),
      drawer: Drawer(
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
              onTap: () {
                Navigator.pop(context);
                _goToCalculator(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.email, color: colors.onSurface),
              title: Text(
                '문의하기',
                style: TextStyle(color: colors.onSurface, fontSize: 16.sp),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _sendEmail();
              },
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
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0.w),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 150.h,
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  image: const DecorationImage(
                    image: AssetImage('assets/images/calculator.png'),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.0.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "청약 인정회차",
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "공공분양 당첨 전략의 필수",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "주택청약 인정 회차는 공공분양(일반) 당첨의 필수 조건입니다. 인정 회차 계산기를 이용하여 나의 청약 인정 회차를 미리 확인해보세요.",
                      style: TextStyle(fontSize: 14.sp, color: Colors.black54),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            padding: EdgeInsets.symmetric(
                              vertical: 12.h,
                              horizontal: 24.w,
                            ),
                          ),
                          onPressed: () => _goToCalculator(context),
                          child: Text(
                            "청약 인정회차 계산기",
                            style: TextStyle(
                              color: colors.onPrimary,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const SafeArea(child: BannerAdWidget()),
    );
  }
}
