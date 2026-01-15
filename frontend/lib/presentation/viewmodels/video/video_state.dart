import 'package:equatable/equatable.dart';
import 'package:chungyak_box/domain/entities/content_entity.dart';

enum VideoStatus { initial, loading, success, failure }

class _Undefined {
  const _Undefined();
}

class VideoState extends Equatable {
  final VideoStatus status;
  final List<ContentEntity> contents;
  final String? nextCursor;
  final bool hasReachedMax;
  final String errorMessage;

  const VideoState({
    this.status = VideoStatus.initial,
    this.contents = const <ContentEntity>[],
    this.nextCursor,
    this.hasReachedMax = false,
    this.errorMessage = '',
  });

  VideoState copyWith({
    VideoStatus? status,
    List<ContentEntity>? contents,
    Object? nextCursor = const _Undefined(),
    bool? hasReachedMax,
    String? errorMessage,
  }) {
    return VideoState(
      status: status ?? this.status,
      contents: contents ?? this.contents,
      nextCursor:
          nextCursor is _Undefined ? this.nextCursor : nextCursor as String?,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, contents, nextCursor, hasReachedMax, errorMessage];
}
