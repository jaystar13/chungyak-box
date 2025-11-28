import 'package:equatable/equatable.dart';
import 'package:chungyak_box/domain/entities/payment_schedule_entity.dart';
import 'package:chungyak_box/domain/entities/recognition_calculator_request_entity.dart';

abstract class CalculatorEvent extends Equatable {
  const CalculatorEvent();

  @override
  List<Object> get props => [];
}

class GenerateSchedule extends CalculatorEvent {
  final DateTime openDate;
  final int dueDay;
  final DateTime? endDate;

  const GenerateSchedule({
    required this.openDate,
    required this.dueDay,
    this.endDate,
  });

  @override
  List<Object> get props => [openDate, dueDay];
}

class RecalculateSchedule extends CalculatorEvent {
  final DateTime openDate;
  final DateTime? endDate;
  final PaymentScheduleEntity schedule;

  const RecalculateSchedule({
    required this.openDate,
    required this.endDate,
    required this.schedule,
  });

  @override
  List<Object> get props => [openDate, schedule];
}

class CalculateRecognition extends CalculatorEvent {
  final RecognitionCalculatorRequestEntity requestEntity;

  const CalculateRecognition({required this.requestEntity});

  @override
  List<Object> get props => [requestEntity];
}

class OpenDateChanged extends CalculatorEvent {
  final DateTime date;

  const OpenDateChanged(this.date);

  @override
  List<Object> get props => [date];
}

class EndDateChanged extends CalculatorEvent {
  final DateTime date;

  const EndDateChanged(this.date);

  @override
  List<Object> get props => [date];
}
