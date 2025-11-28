import 'package:equatable/equatable.dart';
import 'package:chungyak_box/domain/entities/recognition_round_record_entity.dart';

class RecognitionCalculationResultEntity extends Equatable {
  final int paymentDay;
  final DateTime startDate;
  final DateTime endDate;
  final int recognizedRounds;
  final int unrecognizedRounds;
  final int totalRecognizedAmount;
  final List<RecognitionRoundRecordEntity> details;

  const RecognitionCalculationResultEntity({
    required this.paymentDay,
    required this.startDate,
    required this.endDate,
    required this.recognizedRounds,
    required this.unrecognizedRounds,
    required this.totalRecognizedAmount,
    required this.details,
  });

  @override
  List<Object?> get props => [
    paymentDay,
    startDate,
    endDate,
    recognizedRounds,
    unrecognizedRounds,
    totalRecognizedAmount,
    details,
  ];
}
