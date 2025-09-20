class PaymentScheduleResponse {
  final int totalInstallments;
  final int totalDelayDays;
  final int totalPrepaidDays;
  final List<Payment> payments;

  PaymentScheduleResponse({
    required this.totalInstallments,
    required this.totalDelayDays,
    required this.totalPrepaidDays,
    required this.payments,
  });

  factory PaymentScheduleResponse.fromJson(Map<String, dynamic> json) {
    return PaymentScheduleResponse(
      totalInstallments: json['total_installments'],
      totalDelayDays: json['total_delay_days'],
      totalPrepaidDays: json['total_prepaid_days'],
      payments: (json['payments'] as List)
          .map((item) => Payment.fromJson(item))
          .toList(),
    );
  }
}

class Payment {
  final int installmentNo;
  final String dueDate;
  final String paidDate;
  final int delayDays;
  final int totalDelayDays;
  final int prepaidDays;
  final int totalPrepaidDays;
  final String recognizedDate;

  Payment({
    required this.installmentNo,
    required this.dueDate,
    required this.paidDate,
    required this.delayDays,
    required this.totalDelayDays,
    required this.prepaidDays,
    required this.totalPrepaidDays,
    required this.recognizedDate,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      installmentNo: json['installment_no'],
      dueDate: json['due_date'],
      paidDate: json['paid_date'],
      delayDays: json['delay_days'],
      totalDelayDays: json['total_delay_days'],
      prepaidDays: json['prepaid_days'],
      totalPrepaidDays: json['total_prepaid_days'],
      recognizedDate: json['recognized_date'],
    );
  }
}

class PaymentRequest {
  int installmentNo;
  String dueDate;
  String paidDate;

  PaymentRequest({
    required this.installmentNo,
    required this.dueDate,
    required this.paidDate,
  });

  factory PaymentRequest.fromPayment(Payment payment) {
    return PaymentRequest(
      installmentNo: payment.installmentNo,
      dueDate: payment.dueDate,
      paidDate: payment.paidDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "installment_no": installmentNo,
      "due_date": dueDate,
      "paid_date": paidDate,
    };
  }
}

class PaymentScheduleRequest {
  DateTime openDate;
  DateTime endDate;
  List<PaymentRequest> payments;

  PaymentScheduleRequest({
    required this.openDate,
    required this.endDate,
    required this.payments,
  });

  factory PaymentScheduleRequest.fromResponse(
    DateTime? openDate,
    DateTime? endDate,
    PaymentScheduleResponse res,
  ) {
    return PaymentScheduleRequest(
      openDate: openDate ?? DateTime.now(),
      endDate: endDate ?? DateTime.now(),
      payments: res.payments.map((p) => PaymentRequest.fromPayment(p)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "open_date": openDate.toIso8601String().split('T').first,
      "end_date": endDate.toIso8601String().split('T').first,
      "payments": payments.map((p) => p.toJson()).toList(),
    };
  }
}
