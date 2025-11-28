import 'dart:convert';

import 'package:chungyak_box/data/models/payment_schedule_model.dart';
import 'package:http/http.dart' as http;
import 'package:chungyak_box/data/models/calculator_request_model.dart';
import 'package:chungyak_box/data/models/payment_schedule_request_model.dart';
import 'package:chungyak_box/data/models/recognition_calculator_request_model.dart';
import 'package:chungyak_box/data/models/recognition_calculation_result_model.dart';

import 'package:injectable/injectable.dart';

@lazySingleton
class ApiServices {
  // final String baseUrl = "https://chungyak-box.onrender.com";
  final String baseUrl = "http://127.0.0.1:8000";

  Future<PaymentScheduleModel> generatePaymentSchedule(
    CalculatorRequestModel request,
  ) async {
    final url = Uri.parse("$baseUrl/api/v1/payments/normal");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to generate payment schedule");
    }

    final payloads = jsonDecode(response.body);
    return PaymentScheduleModel.fromJson(payloads);
  }

  Future<PaymentScheduleModel> recalculateSchedule(
    PaymentScheduleRequestModel request,
  ) async {
    final url = Uri.parse("$baseUrl/api/v1/payments/recalc");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to generate payment schedule");
    }

    final payloads = jsonDecode(response.body);
    return PaymentScheduleModel.fromJson(payloads);
  }

  Future<RecognitionCalculationResultModel> calculateRecognition(
    RecognitionCalculatorRequestModel request,
  ) async {
    final url = Uri.parse("$baseUrl/api/v1/payments/calculate-recognition");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to calculate recognition");
    }

    final payloads = jsonDecode(response.body);
    return RecognitionCalculationResultModel.fromJson(payloads);
  }
}
