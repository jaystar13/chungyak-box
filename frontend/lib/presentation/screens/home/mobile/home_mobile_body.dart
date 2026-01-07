import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:chungyak_box/presentation/screens/home/widgets/calculator_entry_card.dart';
import 'package:chungyak_box/presentation/screens/home/widgets/news_entry_card.dart';

class HomeMobileBody extends StatelessWidget {
  const HomeMobileBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.0.w),
      children: [
        const CalculatorEntryCard(),
        SizedBox(height: 16.h),
        const NewsEntryCard(),
      ],
    );
  }
}
