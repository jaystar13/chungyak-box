import 'package:flutter/material.dart';

enum DeviceType { mobile, tablet }

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;

  const Responsive({super.key, required this.mobile, this.tablet});

  static DeviceType deviceType(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width >= 800) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 800 && tablet != null) {
          return tablet!;
        } else {
          return mobile;
        }
      },
    );
  }
}
