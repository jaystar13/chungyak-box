// Helper function for safe integer parsing
int _parseInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  if (value is double) {
    return value.toInt();
  }
  return 0;
}

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

  factory RecognitionCalculationResultModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return RecognitionCalculationResultModel(
      paymentDay: _parseInt(json['payment_day']),
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      recognizedRounds: _parseInt(json['recognized_rounds']),
      unrecognizedRounds: _parseInt(json['unrecognized_rounds']),
      totalRecognizedAmount: _parseInt(json['total_recognized_amount']),
      details: (json['details'] as List<dynamic>)
          .map(
            (e) =>
                RecognitionRoundRecordModel.fromJson(e as Map<String, dynamic>),
          )
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
  final String? paidDate;
  final String? recognizedDate;
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
    this.paidDate,
    this.recognizedDate,
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
      installmentNo: _parseInt(json['installment_no']),
      dueDate: json['due_date'] as String,
      paidDate: json['paid_date'] as String?,
      recognizedDate: json['recognized_date'] as String?,
      delayDays: _parseInt(json['delay_days']),
      totalDelayDays: _parseInt(json['total_delay_days']),
      prepaidDays: _parseInt(json['prepaid_days']),
      totalPrepaidDays: _parseInt(json['total_prepaid_days']),
      status: json['status'] as String,
      isRecognized: json['is_recognized'] as bool,
      paidAmount: _parseInt(json['paid_amount']),
      recognizedAmountForRound: _parseInt(json['recognized_amount_for_round']),
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
