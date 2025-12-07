import 'package:chungyak_box/core/result.dart';
import 'package:chungyak_box/domain/entities/social_login_result_entity.dart';
import 'package:chungyak_box/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class NaverLoginUseCase {
  final AuthRepository _authRepository;

  NaverLoginUseCase(this._authRepository);

  Future<Result<SocialLoginResultEntity>> call(String accessToken) async {
    return await _authRepository.naverLogin(accessToken);
  }
}
