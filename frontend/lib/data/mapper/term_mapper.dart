import 'package:injectable/injectable.dart';
import '../../domain/entities/term_entity.dart';
import '../models/term_model.dart';

@injectable
class TermMapper {
  TermEntity fromModel(TermModel model) {
    return TermEntity(
      id: model.id,
      termType: model.termType,
      version: model.version,
      content: model.content,
      createdAt: model.createdAt,
    );
  }

  TermModel toModel(TermEntity entity) {
    return TermModel(
      id: entity.id,
      termType: entity.termType,
      version: entity.version,
      content: entity.content,
      createdAt: entity.createdAt,
    );
  }
}
