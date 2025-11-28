import 'package:chungyak_box/data/models/payment_model.dart';

class PaymentScheduleModel {
  final int totalInstallments;
  final int totalDelayDays;
  final int totalPrepaidDays;
  final List<PaymentModel> payments;

  PaymentScheduleModel({
    required this.totalInstallments,
    required this.totalDelayDays,
    required this.totalPrepaidDays,
    required this.payments,
  });

  factory PaymentScheduleModel.fromJson(Map<String, dynamic> json) {
    return PaymentScheduleModel(
      totalInstallments: json['total_installments'],
      totalDelayDays: json['total_delay_days'],
      totalPrepaidDays: json['total_prepaid_days'],
      payments: (json['payments'] as List)
          .map((item) => PaymentModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_installments': totalInstallments,
      'total_delay_days': totalDelayDays,
      'total_prepaid_days': totalPrepaidDays,
      'payments': payments.map((p) => p.toJson()).toList(),
    };
  }
}
