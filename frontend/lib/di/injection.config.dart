// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:chungyak_box/data/datasources/api_services.dart' as _i879;
import 'package:chungyak_box/data/mapper/login_response_mapper.dart' as _i839;
import 'package:chungyak_box/data/mapper/user_mapper.dart' as _i409;
import 'package:chungyak_box/data/repositories/auth_repository_impl.dart'
    as _i242;
import 'package:chungyak_box/data/repositories/calculator_repository_impl.dart'
    as _i277;
import 'package:chungyak_box/di/register_module.dart' as _i717;
import 'package:chungyak_box/domain/repositories/auth_repository.dart' as _i133;
import 'package:chungyak_box/domain/repositories/calculator_repository.dart'
    as _i823;
import 'package:chungyak_box/domain/usecases/calculate_recognition_use_case.dart'
    as _i61;
import 'package:chungyak_box/domain/usecases/generate_payment_schedule_use_case.dart'
    as _i344;
import 'package:chungyak_box/domain/usecases/google_login_use_case.dart'
    as _i257;
import 'package:chungyak_box/domain/usecases/recalculate_schedule_use_case.dart'
    as _i204;
import 'package:chungyak_box/domain/usecases/verify_token_use_case.dart'
    as _i252;
import 'package:chungyak_box/presentation/viewmodels/auth_bloc.dart' as _i331;
import 'package:chungyak_box/presentation/viewmodels/calculator_bloc.dart'
    as _i365;
import 'package:chungyak_box/presentation/viewmodels/login_bloc.dart' as _i662;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.factory<_i409.UserMapper>(() => _i409.UserMapper());
    gh.lazySingleton<_i879.ApiServices>(() => _i879.ApiServices());
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => registerModule.secureStorage,
    );
    gh.factory<_i839.LoginResponseMapper>(
      () => _i839.LoginResponseMapper(gh<_i409.UserMapper>()),
    );
    gh.lazySingleton<_i133.AuthRepository>(
      () => _i242.AuthRepositoryImpl(
        gh<_i879.ApiServices>(),
        gh<_i558.FlutterSecureStorage>(),
        gh<_i409.UserMapper>(),
        gh<_i839.LoginResponseMapper>(),
      ),
    );
    gh.lazySingleton<_i823.CalculatorRepository>(
      () => _i277.CalculatorRepositoryImpl(gh<_i879.ApiServices>()),
    );
    gh.factory<_i61.CalculateRecognitionUseCase>(
      () => _i61.CalculateRecognitionUseCase(gh<_i823.CalculatorRepository>()),
    );
    gh.factory<_i344.GeneratePaymentScheduleUseCase>(
      () => _i344.GeneratePaymentScheduleUseCase(
        gh<_i823.CalculatorRepository>(),
      ),
    );
    gh.factory<_i204.RecalculateScheduleUseCase>(
      () => _i204.RecalculateScheduleUseCase(gh<_i823.CalculatorRepository>()),
    );
    gh.factory<_i257.GoogleLoginUseCase>(
      () => _i257.GoogleLoginUseCase(gh<_i133.AuthRepository>()),
    );
    gh.factory<_i252.VerifyTokenUseCase>(
      () => _i252.VerifyTokenUseCase(gh<_i133.AuthRepository>()),
    );
    gh.factory<_i365.CalculatorBloc>(
      () => _i365.CalculatorBloc(
        gh<_i344.GeneratePaymentScheduleUseCase>(),
        gh<_i204.RecalculateScheduleUseCase>(),
        gh<_i61.CalculateRecognitionUseCase>(),
      ),
    );
    gh.lazySingleton<_i331.AuthBloc>(
      () => _i331.AuthBloc(
        gh<_i558.FlutterSecureStorage>(),
        gh<_i252.VerifyTokenUseCase>(),
      ),
    );
    gh.factory<_i662.LoginBloc>(
      () =>
          _i662.LoginBloc(gh<_i257.GoogleLoginUseCase>(), gh<_i331.AuthBloc>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i717.RegisterModule {}
