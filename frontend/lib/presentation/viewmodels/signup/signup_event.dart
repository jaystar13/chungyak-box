import 'package:equatable/equatable.dart';

abstract class SignupEvent extends Equatable {
  const SignupEvent();

  @override
  List<Object> get props => [];
}

class SignupRequested extends SignupEvent {
  final String email;
  final String password;
  final String passwordConfirm;
  final String fullName;
  final List<String> agreedTermsIds;

  const SignupRequested({
    required this.email,
    required this.password,
    required this.passwordConfirm,
    required this.fullName,
    required this.agreedTermsIds,
  });

  @override
  List<Object> get props => [
    email,
    password,
    passwordConfirm,
    fullName,
    agreedTermsIds,
  ];
}
