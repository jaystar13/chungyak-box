import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:chungyak_box/presentation/utils/design_system.dart';
import 'package:chungyak_box/routes/app_routes.dart';

class HomeMobileBody extends StatelessWidget {
  const HomeMobileBody({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListView(
      padding: EdgeInsets.all(16.0.w),
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 1,
          clipBehavior: Clip.antiAlias,
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Image: Fixed square size
                Container(
                  width: 120.h,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/calculator.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Text content: Fills the remaining space
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 8.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween, // 상단과 하단에 요소를 배치
                      children: [
                        // Top section: Title and description
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "청약 인정금액",
                              style: AppTextStyles.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              "공공분양 당첨 전략의 필수 조건, 나의 청약 인정 금액을 미리 확인해보세요.",
                              style: AppTextStyles.caption.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),

                        // Bottom section: Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              style: AppButtonStyles.elevatedButtonStyle(
                                colors,
                              ),
                              onPressed: () => Navigator.pushNamed(
                                context,
                                Routes.calculator,
                              ),
                              child: Text(
                                "계산기로 이동",
                                style: AppTextStyles.small.copyWith(
                                  color: colors.onPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16.h),
        // News Entry Card
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, Routes.news),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            elevation: 1,
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Container(
                    width: 48.h,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.newspaper, color: colors.primary),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("부동산 청약 뉴스", style: AppTextStyles.subtitle),
                        SizedBox(height: 4.h),
                        Text(
                          "공공분양 소식을 확인하세요",
                          style: AppTextStyles.caption.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16.sp,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
