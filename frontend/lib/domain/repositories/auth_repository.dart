import 'package:chungyak_box/core/result.dart';
import 'package:chungyak_box/domain/entities/login_response_entity.dart';
import 'package:chungyak_box/domain/entities/social_login_result_entity.dart';
import 'package:chungyak_box/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Result<SocialLoginResultEntity>> googleLogin(String idToken);
  Future<Result<UserEntity>> verifyToken();
  Future<Result<SocialLoginResultEntity>> naverLogin(String idToken);
  Future<Result<LoginResponseEntity>> completeSocialSignup(
    String tempToken,
    List<String> agreedTermsIds,
  );
  Future<Result<LoginResponseEntity>> signup(
    String email,
    String password,
    String passwordConfirm,
    String name,
    List<String> agreedTermsIds,
  );
  Future<Result<LoginResponseEntity>> login(String email, String password);
}
