import 'package:chungyak_box/core/result.dart';
import 'package:chungyak_box/domain/entities/recognition_calculation_result_entity.dart';
import 'package:chungyak_box/domain/repositories/calculator_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class SaveHousingSubscriptionDetailUseCase {
  final CalculatorRepository _repository;

  SaveHousingSubscriptionDetailUseCase(this._repository);

  Future<Result<void>> call(RecognitionCalculationResultEntity result) async {
    return await _repository.saveHousingSubscriptionDetail(result);
  }
}
