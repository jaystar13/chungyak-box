import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../data/datasources/admob_services.dart';
import '../../../../routes/app_routes.dart';
import '../../../utils/design_system.dart';
import '../../../widgets/app_drawer.dart';

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
      drawer: const AppDrawer(),
      body: GridView.builder(
        padding: EdgeInsets.all(24.w),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 400.w, // Each item can have a max width of 400
          childAspectRatio: 9 / 4, // Adjust aspect ratio to prevent vertical overflow
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
      ),
      bottomNavigationBar: const SafeArea(child: BannerAdWidget()),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          description,
                          style: AppTextStyles.caption.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            "바로가기",
                            textAlign: TextAlign.end,
                            style: AppTextStyles.small.copyWith(
                              color: colors.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12.sp,
                          color: colors.primary,
                        )
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
