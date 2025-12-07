import 'package:chungyak_box/core/result.dart';
import 'package:chungyak_box/domain/entities/latest_terms_entity.dart';
import 'package:chungyak_box/domain/repositories/terms_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetLatestTermsUseCase {
  final TermsRepository _repository;

  GetLatestTermsUseCase(this._repository);

  Future<Result<LatestTermsEntity>> call() {
    return _repository.getLatestTerms();
  }
}
