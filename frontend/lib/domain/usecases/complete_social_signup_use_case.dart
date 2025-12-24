import 'package:chungyak_box/core/result.dart';
import 'package:chungyak_box/domain/entities/login_response_entity.dart';
import 'package:chungyak_box/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class CompleteSocialSignupUseCase {
  final AuthRepository _authRepository;

  CompleteSocialSignupUseCase(this._authRepository);

  Future<Result<LoginResponseEntity>> call({
    required String tempToken,
    required List<String> agreedTermsIds,
  }) async {
    return await _authRepository.completeSocialSignup(
      tempToken,
      agreedTermsIds,
    );
  }
}
