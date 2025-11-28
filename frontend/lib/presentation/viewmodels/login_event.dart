import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class GoogleLoginRequested extends LoginEvent {
  const GoogleLoginRequested();
}

class SignOutRequested extends LoginEvent {
  const SignOutRequested();
}
