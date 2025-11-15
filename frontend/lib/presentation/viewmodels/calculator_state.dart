import 'package:equatable/equatable.dart';
import 'package:chungyak_box/domain/entities/payment_schedule_entity.dart';
import 'package:chungyak_box/domain/entities/recognition_calculation_result_entity.dart';

abstract class CalculatorState extends Equatable {
  final DateTime? openDate;
  final DateTime? endDate;

  const CalculatorState({this.openDate, this.endDate});

  @override
  List<Object?> get props => [openDate, endDate];
}

class CalculatorInitial extends CalculatorState {
  const CalculatorInitial({super.openDate, super.endDate});
}

class CalculatorLoading extends CalculatorState {
  const CalculatorLoading({super.openDate, super.endDate});
}

class CalculatorLoaded extends CalculatorState {
  final PaymentScheduleEntity schedule;

  const CalculatorLoaded(this.schedule, {super.openDate, super.endDate});

  @override
  List<Object?> get props => [schedule, openDate, endDate];
}

class RecognitionCalculated extends CalculatorState {
  final RecognitionCalculationResultEntity result;

  const RecognitionCalculated(this.result, {super.openDate, super.endDate});

  @override
  List<Object?> get props => [result, openDate, endDate];
}

class CalculatorError extends CalculatorState {
  final String message;

  const CalculatorError(this.message, {super.openDate, super.endDate});

  @override
  List<Object?> get props => [message, openDate, endDate];
}
