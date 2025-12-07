import 'term_model.dart';

class LatestTermsModel {
  final TermModel? termsOfUse;
  final TermModel? privacyPolicy;

  LatestTermsModel({
    this.termsOfUse,
    this.privacyPolicy,
  });

  factory LatestTermsModel.fromJson(Map<String, dynamic> json) {
    return LatestTermsModel(
      termsOfUse: json['terms_of_use'] != null
          ? TermModel.fromJson(json['terms_of_use'])
          : null,
      privacyPolicy: json['privacy_policy'] != null
          ? TermModel.fromJson(json['privacy_policy'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'terms_of_use': termsOfUse?.toJson(),
      'privacy_policy': privacyPolicy?.toJson(),
    };
  }
}
