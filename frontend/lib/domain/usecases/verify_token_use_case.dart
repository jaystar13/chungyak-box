import 'package:injectable/injectable.dart';
import 'package:chungyak_box/core/result.dart';
import 'package:chungyak_box/domain/repositories/auth_repository.dart';
import 'package:chungyak_box/domain/entities/user_entity.dart';

@injectable
class VerifyTokenUseCase {
  final AuthRepository _authRepository;

  VerifyTokenUseCase(this._authRepository);

  Future<Result<UserEntity>> call() {
    return _authRepository.verifyToken();
  }
}
