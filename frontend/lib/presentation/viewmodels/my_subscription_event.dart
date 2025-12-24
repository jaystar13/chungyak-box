import 'package:equatable/equatable.dart';

abstract class MySubscriptionEvent extends Equatable {
  const MySubscriptionEvent();

  @override
  List<Object> get props => [];
}

class LoadMySubscription extends MySubscriptionEvent {}