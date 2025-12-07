import 'package:chungyak_box/core/result.dart';
import 'package:chungyak_box/domain/entities/login_response_entity.dart';
import 'package:chungyak_box/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class SignupUseCase {
  final AuthRepository _authRepository;

  SignupUseCase(this._authRepository);

  Future<Result<LoginResponseEntity>> call({
    required String email,
    required String password,
    required String passwordConfirm,
    required String fullName,
    required List<String> agreedTermsIds,
  }) async {
    return await _authRepository.signup(
      email,
      password,
      passwordConfirm,
      fullName,
      agreedTermsIds,
    );
  }
}
