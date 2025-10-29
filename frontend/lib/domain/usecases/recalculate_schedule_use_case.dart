import 'package:chungyak_box/domain/entities/payment_schedule_entity.dart';
import 'package:chungyak_box/domain/repositories/calculator_repository.dart';
import 'package:chungyak_box/core/result.dart';

import 'package:injectable/injectable.dart';

@injectable
class RecalculateScheduleUseCase {
  final CalculatorRepository repository;

  RecalculateScheduleUseCase(this.repository);

  Future<Result<PaymentScheduleEntity>> call(
    DateTime openDate,
    DateTime? endDate,
    PaymentScheduleEntity schedule,
  ) {
    return repository.recalculateSchedule(openDate, endDate, schedule);
  }
}
