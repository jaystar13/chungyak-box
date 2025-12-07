import 'package:chungyak_box/core/result.dart';
import 'package:chungyak_box/domain/entities/login_response_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chungyak_box/domain/usecases/signup_use_case.dart';
import 'package:chungyak_box/presentation/viewmodels/signup/signup_event.dart';
import 'package:chungyak_box/presentation/viewmodels/signup/signup_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final SignupUseCase _signupUseCase;

  SignupBloc(this._signupUseCase) : super(SignupInitial()) {
    on<SignupRequested>(_onSignupRequested);
  }

  Future<void> _onSignupRequested(
    SignupRequested event,
    Emitter<SignupState> emit,
  ) async {
    emit(SignupLoading());
    final result = await _signupUseCase(
      email: event.email,
      password: event.password,
      passwordConfirm: event.passwordConfirm,
      fullName: event.fullName,
      agreedTermsIds: event.agreedTermsIds,
    );

    if (result is Success<LoginResponseEntity>) {
      emit(SignupSuccess(result.data));
    } else if (result is Error<LoginResponseEntity>) {
      emit(SignupFailure(result.message));
    }
  }
}
