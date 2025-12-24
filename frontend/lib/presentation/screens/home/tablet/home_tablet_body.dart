import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:chungyak_box/presentation/utils/design_system.dart';
import 'package:chungyak_box/routes/app_routes.dart';

class HomeTabletBody extends StatelessWidget {
  const HomeTabletBody({super.key});

  // In a real app, this data would come from a ViewModel or a service.
  static const _features = [
    {
      'title': '청약 인정금액',
      'description': '공공분양 당첨 전략의 필수 조건, 나의 청약 인정 금액을 미리 확인해보세요.',
      'image': 'assets/images/calculator.png',
      'route': Routes.calculator,
    },
    // Add more features here in the future
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(24.w),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 420.w,
        childAspectRatio: 4 / 2,
        crossAxisSpacing: 20.w,
        mainAxisSpacing: 20.w,
      ),
      itemCount: _features.length,
      itemBuilder: (context, index) {
        final feature = _features[index];
        return _HomeGridItem(
          title: feature['title']!,
          description: feature['description']!,
          imagePath: feature['image']!,
          routeName: feature['route']!,
        );
      },
    );
  }
}

class _HomeGridItem extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final String routeName;

  const _HomeGridItem({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, routeName),
        child: Row(
          children: [
            Container(
              width: 120.w,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.contain, // Prevent image cropping
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 6.h),
                          Flexible(
                            child: Text(
                              description,
                              style: AppTextStyles.caption.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                              softWrap: true,
                              maxLines: null,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: ElevatedButton(
                          style: AppButtonStyles.elevatedButtonStyle(colors),
                          onPressed: () =>
                              Navigator.pushNamed(context, Routes.calculator),
                          child: Text(
                            "계산기로 이동",
                            style: AppTextStyles.small.copyWith(
                              color: colors.onPrimary,
                            ),
                          ),
                        ),
                      ),
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
