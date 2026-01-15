import 'package:equatable/equatable.dart';

class VideoMetadataEntity extends Equatable {
  final String channelName;
  final String? viewCount;
  final String? duration;

  const VideoMetadataEntity({
    required this.channelName,
    this.viewCount,
    this.duration,
  });

  @override
  List<Object?> get props => [channelName, viewCount, duration];
}

class ContentResponseEntity extends Equatable {
  final List<ContentEntity> results;
  final String? nextCursor;

  const ContentResponseEntity({required this.results, this.nextCursor});

  @override
  List<Object?> get props => [results, nextCursor];
}

class ContentEntity extends Equatable {
  final int id;
  final String title;
  final String? press;
  final String? subtitle;
  final String? thumbnailUrl;
  final String url;
  final DateTime publishedAt;
  final DateTime createdAt;
  final String contentType;
  final VideoMetadataEntity? videoMetadata;

  const ContentEntity({
    required this.id,
    required this.title,
    this.press,
    this.subtitle,
    this.thumbnailUrl,
    required this.url,
    required this.publishedAt,
    required this.createdAt,
    required this.contentType,
    this.videoMetadata,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        press,
        subtitle,
        thumbnailUrl,
        url,
        publishedAt,
        createdAt,
        contentType,
        videoMetadata,
      ];
}