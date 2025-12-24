import 'package:chungyak_box/domain/entities/latest_terms_entity.dart';
import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  const LoginSuccess();
}

class LoginRequiresTermsAgreement extends LoginState {
  final String tempToken;
  final LatestTermsEntity latestTerms;

  const LoginRequiresTermsAgreement({
    required this.tempToken,
    required this.latestTerms,
  });

  @override
  List<Object?> get props => [tempToken, latestTerms];
}

class LoginFailure extends LoginState {
  final String message;

  const LoginFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
