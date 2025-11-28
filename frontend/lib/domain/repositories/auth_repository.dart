import 'package:chungyak_box/core/result.dart';
import 'package:chungyak_box/domain/entities/user_entity.dart';
import 'package:chungyak_box/domain/entities/login_response_entity.dart';

abstract class AuthRepository {
  Future<Result<LoginResponseEntity>> googleLogin(String idToken);
  Future<Result<UserEntity>> verifyToken();
}
