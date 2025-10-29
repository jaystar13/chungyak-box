import 'package:chungyak_box/domain/entities/payment_schedule_entity.dart';
import 'package:chungyak_box/domain/repositories/calculator_repository.dart';
import 'package:chungyak_box/core/result.dart';

import 'package:injectable/injectable.dart';

@injectable
class GeneratePaymentScheduleUseCase {
  final CalculatorRepository repository;

  GeneratePaymentScheduleUseCase(this.repository);

  Future<Result<PaymentScheduleEntity>> call(
    DateTime openDate,
    int dueDay,
    DateTime? endDate,
  ) {
    return repository.generatePaymentSchedule(openDate, dueDay, endDate);
  }
}
