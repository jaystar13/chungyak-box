import 'package:chungyak_box/domain/entities/latest_terms_entity.dart';
import 'package:chungyak_box/domain/entities/login_response_entity.dart';
import 'package:chungyak_box/domain/entities/social_login_result_entity.dart';
import 'package:chungyak_box/domain/usecases/complete_social_signup_use_case.dart';
import 'dart:async';

import 'package:chungyak_box/core/result.dart';
import 'package:chungyak_box/domain/usecases/email_password_login_use_case.dart';
import 'package:chungyak_box/domain/usecases/get_latest_terms_use_case.dart';
import 'package:chungyak_box/domain/usecases/google_login_use_case.dart';
import 'package:chungyak_box/domain/usecases/naver_login_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:flutter_naver_login/interface/types/naver_login_status.dart';
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
  final NaverLoginUseCase _naverLoginUseCase;
  final CompleteSocialSignupUseCase _completeSocialSignupUseCase;
  final GetLatestTermsUseCase _getLatestTermsUseCase;
  final AuthBloc _authBloc;
  final EmailPasswordLoginUseCase _emailPasswordLoginUseCase;
  bool _isInitialized = false;

  LoginBloc(
    this._googleLoginUseCase,
    this._naverLoginUseCase,
    this._completeSocialSignupUseCase,
    this._getLatestTermsUseCase,
    this._authBloc,
    this._emailPasswordLoginUseCase,
  ) : super(const LoginInitial()) {
    on<GoogleLoginRequested>(_onGoogleLoginRequested);
    on<NaverLoginRequested>(_onNaverLoginRequested);
    on<TermsAccepted>(_onTermsAccepted);
    on<SignOutRequested>(_onSignOutRequested);
    on<EmailPasswordLoginRequested>(_onEmailPasswordLoginRequested);
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

      final auth = googleUser.authentication;
      final idToken = auth.idToken;

      if (idToken == null) {
        emit(const LoginFailure(message: 'Google ID 토큰을 가져올 수 없습니다.'));
        return;
      }

      final result = await _googleLoginUseCase(idToken);
      if (result is Success<SocialLoginResultEntity>) {
        final socialLoginResult = result.data;

        if (socialLoginResult is ExistingUserEntity) {
          _authBloc.add(
            LoggedIn(
              token: socialLoginResult.loginResponse.token,
              user: socialLoginResult.loginResponse.user,
            ),
          );
        } else if (socialLoginResult is NewUserEntity) {
          final termsResult = await _getLatestTermsUseCase();
          if (termsResult is Success<LatestTermsEntity>) {
            emit(
              LoginRequiresTermsAgreement(
                tempToken: socialLoginResult.tempToken,
                latestTerms: termsResult.data,
              ),
            );
          } else {
            emit(LoginFailure(message: (termsResult as Error).message));
          }
        }
      } else {
        emit(
          LoginFailure(
            message: (result as Error<SocialLoginResultEntity>).message,
          ),
        );
      }
    } catch (e) {
      emit(const LoginFailure(message: '로그인 중 오류가 발생했습니다.'));
    }
  }

  Future<void> _onNaverLoginRequested(
    NaverLoginRequested event,
    Emitter<LoginState> emit,
  ) async {
    if (state is LoginLoading) return;

    emit(const LoginLoading());
    try {
      final naverUser = await FlutterNaverLogin.logIn();

      if (naverUser.status != NaverLoginStatus.loggedIn) {
        // User cancelled the sign-in or failed
        emit(const LoginInitial());
        return;
      }

      final accessToken = naverUser.accessToken?.accessToken;

      if (accessToken == null) {
        emit(const LoginFailure(message: '네이버 액세스 토큰을 가져올 수 없습니다.'));
        return;
      }
      final result = await _naverLoginUseCase(accessToken);
      if (result is Success<SocialLoginResultEntity>) {
        final socialLoginResult = result.data;

        if (socialLoginResult is ExistingUserEntity) {
          _authBloc.add(
            LoggedIn(
              token: socialLoginResult.loginResponse.token,
              user: socialLoginResult.loginResponse.user,
            ),
          );
        } else if (socialLoginResult is NewUserEntity) {
          final termsResult = await _getLatestTermsUseCase();
          if (termsResult is Success<LatestTermsEntity>) {
            emit(
              LoginRequiresTermsAgreement(
                tempToken: socialLoginResult.tempToken,
                latestTerms: termsResult.data,
              ),
            );
          } else {
            emit(LoginFailure(message: (termsResult as Error).message));
          }
        }
      } else {
        emit(
          LoginFailure(
            message: (result as Error<SocialLoginResultEntity>).message,
          ),
        );
      }
    } catch (e) {
      emit(const LoginFailure(message: '로그인 중 오류가 발생했습니다.'));
    }
  }

  Future<void> _onTermsAccepted(
    TermsAccepted event,
    Emitter<LoginState> emit,
  ) async {
    if (state is LoginRequiresTermsAgreement) {
      final tempToken = (state as LoginRequiresTermsAgreement).tempToken;
      emit(const LoginLoading());

      final result = await _completeSocialSignupUseCase(
        tempToken: tempToken,
        agreedTermsIds: event.agreedTermsIds,
      );

      if (result is Success<LoginResponseEntity>) {
        final loginResponse = result.data;
        _authBloc.add(
          LoggedIn(token: loginResponse.token, user: loginResponse.user),
        );
      } else {
        emit(
          LoginFailure(message: (result as Error<LoginResponseEntity>).message),
        );
      }
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<LoginState> emit,
  ) async {
    // Also ensure initialization before sign-out, in case it's called standalone
    await _initializeIfNeeded();
    await _googleSignIn.signOut();
    await FlutterNaverLogin.logOut();
    _authBloc.add(const LoggedOut()); // Notify AuthBloc
  }

  Future<void> _onEmailPasswordLoginRequested(
    EmailPasswordLoginRequested event,
    Emitter<LoginState> emit,
  ) async {
    if (state is LoginLoading) return;

    emit(const LoginLoading());
    final result = await _emailPasswordLoginUseCase(
      event.email,
      event.password,
    );

    if (result is Success<LoginResponseEntity>) {
      _authBloc.add(LoggedIn(token: result.data.token, user: result.data.user));
    } else if (result is Error<LoginResponseEntity>) {
      emit(LoginFailure(message: result.message));
    }
  }
}
