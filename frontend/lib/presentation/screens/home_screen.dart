import 'package:chungyak_box/presentation/layouts/responsive_layout.dart';
import 'package:chungyak_box/presentation/screens/home/mobile/home_mobile_body.dart';
import 'package:chungyak_box/presentation/screens/home/tablet/home_tablet_body.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobileBody: HomeMobileBody(),
      tabletBody: HomeTabletBody(),
    );
  }
}
