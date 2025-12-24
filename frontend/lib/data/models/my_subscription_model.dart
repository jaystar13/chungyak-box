import 'package:chungyak_box/data/models/recognition_calculation_result_model.dart';

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

class MySubscriptionModel {
  final int id;
  final String name;
  final int paymentDay;
  final String startDate;
  final String endDate;
  final int recognizedRounds;
  final int unrecognizedRounds;
  final int totalRecognizedAmount;
  final List<RecognitionRoundRecordModel> details;
  final String createdAt;

  MySubscriptionModel({
    required this.id,
    required this.name,
    required this.paymentDay,
    required this.startDate,
    required this.endDate,
    required this.recognizedRounds,
    required this.unrecognizedRounds,
    required this.totalRecognizedAmount,
    required this.details,
    required this.createdAt,
  });

  factory MySubscriptionModel.fromJson(Map<String, dynamic> json) {
    final calculationResultJson =
        json['calculation_result'] as Map<String, dynamic>;
    final calculationResultModel = RecognitionCalculationResultModel.fromJson(
      calculationResultJson,
    );

    return MySubscriptionModel(
      id: _parseInt(json['id']),
      name: json['name'] as String? ?? '저장된 청약',
      createdAt: json['created_at'] as String? ?? '',
      paymentDay: calculationResultModel.paymentDay,
      startDate: calculationResultModel.startDate,
      endDate: calculationResultModel.endDate,
      recognizedRounds: calculationResultModel.recognizedRounds,
      unrecognizedRounds: calculationResultModel.unrecognizedRounds,
      totalRecognizedAmount: calculationResultModel.totalRecognizedAmount,
      details: calculationResultModel.details,
    );
  }
}
