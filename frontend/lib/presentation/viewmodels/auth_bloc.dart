import 'package:chungyak_box/domain/usecases/delete_account_use_case.dart'; // Import DeleteAccountUseCase
import 'package:chungyak_box/domain/usecases/verify_token_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:chungyak_box/core/result.dart';
import 'package:chungyak_box/domain/entities/user_entity.dart'; // Import UserEntity

import 'auth_event.dart';
import 'auth_state.dart';

@LazySingleton() // AuthBloc should be a singleton as it manages global state
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FlutterSecureStorage _secureStorage;
  final VerifyTokenUseCase _verifyTokenUseCase;
  final DeleteAccountUseCase _deleteAccountUseCase; // Inject DeleteAccountUseCase

  AuthBloc(
    this._secureStorage,
    this._verifyTokenUseCase,
    this._deleteAccountUseCase, // Initialize DeleteAccountUseCase
  ) : super(const AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoggedIn>(_onLoggedIn);
    on<LoggedOut>(_onLoggedOut);
    on<DeleteAccount>(_onDeleteAccount); // Add handler for DeleteAccount event
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await _verifyTokenUseCase();
    if (result is Success<UserEntity>) {
      final token = await _secureStorage.read(key: 'jwt_token');
      if (token != null) {
        emit(Authenticated(token: token, user: result.data));
      } else {
        // This case should ideally not happen if verifyToken succeeded.
        // If it does, it implies a logic error or storage issue.
        emit(const Unauthenticated());
      }
    } else {
      emit(const Unauthenticated());
    }
  }

  Future<void> _onLoggedIn(LoggedIn event, Emitter<AuthState> emit) async {
    await _secureStorage.delete(key: 'jwt_token');
    await _secureStorage.write(key: 'jwt_token', value: event.token);
    emit(Authenticated(token: event.token, user: event.user));
  }

  Future<void> _onLoggedOut(LoggedOut event, Emitter<AuthState> emit) async {
    await _secureStorage.delete(key: 'jwt_token');
    emit(const Unauthenticated());
  }

  Future<void> _onDeleteAccount(DeleteAccount event, Emitter<AuthState> emit) async {
    emit(const AuthLoading()); // Indicate loading
    final result = await _deleteAccountUseCase();
    if (result is Success<void>) {
      emit(const AccountDeletionSuccess()); // Account deleted, emit specific success state
    } else if (result is Error<void>) {
      emit(AuthError(result.message)); // Emit error state
    }
  }
}
