import 'package:equatable/equatable.dart';
import 'package:chungyak_box/domain/entities/payment_entity.dart';

class PaymentScheduleEntity extends Equatable {
  final int totalInstallments;
  final int totalDelayDays;
  final int totalPrepaidDays;
  final List<PaymentEntity> payments;

  const PaymentScheduleEntity({
    required this.totalInstallments,
    required this.totalDelayDays,
    required this.totalPrepaidDays,
    required this.payments,
  });

  @override
  List<Object?> get props => [
        totalInstallments,
        totalDelayDays,
        totalPrepaidDays,
        payments,
      ];
}