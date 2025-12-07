import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class GoogleLoginRequested extends LoginEvent {
  const GoogleLoginRequested();
}

class NaverLoginRequested extends LoginEvent {
  const NaverLoginRequested();
}

class TermsScreenLoaded extends LoginEvent {
  const TermsScreenLoaded();
}

class TermsAccepted extends LoginEvent {
  final List<String> agreedTermsIds;
  const TermsAccepted({required this.agreedTermsIds});

  @override
  List<Object?> get props => [agreedTermsIds];
}

class SignOutRequested extends LoginEvent {
  const SignOutRequested();
}

class EmailPasswordLoginRequested extends LoginEvent {
  final String email;
  final String password;

  const EmailPasswordLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}
