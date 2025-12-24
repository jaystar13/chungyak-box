import 'package:equatable/equatable.dart';
import 'package:chungyak_box/domain/entities/my_subscription_entity.dart';

abstract class MySubscriptionState extends Equatable {
  const MySubscriptionState();

  @override
  List<Object?> get props => [];
}

class MySubscriptionInitial extends MySubscriptionState {}

class MySubscriptionLoading extends MySubscriptionState {}

class MySubscriptionLoaded extends MySubscriptionState {
  final MySubscriptionEntity? subscription;

  const MySubscriptionLoaded(this.subscription);

  @override
  List<Object?> get props => [subscription];
}

class MySubscriptionError extends MySubscriptionState {
  final String message;

  const MySubscriptionError(this.message);

  @override
  List<Object> get props => [message];
}