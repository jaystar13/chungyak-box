import 'package:chungyak_box/core/result.dart';
import 'package:chungyak_box/domain/entities/content_entity.dart';

abstract class ContentRepository {
  Future<Result<ContentResponseEntity>> getContents({
    required String contentType,
    String? cursor,
  });
}
