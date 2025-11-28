class RecognitionCalculatorRequestModel {
  final int paymentDay;
  final String startDate;
  final String endDate;
  final String paymentAmountOption;
  final int? standardPaymentAmount;
  final List<CustomPaymentInputModel>? payments;

  RecognitionCalculatorRequestModel({
    required this.paymentDay,
    required this.startDate,
    required this.endDate,
    required this.paymentAmountOption,
    this.standardPaymentAmount,
    this.payments,
  });

  Map<String, dynamic> toJson() {
    return {
      'payment_day': paymentDay,
      'start_date': startDate,
      'end_date': endDate,
      'payment_amount_option': paymentAmountOption,
      if (standardPaymentAmount != null)
        'standard_payment_amount': standardPaymentAmount,
      if (payments != null)
        'payments': payments!.map((e) => e.toJson()).toList(),
    };
  }
}

class CustomPaymentInputModel {
  final int installmentNo;
  final String paidDate;
  final int paidAmount;

  CustomPaymentInputModel({
    required this.installmentNo,
    required this.paidDate,
    required this.paidAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      'installment_no': installmentNo,
      'paid_date': paidDate,
      'paid_amount': paidAmount,
    };
  }
}
