import 'package:equatable/equatable.dart';
import 'package:chungyak_box/domain/entities/recognition_round_record_entity.dart';

class MySubscriptionEntity extends Equatable {
  final int id;
  final String name;
  final int paymentDay;
  final DateTime startDate;
  final DateTime endDate;
  final int recognizedRounds;
  final int unrecognizedRounds;
  final int totalRecognizedAmount;
  final List<RecognitionRoundRecordEntity> details;
  final DateTime createdAt;

  const MySubscriptionEntity({
    required this.id,
    required this.name,
    required this.paymentDay,
    required this.startDate,
    required this.endDate,
    required this.recognizedRounds,
    required this.unrecognizedRounds,
    required this.totalRecognizedAmount,
    required this.details,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        paymentDay,
        startDate,
        endDate,
        recognizedRounds,
        unrecognizedRounds,
        totalRecognizedAmount,
        details,
        createdAt,
      ];
}
