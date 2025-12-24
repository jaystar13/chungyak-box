import 'package:chungyak_box/core/auth_exception.dart';
import 'dart:convert';

import 'package:chungyak_box/data/models/my_subscription_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:chungyak_box/data/models/recognition_calculator_request_model.dart';
import 'package:chungyak_box/data/models/recognition_calculation_result_model.dart';

import 'package:injectable/injectable.dart';

@lazySingleton
class ApiServices {
  final FlutterSecureStorage _secureStorage;

  final String baseUrl = "https://chungyak-box.onrender.com";
  // final String baseUrl = "http://127.0.0.1:8000";

  ApiServices(this._secureStorage);

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

  Future<void> saveHousingSubscriptionDetail(
    RecognitionCalculationResultModel request,
  ) async {
    final token = await _secureStorage.read(key: 'jwt_token');
    if (token == null || token.isEmpty) {
      throw AuthException('Access token not found');
    }

    final url = Uri.parse("$baseUrl/api/v1/me/housing-subscription-detail");
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 401) {
      throw AuthException('Unauthorized: Token is invalid or expired');
    }
    if (response.statusCode != 200) {
      throw Exception("Failed to save housing subscription detail");
    }
  }

  Future<MySubscriptionModel?> getMyHousingSubscriptionDetail() async {
    final token = await _secureStorage.read(key: 'jwt_token');
    if (token == null || token.isEmpty) {
      throw AuthException('Access token not found');
    }

    final url = Uri.parse("$baseUrl/api/v1/me/housing-subscription-detail");
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 401) {
      throw AuthException('Unauthorized: Token is invalid or expired');
    }
    if (response.statusCode != 200) {
      throw Exception("Failed to get housing subscription details");
    }

    if (response.bodyBytes.isEmpty) {
      return null;
    }

    final responseData = jsonDecode(utf8.decode(response.bodyBytes));

    if (responseData is Map<String, dynamic>) {
      if (responseData.isEmpty) {
        return null;
      }
      return MySubscriptionModel.fromJson(responseData);
    }

    return null;
  }

  Future<void> deleteAccount() async {
    final token = await _secureStorage.read(key: 'jwt_token');
    if (token == null || token.isEmpty) {
      throw AuthException('Access token not found');
    }

    final url = Uri.parse("$baseUrl/api/v1/users/me");
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 401) {
      throw AuthException('Unauthorized: Token is invalid or expired');
    }
    if (response.statusCode != 204 && response.statusCode != 200) {
      // Assuming 204 No Content or 200 OK for success
      throw Exception(
        "Failed to delete account. Status code: ${response.statusCode}",
      );
    }
  }
}
