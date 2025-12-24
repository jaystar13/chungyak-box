import 'package:chungyak_box/core/result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chungyak_box/domain/usecases/get_my_subscription_use_case.dart';
import 'package:chungyak_box/presentation/viewmodels/my_subscription_event.dart';
import 'package:chungyak_box/presentation/viewmodels/my_subscription_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class MySubscriptionBloc
    extends Bloc<MySubscriptionEvent, MySubscriptionState> {
  final GetMySubscriptionUseCase _getMySubscriptionUseCase;

  MySubscriptionBloc(this._getMySubscriptionUseCase)
    : super(MySubscriptionInitial()) {
    on<LoadMySubscription>(_onLoadMySubscription);
  }

  Future<void> _onLoadMySubscription(
    LoadMySubscription event,
    Emitter<MySubscriptionState> emit,
  ) async {
    emit(MySubscriptionLoading());
    final result = await _getMySubscriptionUseCase();

    if (result is Success) {
      emit(MySubscriptionLoaded((result as Success).data));
    } else if (result is Error) {
      emit(MySubscriptionError((result as Error).message));
    }
  }
}
