import 'package:chungyak_box/domain/entities/login_response_entity.dart';
import 'dart:async';

import 'package:chungyak_box/core/result.dart';
import 'package:chungyak_box/domain/usecases/google_login_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';

import 'auth_bloc.dart';
import 'auth_event.dart';
import 'login_event.dart';
import 'login_state.dart';

@injectable
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final GoogleLoginUseCase _googleLoginUseCase;
  final AuthBloc _authBloc;
  bool _isInitialized = false;

  LoginBloc(this._googleLoginUseCase, this._authBloc)
    : super(const LoginInitial()) {
    on<GoogleLoginRequested>(_onGoogleLoginRequested);
    on<SignOutRequested>(_onSignOutRequested);
  }

  Future<void> _initializeIfNeeded() async {
    if (!_isInitialized) {
      await _googleSignIn.initialize();
      _isInitialized = true;
    }
  }

  Future<void> _onGoogleLoginRequested(
    GoogleLoginRequested event,
    Emitter<LoginState> emit,
  ) async {
    if (state is LoginLoading) return;

    emit(const LoginLoading());
    try {
      await _initializeIfNeeded();
      final googleUser = await _googleSignIn.authenticate();

      if (googleUser == null) {
        // User cancelled the sign-in
        emit(const LoginInitial());
        return;
      }

      final auth = googleUser.authentication;
      final idToken = auth.idToken;

      if (idToken == null) {
        emit(const LoginFailure(message: 'Google ID 토큰을 가져올 수 없습니다.'));
        return;
      }

      final result = await _googleLoginUseCase(idToken);
      if (result is Success<LoginResponseEntity>) {
        final loginResponse = result.data;
        _authBloc.add(
          LoggedIn(token: loginResponse.token, user: loginResponse.user),
        );
        emit(LoginSuccess(token: loginResponse.token));
      } else {
        emit(LoginFailure(message: (result as Error).message));
      }
    } catch (e) {
      emit(const LoginFailure(message: '로그인 중 오류가 발생했습니다.'));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<LoginState> emit,
  ) async {
    // Also ensure initialization before sign-out, in case it's called standalone
    await _initializeIfNeeded();
    await _googleSignIn.signOut();
    _authBloc.add(const LoggedOut()); // Notify AuthBloc
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
