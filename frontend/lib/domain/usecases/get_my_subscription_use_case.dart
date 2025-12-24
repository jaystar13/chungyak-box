import 'package:chungyak_box/core/result.dart';
import 'package:chungyak_box/domain/entities/my_subscription_entity.dart';
import 'package:chungyak_box/domain/repositories/calculator_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetMySubscriptionUseCase {
  final CalculatorRepository _repository;

  GetMySubscriptionUseCase(this._repository);

  Future<Result<MySubscriptionEntity?>> call() async {
    return await _repository.getMyHousingSubscriptionDetail();
  }
}
