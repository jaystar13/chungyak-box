import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:chungyak_box/data/datasources/mock_news_data.dart';
import 'news_event.dart';
import 'news_state.dart';

@injectable
class NewsBloc extends Bloc<NewsEvent, NewsState> {
  // In the future, a repository will be injected here.
  // final NewsRepository _newsRepository;

  NewsBloc() : super(NewsInitial()) {
    on<LoadNews>(_onLoadNews);
    on<MarkItemAsViewed>(_onMarkItemAsViewed);
  }

  Future<void> _onLoadNews(
    LoadNews event,
    Emitter<NewsState> emit,
  ) async {
    emit(NewsLoading());
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // For now, load directly from mock data.
      final newsItems = kNewsItems;
      final videoItems = kVideoItems;
      
      // In the future, this would be:
      // final newsItems = await _newsRepository.getNewsItems();
      // final videoItems = await _newsRepository.getVideoItems();

      emit(NewsLoaded(
        newsItems: newsItems,
        videoItems: videoItems,
        viewedItemIds: const {}, // Initially, no items are viewed
      ));
    } catch (e) {
      emit(NewsError(e.toString()));
    }
  }

  void _onMarkItemAsViewed(
    MarkItemAsViewed event,
    Emitter<NewsState> emit,
  ) {
    if (state is NewsLoaded) {
      final currentState = state as NewsLoaded;
      
      // Create a new set with the added item ID
      final updatedViewedIds = Set<String>.from(currentState.viewedItemIds)..add(event.itemId);

      emit(currentState.copyWith(
        viewedItemIds: updatedViewedIds,
      ));
    }
  }
}