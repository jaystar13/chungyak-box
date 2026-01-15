import 'package:chungyak_box/presentation/screens/video/tablet/widgets/video_list_item_tablet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chungyak_box/presentation/viewmodels/video/video_bloc.dart';
import 'package:chungyak_box/presentation/viewmodels/video/video_event.dart';
import 'package:chungyak_box/presentation/viewmodels/video/video_state.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Import flutter_screenutil

class VideoListViewTablet extends StatefulWidget {
  const VideoListViewTablet({super.key});

  @override
  State<VideoListViewTablet> createState() => _VideoListViewTabletState();
}

class _VideoListViewTabletState extends State<VideoListViewTablet> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocBuilder<VideoBloc, VideoState>(
      builder: (context, state) {
        switch (state.status) {
          case VideoStatus.initial:
            return const Center(child: CircularProgressIndicator());

          case VideoStatus.failure:
            return Center(child: Text('영상을 불러오는데 실패했습니다: ${state.errorMessage}'));

          case VideoStatus.loading:
          case VideoStatus.success:
            if (state.contents.isEmpty) {
              return const Center(child: Text('표시할 영상이 없습니다.'));
            }
            return GridView.builder( // Changed to GridView.builder
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h), // Adjusted padding
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Two columns
                crossAxisSpacing: 20.w, // Spacing between columns
                mainAxisSpacing: 20.h, // Spacing between rows
                childAspectRatio: 1.0, // Adjust aspect ratio for video items
              ),
              itemCount: state.hasReachedMax
                  ? state.contents.length
                  : state.contents.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index >= state.contents.length) {
                  return state.status == VideoStatus.loading
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : const SizedBox.shrink();
                }
                final item = state.contents[index];
                return VideoListItemTablet(item: item);
              },
            );
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<VideoBloc>().add(VideoFetched());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Trigger loading when 80% scrolled
    return currentScroll >= (maxScroll * 0.8);
  }
}
