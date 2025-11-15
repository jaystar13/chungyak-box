import 'package:equatable/equatable.dart';
import 'package:chungyak_box/domain/entities/custom_payment_input_entity.dart';

class RecognitionCalculatorRequestEntity extends Equatable {
  final int paymentDay;
  final DateTime startDate;
  final DateTime endDate;
  final String paymentAmountOption;
  final int? standardPaymentAmount;
  final List<CustomPaymentInputEntity>? payments;

  const RecognitionCalculatorRequestEntity({
    required this.paymentDay,
    required this.startDate,
    required this.endDate,
    required this.paymentAmountOption,
    this.standardPaymentAmount,
    this.payments,
  });

  @override
  List<Object?> get props => [
        paymentDay,
        startDate,
        endDate,
        paymentAmountOption,
        standardPaymentAmount,
        payments,
      ];
}
