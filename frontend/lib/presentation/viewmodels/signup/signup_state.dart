import 'package:equatable/equatable.dart';
import 'package:chungyak_box/domain/entities/login_response_entity.dart';

abstract class SignupState extends Equatable {
  const SignupState();

  @override
  List<Object> get props => [];
}

class SignupInitial extends SignupState {}

class SignupLoading extends SignupState {}

class SignupSuccess extends SignupState {
  final LoginResponseEntity loginResponse;

  const SignupSuccess(this.loginResponse);

  @override
  List<Object> get props => [loginResponse];
}

class SignupFailure extends SignupState {
  final String message;

  const SignupFailure(this.message);

  @override
  List<Object> get props => [message];
}
