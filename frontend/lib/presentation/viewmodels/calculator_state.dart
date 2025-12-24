import 'package:equatable/equatable.dart';
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

class CalculatorSaving extends CalculatorState {
  const CalculatorSaving({super.openDate, super.endDate});
}

class CalculatorSaveSuccess extends CalculatorState {
  const CalculatorSaveSuccess({super.openDate, super.endDate});
}

class CalculatorSaveError extends CalculatorState {
  final String message;

  const CalculatorSaveError(this.message, {super.openDate, super.endDate});

  @override
  List<Object?> get props => [message, openDate, endDate];
}

class RecognitionCalculated extends CalculatorState {
  final RecognitionCalculationResultEntity result;

  const RecognitionCalculated(this.result, {super.openDate, super.endDate});

  @override
  List<Object?> get props => [result, openDate, endDate];
}

class InitialCalculationSuccess extends CalculatorState {
  final RecognitionCalculationResultEntity result;

  const InitialCalculationSuccess(this.result, {super.openDate, super.endDate});

  @override
  List<Object?> get props => [result, openDate, endDate];
}

class CalculatorError extends CalculatorState {
  final String message;

  const CalculatorError(this.message, {super.openDate, super.endDate});

  @override
  List<Object?> get props => [message, openDate, endDate];
}

class CalculatorAuthRequired extends CalculatorState {
  final RecognitionCalculationResultEntity result;
  const CalculatorAuthRequired(this.result, {super.openDate, super.endDate});

  @override
  List<Object?> get props => [result, openDate, endDate];
}
