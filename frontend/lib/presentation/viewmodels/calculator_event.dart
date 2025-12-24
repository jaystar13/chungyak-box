import 'package:chungyak_box/domain/entities/recognition_calculation_result_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:chungyak_box/domain/entities/recognition_calculator_request_entity.dart';

abstract class CalculatorEvent extends Equatable {
  const CalculatorEvent();

  @override
  List<Object> get props => [];
}

class CalculateRecognition extends CalculatorEvent {
  final RecognitionCalculatorRequestEntity requestEntity;

  const CalculateRecognition({required this.requestEntity});

  @override
  List<Object> get props => [requestEntity];
}

class GenerateInitialResult extends CalculatorEvent {
  final RecognitionCalculatorRequestEntity requestEntity;

  const GenerateInitialResult({required this.requestEntity});

  @override
  List<Object> get props => [requestEntity];
}

class SaveCalculationResult extends CalculatorEvent {
  final RecognitionCalculationResultEntity result;

  const SaveCalculationResult(this.result);

  @override
  List<Object> get props => [result];
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

class CalculationStateReset extends CalculatorEvent {
  const CalculationStateReset();
}
