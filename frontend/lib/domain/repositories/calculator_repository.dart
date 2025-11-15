import 'package:chungyak_box/domain/entities/payment_schedule_entity.dart';
import 'package:chungyak_box/core/result.dart';
import 'package:chungyak_box/domain/entities/recognition_calculator_request_entity.dart';
import 'package:chungyak_box/domain/entities/recognition_calculation_result_entity.dart';

abstract class CalculatorRepository {
  Future<Result<PaymentScheduleEntity>> generatePaymentSchedule(
    DateTime openDate,
    int dueDay,
    DateTime? endDate,
  );

  Future<Result<PaymentScheduleEntity>> recalculateSchedule(
    DateTime openDate,
    DateTime? endDate,
    PaymentScheduleEntity schedule,
  );

  Future<Result<RecognitionCalculationResultEntity>> calculateRecognition(
    RecognitionCalculatorRequestEntity requestEntity,
  );
}
