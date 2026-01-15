import 'package:chungyak_box/data/models/content_model.dart';
import 'package:chungyak_box/domain/entities/content_entity.dart';
import 'package:injectable/injectable.dart';

@injectable
class ContentMapper {
  ContentEntity fromModel(Content model) {
    return ContentEntity(
      id: model.id,
      title: model.title,
      press: model.press,
      subtitle: model.subtitle,
      thumbnailUrl: model.thumbnailUrl,
      url: model.url,
      publishedAt: model.publishedAt,
      createdAt: model.createdAt,
      contentType: model.contentType,
      videoMetadata: model.videoMetadata != null
          ? VideoMetadataEntity(
              channelName: model.videoMetadata!.channelName,
              viewCount: model.videoMetadata!.viewCount,
              duration: model.videoMetadata!.duration,
            )
          : null,
    );
  }

  ContentResponseEntity fromResponseModel(ContentResponse responseModel) {
    return ContentResponseEntity(
      results: responseModel.results.map((model) => fromModel(model)).toList(),
      nextCursor: responseModel.nextCursor,
    );
  }
}
