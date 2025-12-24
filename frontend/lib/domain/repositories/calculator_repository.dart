import 'package:chungyak_box/domain/entities/my_subscription_entity.dart';
import 'package:chungyak_box/core/result.dart';
import 'package:chungyak_box/domain/entities/recognition_calculator_request_entity.dart';
import 'package:chungyak_box/domain/entities/recognition_calculation_result_entity.dart';

abstract class CalculatorRepository {
  Future<Result<RecognitionCalculationResultEntity>> calculateRecognition(
    RecognitionCalculatorRequestEntity requestEntity,
  );

  Future<Result<void>> saveHousingSubscriptionDetail(
    RecognitionCalculationResultEntity result,
  );

  Future<Result<MySubscriptionEntity?>> getMyHousingSubscriptionDetail();
}
