import 'package:chungyak_box/data/models/payment_model.dart';

class PaymentScheduleRequestModel {
  final String openDate;
  final String endDate;
  final List<PaymentModel> payments;

  PaymentScheduleRequestModel({
    required this.openDate,
    required this.endDate,
    required this.payments,
  });

  Map<String, dynamic> toJson() {
    return {
      'open_date': openDate,
      'end_date': endDate,
      'payments': payments.map((p) => p.toJson()).toList(),
    };
  }
}
