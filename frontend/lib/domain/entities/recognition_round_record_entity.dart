import 'package:equatable/equatable.dart';

class RecognitionRoundRecordEntity extends Equatable {
  final int installmentNo;
  final DateTime dueDate;
  final DateTime paidDate;
  final DateTime recognizedDate;
  final int delayDays;
  final int totalDelayDays;
  final int prepaidDays;
  final int totalPrepaidDays;
  final String status;
  final bool isRecognized;
  final int paidAmount;
  final int recognizedAmountForRound;

  const RecognitionRoundRecordEntity({
    required this.installmentNo,
    required this.dueDate,
    required this.paidDate,
    required this.recognizedDate,
    required this.delayDays,
    required this.totalDelayDays,
    required this.prepaidDays,
    required this.totalPrepaidDays,
    required this.status,
    required this.isRecognized,
    required this.paidAmount,
    required this.recognizedAmountForRound,
  });

  @override
  List<Object?> get props => [
        installmentNo,
        dueDate,
        paidDate,
        recognizedDate,
        delayDays,
        totalDelayDays,
        prepaidDays,
        totalPrepaidDays,
        status,
        isRecognized,
        paidAmount,
        recognizedAmountForRound,
      ];
}
