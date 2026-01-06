import 'package:chungyak_box/domain/entities/news_item.dart';
import 'package:chungyak_box/presentation/screens/news/widgets/news_list_item.dart';
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

class NewsListView extends StatelessWidget {
  final List<NewsItem> newsItems;
  final Set<String> viewedItemIds;

  const NewsListView({
    super.key,
    required this.newsItems,
    required this.viewedItemIds,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (newsItems.isEmpty) {
      return const Center(child: Text('뉴스가 없습니다.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: newsItems.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: colors.outline.withOpacity(0.3),
      ),
      itemBuilder: (context, index) {
        final item = newsItems[index];
        final itemId = 'news-${item.id}';
        final isViewed = viewedItemIds.contains(itemId);
        final isRecentItem = isRecent(item.date);

        return GestureDetector(
          onTap: () {
            context.read<NewsBloc>().add(MarkItemAsViewed(itemId));
            // TODO: Add navigation to news detail screen or open URL
          },
          child: NewsListItem(
            item: item,
            isViewed: isViewed,
            isRecent: isRecentItem,
          ),
        );
      },
    );
  }
}
