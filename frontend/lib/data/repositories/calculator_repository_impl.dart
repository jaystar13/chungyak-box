import 'package:chungyak_box/core/auth_exception.dart';
import 'package:chungyak_box/data/datasources/api_services.dart';
import 'package:chungyak_box/data/mapper/my_subscription_mapper.dart';
import 'package:chungyak_box/data/mapper/recognition_mapper.dart';
import 'package:chungyak_box/domain/entities/my_subscription_entity.dart';
import 'package:chungyak_box/core/result.dart';
import 'package:chungyak_box/domain/entities/recognition_calculator_request_entity.dart';
import 'package:chungyak_box/domain/entities/recognition_calculation_result_entity.dart';
import 'package:chungyak_box/domain/repositories/calculator_repository.dart';

import 'package:injectable/injectable.dart';

@LazySingleton(as: CalculatorRepository)
class CalculatorRepositoryImpl implements CalculatorRepository {
  final ApiServices _apiServices;

  CalculatorRepositoryImpl(this._apiServices);

  @override
  Future<Result<RecognitionCalculationResultEntity>> calculateRecognition(
    RecognitionCalculatorRequestEntity requestEntity,
  ) async {
    try {
      final requestModel = requestEntity.toModel();
      final responseModel = await _apiServices.calculateRecognition(
        requestModel,
      );
      return Success(responseModel.toEntity());
    } catch (e) {
      return Error('Failed to calculate recognition: $e');
    }
  }

  @override
  Future<Result<void>> saveHousingSubscriptionDetail(
    RecognitionCalculationResultEntity result,
  ) async {
    try {
      final requestModel = result.toModel();
      await _apiServices.saveHousingSubscriptionDetail(requestModel);
      return const Success(null);
    } on AuthException catch (_) {
      return const Error("AUTH_REQUIRED");
    } catch (e) {
      return Error('Failed to save housing subscription detail: $e');
    }
  }

  @override
  Future<Result<MySubscriptionEntity?>> getMyHousingSubscriptionDetail() async {
    try {
      final responseModel = await _apiServices.getMyHousingSubscriptionDetail();
      if (responseModel == null) {
        return const Success(null);
      }
      final responseEntitiy = responseModel.toEntity();
      return Success(responseEntitiy);
    } on AuthException catch (_) {
      return const Error("AUTH_REQUIRED");
    } catch (e) {
      return Error('Failed to get housing subscription detail: $e');
    }
  }
}
