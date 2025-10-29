class PaymentModel {
  final int installmentNo;
  final String dueDate;
  final String paidDate;
  final int delayDays;
  final int totalDelayDays;
  final int prepaidDays;
  final int totalPrepaidDays;
  final String recognizedDate;
  final bool isRecognized;

  PaymentModel({
    required this.installmentNo,
    required this.dueDate,
    required this.paidDate,
    required this.delayDays,
    required this.totalDelayDays,
    required this.prepaidDays,
    required this.totalPrepaidDays,
    required this.recognizedDate,
    required this.isRecognized,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      installmentNo: json['installment_no'],
      dueDate: json['due_date'],
      paidDate: json['paid_date'],
      delayDays: json['delay_days'],
      totalDelayDays: json['total_delay_days'],
      prepaidDays: json['prepaid_days'],
      totalPrepaidDays: json['total_prepaid_days'],
      recognizedDate: json['recognized_date'],
      isRecognized: json['is_recognized'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'installment_no': installmentNo,
      'due_date': dueDate,
      'paid_date': paidDate,
      'delay_days': delayDays,
      'total_delay_days': totalDelayDays,
      'prepaid_days': prepaidDays,
      'total_prepaid_days': totalPrepaidDays,
      'recognized_date': recognizedDate,
      'is_recognized': isRecognized,
    };
  }
}