import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chungyak_box/presentation/utils/design_system.dart';
import 'package:chungyak_box/routes/app_routes.dart';

class CalculatorEntryCardTablet extends StatelessWidget {
  const CalculatorEntryCardTablet({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Image: Fixed square size
            Container(
              width: 140.h, // Slightly larger image
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
                padding: EdgeInsets.fromLTRB(
                  16.w,
                  16.h,
                  16.w,
                  12.h,
                ), // Increased padding
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
                          style: AppTextStyles.subtitle.copyWith(
                            fontSize: 20.sp,
                          ), // Larger font size
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8.h), // Increased spacing
                        Text(
                          "공공분양 당첨 전략의 필수 조건, 나의 청약 인정 금액을 미리 확인해보세요.",
                          style: AppTextStyles.caption.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: 16.sp, // Larger font size
                          ),
                        ),
                      ],
                    ),

                    // Bottom section: Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          style: AppButtonStyles.elevatedButtonStyle(colors)
                              .copyWith(
                                padding: WidgetStateProperty.all(
                                  EdgeInsets.symmetric(
                                    horizontal: 20.w,
                                    vertical: 12.h,
                                  ),
                                ), // Larger button padding
                              ),
                          onPressed: () =>
                              Navigator.pushNamed(context, Routes.calculator),
                          child: Text(
                            "계산기로 이동",
                            style: AppTextStyles.small.copyWith(
                              color: colors.onPrimary,
                              fontSize: 14.sp, // Larger font size
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
    );
  }
}
