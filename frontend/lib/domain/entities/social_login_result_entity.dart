import 'package:equatable/equatable.dart';
import 'login_response_entity.dart';

abstract class SocialLoginResultEntity extends Equatable {
  const SocialLoginResultEntity();
}

class ExistingUserEntity extends SocialLoginResultEntity {
  final LoginResponseEntity loginResponse;

  const ExistingUserEntity(this.loginResponse);

  @override
  List<Object?> get props => [loginResponse];
}

class NewUserEntity extends SocialLoginResultEntity {
  final String tempToken;

  const NewUserEntity(this.tempToken);

  @override
  List<Object?> get props => [tempToken];
}
