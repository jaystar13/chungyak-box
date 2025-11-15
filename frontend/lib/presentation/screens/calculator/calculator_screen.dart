import 'package:chungyak_box/presentation/layouts/responsive_layout.dart';
import 'package:chungyak_box/presentation/screens/calculator/mobile/calculator_mobile_body.dart';
import 'package:chungyak_box/presentation/screens/calculator/tablet/calculator_tablet_body.dart';
import 'package:flutter/material.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobileBody: CalculatorMobileBody(),
      tabletBody: CalculatorTabletBody(),
    );
  }
}