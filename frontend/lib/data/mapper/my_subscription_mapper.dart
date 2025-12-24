import 'package:chungyak_box/data/mapper/recognition_mapper.dart';
import 'package:chungyak_box/data/models/my_subscription_model.dart';
import 'package:chungyak_box/domain/entities/my_subscription_entity.dart';

extension MySubscriptionMapper on MySubscriptionModel {
  MySubscriptionEntity toEntity() {
    return MySubscriptionEntity(
      id: id,
      name: name,
      paymentDay: paymentDay,
      startDate: DateTime.parse(startDate),
      endDate: DateTime.parse(endDate),
      recognizedRounds: recognizedRounds,
      unrecognizedRounds: unrecognizedRounds,
      totalRecognizedAmount: totalRecognizedAmount,
      details: details.map((e) => e.toEntity()).toList(),
      createdAt: DateTime.parse(createdAt).toLocal(),
    );
  }
}
