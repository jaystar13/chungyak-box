import 'package:chungyak_box/presentation/layouts/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:chungyak_box/data/datasources/admob_services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chungyak_box/routes/app_routes.dart';
import 'package:chungyak_box/presentation/widgets/app_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final mobileBody = Scaffold(
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
      drawer: const AppDrawer(),
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
                          onPressed: () => Navigator.pushNamed(context, Routes.calculator),
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

    final tabletBody = Scaffold(
      appBar: AppBar(
        title: const Text('Chungyak Box - Tablet'),
      ),
      body: const Center(
        child: Placeholder(),
      ),
    );

    return ResponsiveLayout(
      mobileBody: mobileBody,
      tabletBody: tabletBody,
    );
  }
}

