import 'dart:convert';
import 'package:chungyak_box/core/result.dart';
import 'package:chungyak_box/data/datasources/api_services.dart';
import 'package:chungyak_box/domain/entities/login_response_entity.dart';
import 'package:chungyak_box/domain/repositories/auth_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:chungyak_box/domain/entities/user_entity.dart';
import 'package:chungyak_box/data/models/user_model.dart';
import 'package:chungyak_box/data/mapper/user_mapper.dart';
import 'package:chungyak_box/data/models/login_response_model.dart';
import 'package:chungyak_box/data/mapper/login_response_mapper.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final ApiServices _api;
  final FlutterSecureStorage _secureStorage;
  final UserMapper _userMapper;
  final LoginResponseMapper _loginResponseMapper;

  AuthRepositoryImpl(
    this._api,
    this._secureStorage,
    this._userMapper,
    this._loginResponseMapper,
  );

  @override
  Future<Result<LoginResponseEntity>> googleLogin(String idToken) async {
    try {
      final uri = Uri.parse('${_api.baseUrl}/api/v1/login/google');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': idToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final loginResponseModel = LoginResponseModel.fromJson(data);
        final loginResponseEntity = _loginResponseMapper.fromModel(
          loginResponseModel,
        );
        return Success(loginResponseEntity);
      } else {
        // You might want to parse the error message from the response body
        return Error('로그인에 실패했습니다. (코드: ${response.statusCode})');
      }
    } catch (e) {
      return Error('네트워크 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<Result<UserEntity>> verifyToken() async {
    try {
      final token = await _secureStorage.read(key: 'jwt_token');
      if (token == null || token.isEmpty) {
        return const Error('토큰이 존재하지 않습니다.');
      }

      final uri = Uri.parse('${_api.baseUrl}/api/v1/private/me');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print('response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userModel = UserModel.fromJson(data);
        final userEntity = _userMapper.fromModel(userModel);
        return Success(userEntity);
      } else if (response.statusCode == 403) {
        await _secureStorage.delete(key: 'jwt_token');
        return const Error('토큰이 유효하지 않습니다.');
      } else {
        return Error('토큰 검증에 실패했습니다. (코드: ${response.statusCode})');
      }
    } catch (e) {
      return Error('네트워크 오류가 발생했습니다: $e');
    }
  }
}
