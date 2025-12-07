import 'package:equatable/equatable.dart';
import 'term_entity.dart';

class LatestTermsEntity extends Equatable {
  final TermEntity? termsOfUse;
  final TermEntity? privacyPolicy;

  const LatestTermsEntity({
    this.termsOfUse,
    this.privacyPolicy,
  });

  @override
  List<Object?> get props => [termsOfUse, privacyPolicy];

  bool get areAllRequiredTermsAgreed =>
      termsOfUse != null && privacyPolicy != null;
}
