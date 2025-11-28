import 'package:equatable/equatable.dart';

class PaymentEntity extends Equatable {
  final int installmentNo;
  final String dueDate;
  final String paidDate;
  final int delayDays;
  final int totalDelayDays;
  final int prepaidDays;
  final int totalPrepaidDays;
  final String recognizedDate;
  final bool isRecognized;
  final int paidAmount;

  const PaymentEntity({
    required this.installmentNo,
    required this.dueDate,
    required this.paidDate,
    required this.paidAmount,
    required this.delayDays,
    required this.totalDelayDays,
    required this.prepaidDays,
    required this.totalPrepaidDays,
    required this.recognizedDate,
    required this.isRecognized,
  });

  @override
  List<Object?> get props => [
    installmentNo,
    dueDate,
    paidDate,
    paidAmount,
    delayDays,
    totalDelayDays,
    prepaidDays,
    totalPrepaidDays,
    recognizedDate,
    isRecognized,
  ];
}
