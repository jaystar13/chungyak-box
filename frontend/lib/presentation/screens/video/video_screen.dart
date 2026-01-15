import 'package:chungyak_box/presentation/layouts/responsive_layout.dart';
import 'package:chungyak_box/presentation/screens/video/video_screen_mobile.dart';
import 'package:chungyak_box/presentation/screens/video/tablet/video_screen_tablet.dart';
import 'package:flutter/material.dart';

class VideoScreen extends StatelessWidget {
  const VideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobileBody: VideoScreenMobile(),
      tabletBody: VideoScreenTablet(),
    );
  }
}
