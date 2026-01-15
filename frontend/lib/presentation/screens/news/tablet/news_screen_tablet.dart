import 'package:chungyak_box/di/injection.dart';
import 'package:chungyak_box/presentation/screens/news/tablet/widgets/news_list_view_tablet.dart';
import 'package:chungyak_box/presentation/screens/video/tablet/video_screen_tablet.dart';
import 'package:chungyak_box/presentation/viewmodels/news/news_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:chungyak_box/presentation/viewmodels/news/news_event.dart';

class NewsScreenTablet extends StatefulWidget {
  const NewsScreenTablet({super.key});

  @override
  State<NewsScreenTablet> createState() => _NewsScreenTabletState();
}

class _NewsScreenTabletState extends State<NewsScreenTablet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "청약 인사이트",
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "공공분양 특화",
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Custom Tab Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: colors.secondaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            labelColor: colors.onSurface,
            unselectedLabelColor: colors.onSurface.withValues(alpha: 0.7),
            labelStyle: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: "뉴스"),
              Tab(text: "영상"),
            ],
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.tab,
          ),
        ),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              BlocProvider(
                create: (context) => getIt<NewsBloc>()..add(NewsFetched()),
                child: const NewsListViewTablet(),
              ),
              const VideoScreenTablet(),
            ],
          ),
        ),
      ],
    );
  }
}
