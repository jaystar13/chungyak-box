import 'package:chungyak_box/presentation/screens/news/tablet/widgets/news_list_item_tablet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chungyak_box/presentation/viewmodels/news/news_bloc.dart';
import 'package:chungyak_box/presentation/viewmodels/news/news_event.dart';
import 'package:chungyak_box/presentation/viewmodels/news/news_state.dart';

class NewsListViewTablet extends StatefulWidget {
  const NewsListViewTablet({super.key});

  @override
  State<NewsListViewTablet> createState() => _NewsListViewTabletState();
}

class _NewsListViewTabletState extends State<NewsListViewTablet> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return BlocBuilder<NewsBloc, NewsState>(
      builder: (context, state) {
        switch (state.status) {
          case NewsStatus.initial:
            return const Center(child: CircularProgressIndicator());

          case NewsStatus.failure:
            return const Center(child: Text('뉴스를 불러오는데 실패했습니다.'));

          case NewsStatus.loading:
          case NewsStatus.success:
            if (state.contents.isEmpty) {
              // 로딩 중이거나, 로딩 성공 후에도 컨텐츠가 없을 경우
              return const Center(child: Text('표시할 뉴스가 없습니다.'));
            }
            return ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: state.hasReachedMax
                  ? state.contents.length
                  : state.contents.length + 1,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: colors.outline.withValues(alpha: 0.3),
              ),
              itemBuilder: (BuildContext context, int index) {
                if (index >= state.contents.length) {
                  // 로딩중이고, 최대치에 도달하지 않았으면 맨 아래에 인디케이터 표시
                  return state.status == NewsStatus.loading
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : const SizedBox.shrink();
                }
                final item = state.contents[index];
                return GestureDetector(child: NewsListItemTablet(item: item));
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
      context.read<NewsBloc>().add(NewsFetched());
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
