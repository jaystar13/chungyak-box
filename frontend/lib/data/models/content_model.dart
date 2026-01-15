class VideoMetadata {
  final String channelName;
  final String? viewCount;
  final String? duration;

  VideoMetadata({
    required this.channelName,
    this.viewCount,
    this.duration,
  });

  factory VideoMetadata.fromJson(Map<String, dynamic> json) {
    return VideoMetadata(
      channelName: json['channel_name'] as String,
      viewCount: json['view_count'] as String?,
      duration: json['duration'] as String?,
    );
  }
}

class ContentResponse {
  final List<Content> results;
  final String? nextCursor;

  ContentResponse({required this.results, this.nextCursor});

  factory ContentResponse.fromJson(Map<String, dynamic> json) {
    var list = json['items'] as List? ?? [];
    List<Content> contentList = list
        .map((i) => Content.fromJson(i as Map<String, dynamic>))
        .toList();

    return ContentResponse(
      results: contentList,
      nextCursor: json['next_cursor'] as String?,
    );
  }
}

class Content {
  final int id;
  final String title;
  final String? press;
  final String? subtitle;
  final String? thumbnailUrl;
  final String url;
  final DateTime publishedAt;
  final DateTime createdAt;
  final String contentType;
  final VideoMetadata? videoMetadata;

  Content({
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

  factory Content.fromJson(Map<String, dynamic> json) {
    final metadata = json['metadata_'] as Map<String, dynamic>?;
    final contentType = (json['content_type'] ?? json['contentType']) as String;

    return Content(
      id: json['id'] as int,
      title: json['title'] as String,
      press: (metadata?['channel_name'] ?? metadata?['publisher']) as String?,
      subtitle: metadata?['subtitle'] as String?,
      thumbnailUrl: (json['thumbnail_url'] ?? json['thumbnailUrl']) as String?,
      url: json['url'] as String,
      publishedAt: DateTime.parse(
        (json['published_at'] ?? json['publishedAt']) as String,
      ),
      createdAt: DateTime.parse(
        (json['created_at'] ?? json['createdAt']) as String,
      ),
      contentType: contentType,
      videoMetadata: contentType == 'video' && metadata != null
          ? VideoMetadata.fromJson(metadata)
          : null,
    );
  }
}