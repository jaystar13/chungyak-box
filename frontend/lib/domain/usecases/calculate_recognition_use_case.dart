import 'package:chungyak_box/core/result.dart';
import 'package:chungyak_box/domain/entities/recognition_calculator_request_entity.dart';
import 'package:chungyak_box/domain/entities/recognition_calculation_result_entity.dart';
import 'package:chungyak_box/domain/repositories/calculator_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class CalculateRecognitionUseCase {
  final CalculatorRepository _repository;

  CalculateRecognitionUseCase(this._repository);

  Future<Result<RecognitionCalculationResultEntity>> call(
    RecognitionCalculatorRequestEntity requestEntity,
  ) async {
    return await _repository.calculateRecognition(requestEntity);
  }
}
