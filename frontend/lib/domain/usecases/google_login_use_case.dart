import 'package:chungyak_box/core/result.dart';
import 'package:chungyak_box/domain/entities/social_login_result_entity.dart';
import 'package:chungyak_box/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GoogleLoginUseCase {
  final AuthRepository _authRepository;

  GoogleLoginUseCase(this._authRepository);

  Future<Result<SocialLoginResultEntity>> call(String idToken) async {
    return await _authRepository.googleLogin(idToken);
  }
}
