import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chungyak_box/domain/repositories/content_repository.dart';
import 'package:chungyak_box/presentation/viewmodels/video/video_event.dart';
import 'package:chungyak_box/presentation/viewmodels/video/video_state.dart';
import 'package:injectable/injectable.dart';
import 'package:chungyak_box/core/result.dart';
import 'package:chungyak_box/domain/entities/content_entity.dart';

@injectable
class VideoBloc extends Bloc<VideoEvent, VideoState> {
  final ContentRepository _contentRepository;

  VideoBloc(this._contentRepository) : super(const VideoState()) {
    on<VideoFetched>(_onVideoFetched);
  }

  Future<void> _onVideoFetched(
    VideoFetched event,
    Emitter<VideoState> emit,
  ) async {
    if (state.hasReachedMax || state.status == VideoStatus.loading) return;

    try {
      // Initial fetch
      if (state.status == VideoStatus.initial) {
        emit(state.copyWith(status: VideoStatus.loading));
        final result = await _contentRepository.getContents(
          contentType: 'video', // Changed from 'article' to 'video'
        );

        if (result is Success<ContentResponseEntity>) {
          final data = result.data;
          emit(
            state.copyWith(
              status: VideoStatus.success,
              contents: data.results,
              nextCursor: data.nextCursor,
              hasReachedMax: data.nextCursor == null,
            ),
          );
        } else if (result is Error) {
          emit(
            state.copyWith(
              status: VideoStatus.failure,
              errorMessage: (result as Error).message,
            ),
          );
        }
        return;
      }

      // Load more
      emit(state.copyWith(status: VideoStatus.loading));
      final result = await _contentRepository.getContents(
        contentType: 'video', // Changed from 'article' to 'video'
        cursor: state.nextCursor,
      );

      if (result is Success<ContentResponseEntity>) {
        final data = result.data;
        emit(
          state.copyWith(
            status: VideoStatus.success,
            contents: List.of(state.contents)..addAll(data.results),
            nextCursor: data.nextCursor,
            hasReachedMax: data.nextCursor == null,
          ),
        );
      } else if (result is Error) {
        emit(
          state.copyWith(
            status: VideoStatus.failure,
            errorMessage: (result as Error).message,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: VideoStatus.failure,
          errorMessage: '알 수 없는 오류가 발생했습니다.',
        ),
      );
    }
  }
}
