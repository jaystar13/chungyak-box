import 'package:chungyak_box/presentation/layouts/responsive_layout.dart';
import 'package:chungyak_box/presentation/screens/calculator/mobile/calculator_result_mobile_body.dart';
import 'package:chungyak_box/presentation/screens/calculator/tablet/calculator_result_tablet_body.dart';
import 'package:flutter/material.dart';

class CalculatorResultScreen extends StatelessWidget {
  const CalculatorResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobileBody: CalculatorResultMobileBody(),
      tabletBody: CalculatorResultTabletBody(),
    );
  }
}