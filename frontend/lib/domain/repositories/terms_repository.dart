import 'package:chungyak_box/core/result.dart';
import 'package:chungyak_box/domain/entities/latest_terms_entity.dart';

abstract class TermsRepository {
  Future<Result<LatestTermsEntity>> getLatestTerms();
}
