class RecognitionCalculationResultModel {
  final int paymentDay;
  final String startDate;
  final String endDate;
  final int recognizedRounds;
  final int unrecognizedRounds;
  final int totalRecognizedAmount;
  final List<RecognitionRoundRecordModel> details;

  RecognitionCalculationResultModel({
    required this.paymentDay,
    required this.startDate,
    required this.endDate,
    required this.recognizedRounds,
    required this.unrecognizedRounds,
    required this.totalRecognizedAmount,
    required this.details,
  });

  factory RecognitionCalculationResultModel.fromJson(Map<String, dynamic> json) {
    return RecognitionCalculationResultModel(
      paymentDay: json['payment_day'] as int,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      recognizedRounds: json['recognized_rounds'] as int,
      unrecognizedRounds: json['unrecognized_rounds'] as int,
      totalRecognizedAmount: json['total_recognized_amount'] as int,
      details: (json['details'] as List<dynamic>)
          .map((e) => RecognitionRoundRecordModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_day': paymentDay,
      'start_date': startDate,
      'end_date': endDate,
      'recognized_rounds': recognizedRounds,
      'unrecognized_rounds': unrecognizedRounds,
      'total_recognized_amount': totalRecognizedAmount,
      'details': details.map((e) => e.toJson()).toList(),
    };
  }
}

class RecognitionRoundRecordModel {
  final int installmentNo;
  final String dueDate;
  final String paidDate;
  final String recognizedDate;
  final int delayDays;
  final int totalDelayDays;
  final int prepaidDays;
  final int totalPrepaidDays;
  final String status;
  final bool isRecognized;
  final int paidAmount;
  final int recognizedAmountForRound;

  RecognitionRoundRecordModel({
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

  factory RecognitionRoundRecordModel.fromJson(Map<String, dynamic> json) {
    return RecognitionRoundRecordModel(
      installmentNo: json['installment_no'] as int,
      dueDate: json['due_date'] as String,
      paidDate: json['paid_date'] as String,
      recognizedDate: json['recognized_date'] as String,
      delayDays: json['delay_days'] as int,
      totalDelayDays: json['total_delay_days'] as int,
      prepaidDays: json['prepaid_days'] as int,
      totalPrepaidDays: json['total_prepaid_days'] as int,
      status: json['status'] as String,
      isRecognized: json['is_recognized'] as bool,
      paidAmount: json['paid_amount'] as int,
      recognizedAmountForRound: json['recognized_amount_for_round'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'installment_no': installmentNo,
      'due_date': dueDate,
      'paid_date': paidDate,
      'recognized_date': recognizedDate,
      'delay_days': delayDays,
      'total_delay_days': totalDelayDays,
      'prepaid_days': prepaidDays,
      'total_prepaid_days': totalPrepaidDays,
      'status': status,
      'is_recognized': isRecognized,
      'paid_amount': paidAmount,
      'recognized_amount_for_round': recognizedAmountForRound,
    };
  }
}
