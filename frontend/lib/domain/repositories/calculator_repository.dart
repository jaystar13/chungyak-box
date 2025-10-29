import 'package:chungyak_box/domain/entities/payment_schedule_entity.dart';
import 'package:chungyak_box/core/result.dart';

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
}
