import 'package:chungyak_box/domain/entities/video_item.dart';
import 'package:chungyak_box/presentation/screens/news/widgets/video_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chungyak_box/presentation/viewmodels/news/news_bloc.dart';
import 'package:chungyak_box/presentation/viewmodels/news/news_event.dart';

// Date Utility from sample
bool isRecent(String dateString) {
  try {
    final dateParts = dateString.split('.');
    final date = DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
    );
    final diff = DateTime.now().difference(date).inDays.abs();
    return diff <= 7;
  } catch (e) {
    return false;
  }
}

class VideoListView extends StatelessWidget {
  final List<VideoItem> videoItems;
  final Set<String> viewedItemIds;

  const VideoListView({
    super.key,
    required this.videoItems,
    required this.viewedItemIds,
  });

  @override
  Widget build(BuildContext context) {
    if (videoItems.isEmpty) {
      return const Center(child: Text('영상이 없습니다.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: videoItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = videoItems[index];
        final itemId = 'video-${item.id}';
        final isViewed = viewedItemIds.contains(itemId);
        final isRecentItem = isRecent(item.date);

        return GestureDetector(
          onTap: () {
            context.read<NewsBloc>().add(MarkItemAsViewed(itemId));
            // TODO: Add navigation to video player or open URL
          },
          child: VideoListItem(
            item: item,
            isViewed: isViewed,
            isRecent: isRecentItem,
          ),
        );
      },
    );
  }
}
