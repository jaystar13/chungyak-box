import 'package:chungyak_box/data/models/user_model.dart';
import 'package:chungyak_box/domain/entities/user_entity.dart';
import 'package:injectable/injectable.dart';

@injectable
class UserMapper {
  UserEntity fromModel(UserModel model) {
    return UserEntity(id: model.id, email: model.email, name: model.name);
  }
}
