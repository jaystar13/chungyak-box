import 'package:flutter/material.dart';
import 'package:chungyak_box/core/responsive.dart';
import 'package:chungyak_box/ui/layout/mobile_layout.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Responsive(mobile: MobileLayout(), tablet: MobileLayout());
  }
}
