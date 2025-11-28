import 'package:chungyak_box/data/mapper/user_mapper.dart';
import 'package:chungyak_box/data/models/login_response_model.dart';
import 'package:chungyak_box/domain/entities/login_response_entity.dart';
import 'package:injectable/injectable.dart';

@injectable
class LoginResponseMapper {
  final UserMapper _userMapper;

  LoginResponseMapper(this._userMapper);

  LoginResponseEntity fromModel(LoginResponseModel model) {
    return LoginResponseEntity(
      token: model.token,
      user: _userMapper.fromModel(model.user),
    );
  }
}
