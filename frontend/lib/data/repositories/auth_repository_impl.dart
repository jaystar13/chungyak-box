import 'dart:convert';
import 'package:chungyak_box/core/result.dart';
import 'package:chungyak_box/data/datasources/api_services.dart';
import 'package:chungyak_box/domain/entities/login_response_entity.dart';
import 'package:chungyak_box/domain/entities/social_login_result_entity.dart';
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
  Future<Result<SocialLoginResultEntity>> googleLogin(String idToken) async {
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
        return Success(ExistingUserEntity(loginResponseEntity));
      } else if (response.statusCode == 202) {
        final data = jsonDecode(response.body);
        final tempToken = data['token'];
        return Success(NewUserEntity(tempToken));
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

  @override
  Future<Result<SocialLoginResultEntity>> naverLogin(String accessToken) async {
    try {
      final uri = Uri.parse('${_api.baseUrl}/api/v1/login/naver');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': accessToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final loginResponseModel = LoginResponseModel.fromJson(data);
        final loginResponseEntity = _loginResponseMapper.fromModel(
          loginResponseModel,
        );
        return Success(ExistingUserEntity(loginResponseEntity));
      } else if (response.statusCode == 202) {
        final data = jsonDecode(response.body);
        final tempToken = data['token'];
        return Success(NewUserEntity(tempToken));
      } else {
        // You might want to parse the error message from the response body
        return Error('네이버 로그인에 실패했습니다. (코드: ${response.statusCode})');
      }
    } catch (e) {
      return Error('네트워크 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<Result<LoginResponseEntity>> completeSocialSignup(
    String tempToken,
    List<String> agreedTermsIds,
  ) async {
    try {
      final uri = Uri.parse(
        '${_api.baseUrl}/api/v1/login/social-signup/complete',
      );
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': tempToken,
          'agreed_terms_ids': agreedTermsIds,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final loginResponseModel = LoginResponseModel.fromJson(data);
        final loginResponseEntity = _loginResponseMapper.fromModel(
          loginResponseModel,
        );
        return Success(loginResponseEntity);
      } else {
        return Error('회원가입 완료에 실패했습니다. (코드: ${response.statusCode})');
      }
    } catch (e) {
      return Error('네트워크 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<Result<LoginResponseEntity>> signup(
    String email,
    String password,
    String passwordConfirm,
    String name,
    List<String> agreedTermsIds,
  ) async {
    try {
      final uri = Uri.parse('${_api.baseUrl}/api/v1/signup/');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'password_confirm': passwordConfirm,
          'full_name': name,
          'agreed_terms_ids': agreedTermsIds,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final loginResponseModel = LoginResponseModel.fromJson(data);
        final loginResponseEntity = _loginResponseMapper.fromModel(
          loginResponseModel,
        );
        return Success(loginResponseEntity);
      } else if (response.statusCode == 400) {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        final errorMessage = errorData['detail'];
        return Error(errorMessage);
      } else if (response.statusCode == 422) {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> errorList = errorData['detail'];

        final List<String> errorMessages = errorList.map((errorItem) {
          final String field = errorItem['loc'][1];
          final String message = errorItem['msg'];
          if (message.contains('valid email')) {
            return '이메일 항목을 이메일 형식에 맞게 입력해주세요.';
          }
          return '$field: $message';
        }).toList();

        return Error(errorMessages.join('\n'));
      } else {
        return Error('회원가입에 실패했습니다. (코드: ${response.statusCode})');
      }
    } catch (e) {
      return Error('네트워크 오류가 발생했습니다: $e');
    }
  }

  @override
  Future<Result<LoginResponseEntity>> login(
    String email,
    String password,
  ) async {
    try {
      final uri = Uri.parse('${_api.baseUrl}/api/v1/login/access-token');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'username': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final loginResponseModel = LoginResponseModel.fromJson(data);
        final loginResponseEntity = _loginResponseMapper.fromModel(
          loginResponseModel,
        );
        return Success(loginResponseEntity);
      } else if (response.statusCode == 401) {
        return const Error('이메일 또는 비밀번호가 잘못되었습니다.');
      } else {
        return Error('로그인에 실패했습니다. (코드: ${response.statusCode})');
      }
    } catch (e) {
      return Error('네트워크 오류가 발생했습니다: $e');
    }
  }
}
