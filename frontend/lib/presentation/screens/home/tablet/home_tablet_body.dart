import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:chungyak_box/presentation/screens/home/widgets/calculator_entry_card_tablet.dart';
import 'package:chungyak_box/presentation/screens/home/widgets/news_entry_card_tablet.dart';

class HomeTabletBody extends StatelessWidget {
  const HomeTabletBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.0.w),
      children: [
        const CalculatorEntryCardTablet(),
        SizedBox(height: 16.h),
        const NewsEntryCardTablet(),
      ],
    );
  }
}
