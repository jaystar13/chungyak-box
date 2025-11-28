import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTextStyles {
  static final TextStyle title = TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle subtitle = TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle body = TextStyle(fontSize: 16.sp);

  static final TextStyle caption = TextStyle(fontSize: 14.sp);

  static final TextStyle small = TextStyle(fontSize: 12.sp);
}

class AppButtonStyles {
  static ButtonStyle elevatedButtonStyle(ColorScheme colors) {
    return ElevatedButton.styleFrom(
      backgroundColor: colors.primary,
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      textStyle: AppTextStyles.caption.copyWith(color: colors.onPrimary),
    );
  }
}
