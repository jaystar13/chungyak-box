import 'package:chungyak_box/di/injection.dart';
import 'package:chungyak_box/presentation/screens/video/tablet/widgets/video_list_view_tablet.dart';
import 'package:chungyak_box/presentation/viewmodels/video/video_bloc.dart';
import 'package:chungyak_box/presentation/viewmodels/video/video_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VideoScreenTablet extends StatelessWidget {
  const VideoScreenTablet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<VideoBloc>()..add(VideoFetched()),
      child: const VideoListViewTablet(),
    );
  }
}
