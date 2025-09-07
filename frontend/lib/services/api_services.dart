import 'dart:convert';

import 'package:frontend/models/payment_schdule_model.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/models/calculator_model.dart';

class ApiServices {
  static final String baseUrl = "http://127.0.0.1:8000";

  static Future<PaymentScheduleResponse> generatePaymentSchedule(
    CalculatorRequest request,
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
    return PaymentScheduleResponse.fromJson(payloads);
  }

  static Future<PaymentScheduleResponse> recalculateSchedule(
    PaymentScheduleRequest request,
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
    return PaymentScheduleResponse.fromJson(payloads);
  }
}
