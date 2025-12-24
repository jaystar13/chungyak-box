import 'package:equatable/equatable.dart';
import 'package:chungyak_box/domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final String token;
  final UserEntity user;

  const Authenticated({required this.token, required this.user});

  @override
  List<Object> get props => [token, user];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

class AccountDeletionSuccess extends AuthState {
  const AccountDeletionSuccess();
}
