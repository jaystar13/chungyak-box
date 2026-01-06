import 'package:equatable/equatable.dart';

abstract class NewsEvent extends Equatable {
  const NewsEvent();

  @override
  List<Object> get props => [];
}

class LoadNews extends NewsEvent {}

class MarkItemAsViewed extends NewsEvent {
  final String itemId;

  const MarkItemAsViewed(this.itemId);

  @override
  List<Object> get props => [itemId];
}
