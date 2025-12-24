import 'package:chungyak_box/core/result.dart';
import 'package:chungyak_box/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class DeleteAccountUseCase {
  final AuthRepository _authRepository;

  DeleteAccountUseCase(this._authRepository);

  Future<Result<void>> call() async {
    return _authRepository.deleteAccount();
  }
}
