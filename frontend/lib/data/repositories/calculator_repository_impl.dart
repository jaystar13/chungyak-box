import 'package:chungyak_box/data/datasources/api_services.dart';
import 'package:chungyak_box/data/mapper/payment_mapper.dart';
import 'package:chungyak_box/data/mapper/recognition_mapper.dart';
import 'package:chungyak_box/data/models/calculator_request_model.dart';
import 'package:chungyak_box/data/models/payment_schedule_request_model.dart';
import 'package:chungyak_box/domain/entities/payment_schedule_entity.dart';
import 'package:chungyak_box/core/result.dart';
import 'package:chungyak_box/domain/entities/recognition_calculator_request_entity.dart';
import 'package:chungyak_box/domain/entities/recognition_calculation_result_entity.dart';
import 'package:chungyak_box/domain/repositories/calculator_repository.dart';

import 'package:injectable/injectable.dart';

@LazySingleton(as: CalculatorRepository)
class CalculatorRepositoryImpl implements CalculatorRepository {
  final ApiServices _apiServices;

  CalculatorRepositoryImpl(this._apiServices);

  String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  Future<Result<PaymentScheduleEntity>> generatePaymentSchedule(
    DateTime openDate,
    int dueDay,
    DateTime? endDate,
  ) async {
    try {
      final request = CalculatorRequestModel(
        openDate: _formatDate(openDate),
        dueDay: dueDay,
        endDate: _formatDate(endDate ?? DateTime.now()),
      );
      final response = await _apiServices.generatePaymentSchedule(request);
      return Success(response.toEntity());
    } catch (e) {
      return Error('Failed to generate payment schedule: $e');
    }
  }

  @override
  Future<Result<PaymentScheduleEntity>> recalculateSchedule(
    DateTime openDate,
    DateTime? endDate,
    PaymentScheduleEntity schedule,
  ) async {
    try {
      final request = PaymentScheduleRequestModel(
        openDate: _formatDate(openDate),
        endDate: _formatDate(endDate ?? DateTime.now()),
        payments: schedule.payments.map((e) => e.toModel()).toList(),
      );
      final response = await _apiServices.recalculateSchedule(request);
      return Success(response.toEntity());
    } catch (e) {
      return Error('Failed to recalculate schedule: $e');
    }
  }

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
}
