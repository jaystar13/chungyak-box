import 'package:injectable/injectable.dart';
import '../../domain/entities/latest_terms_entity.dart';
import '../models/latest_terms_model.dart';
import 'term_mapper.dart';

@injectable
class LatestTermsMapper {
  final TermMapper _termMapper;

  LatestTermsMapper(this._termMapper);

  LatestTermsEntity fromModel(LatestTermsModel model) {
    return LatestTermsEntity(
      termsOfUse: model.termsOfUse != null
          ? _termMapper.fromModel(model.termsOfUse!)
          : null,
      privacyPolicy: model.privacyPolicy != null
          ? _termMapper.fromModel(model.privacyPolicy!)
          : null,
    );
  }
}
