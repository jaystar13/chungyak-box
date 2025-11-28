import 'package:equatable/equatable.dart';
import 'package:chungyak_box/domain/entities/user_entity.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AuthEvent {
  const AppStarted();
}

class LoggedIn extends AuthEvent {
  final String token; // The backend JWT token
  final UserEntity user;

  const LoggedIn({required this.token, required this.user});

  @override
  List<Object> get props => [token, user];
}

class LoggedOut extends AuthEvent {
  const LoggedOut();
}
