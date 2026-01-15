import 'package:chungyak_box/core/result.dart';
import 'package:chungyak_box/data/datasources/api_services.dart';
import 'package:chungyak_box/data/mapper/content_mapper.dart';
import 'package:chungyak_box/domain/entities/content_entity.dart';
import 'package:chungyak_box/domain/repositories/content_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: ContentRepository)
class ContentRepositoryImpl implements ContentRepository {
  final ApiServices _api;
  final ContentMapper _mapper;

  ContentRepositoryImpl(this._api, this._mapper);

  @override
  Future<Result<ContentResponseEntity>> getContents({
    required String contentType,
    String? cursor,
  }) async {
    try {
      final contentResponseModel = await _api.getContents(
        contentType: contentType,
        cursor: cursor,
      );
      final contentResponseEntity = _mapper.fromResponseModel(
        contentResponseModel,
      );
      return Success(contentResponseEntity);
    } catch (e) {
      return Error('콘텐츠를 불러오는 중 오류가 발생했습니다: $e');
    }
  }
}
