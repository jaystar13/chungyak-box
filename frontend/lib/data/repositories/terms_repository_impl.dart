import 'dart:convert';
import 'package:chungyak_box/core/result.dart';
import 'package:chungyak_box/data/datasources/api_services.dart';
import 'package:chungyak_box/data/mapper/latest_terms_mapper.dart';
import 'package:chungyak_box/data/models/latest_terms_model.dart';
import 'package:chungyak_box/domain/entities/latest_terms_entity.dart';
import 'package:chungyak_box/domain/repositories/terms_repository.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

@LazySingleton(as: TermsRepository)
class TermsRepositoryImpl implements TermsRepository {
  final ApiServices _api;
  final LatestTermsMapper _mapper;

  TermsRepositoryImpl(this._api, this._mapper);

  @override
  Future<Result<LatestTermsEntity>> getLatestTerms() async {
    try {
      final uri = Uri.parse('${_api.baseUrl}/api/v1/terms/latest');
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final model = LatestTermsModel.fromJson(data);
        final entity = _mapper.fromModel(model);
        return Success(entity);
      } else {
        return Error('최신 약관을 불러오는데 실패했습니다. (코드: ${response.statusCode})');
      }
    } catch (e) {
      return Error('네트워크 오류가 발생했습니다: $e');
    }
  }
}
