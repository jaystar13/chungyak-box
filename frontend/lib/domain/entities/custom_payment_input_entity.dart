import 'package:equatable/equatable.dart';

class CustomPaymentInputEntity extends Equatable {
  final int installmentNo;
  final DateTime paidDate;
  final int paidAmount;

  const CustomPaymentInputEntity({
    required this.installmentNo,
    required this.paidDate,
    required this.paidAmount,
  });

  @override
  List<Object?> get props => [installmentNo, paidDate, paidAmount];
}
