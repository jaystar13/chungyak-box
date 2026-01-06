import 'package:equatable/equatable.dart';
import 'package:chungyak_box/domain/entities/news_item.dart';
import 'package:chungyak_box/domain/entities/video_item.dart';

abstract class NewsState extends Equatable {
  const NewsState();

  @override
  List<Object?> get props => [];
}

class NewsInitial extends NewsState {}

class NewsLoading extends NewsState {}

class NewsLoaded extends NewsState {
  final List<NewsItem> newsItems;
  final List<VideoItem> videoItems;
  final Set<String> viewedItemIds;

  const NewsLoaded({
    this.newsItems = const [],
    this.videoItems = const [],
    this.viewedItemIds = const {},
  });

  @override
  List<Object?> get props => [newsItems, videoItems, viewedItemIds];

  NewsLoaded copyWith({
    List<NewsItem>? newsItems,
    List<VideoItem>? videoItems,
    Set<String>? viewedItemIds,
  }) {
    return NewsLoaded(
      newsItems: newsItems ?? this.newsItems,
      videoItems: videoItems ?? this.videoItems,
      viewedItemIds: viewedItemIds ?? this.viewedItemIds,
    );
  }
}

class NewsError extends NewsState {
  final String message;

  const NewsError(this.message);

  @override
  List<Object?> get props => [message];
}
