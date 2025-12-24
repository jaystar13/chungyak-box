import 'package:chungyak_box/core/result.dart';
import 'package:chungyak_box/domain/entities/login_response_entity.dart';
import 'package:chungyak_box/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class EmailPasswordLoginUseCase {
  final AuthRepository _authRepository;
  EmailPasswordLoginUseCase(this._authRepository);

  Future<Result<LoginResponseEntity>> call(
    String email,
    String password,
  ) async {
    return await _authRepository.login(email, password);
  }
}
