// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:chungyak_box/data/datasources/api_services.dart' as _i879;
import 'package:chungyak_box/data/repositories/calculator_repository_impl.dart'
    as _i277;
import 'package:chungyak_box/domain/repositories/calculator_repository.dart'
    as _i823;
import 'package:chungyak_box/domain/usecases/generate_payment_schedule_use_case.dart'
    as _i344;
import 'package:chungyak_box/domain/usecases/recalculate_schedule_use_case.dart'
    as _i204;
import 'package:chungyak_box/presentation/viewmodels/calculator_bloc.dart'
    as _i365;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i879.ApiServices>(() => _i879.ApiServices());
    gh.lazySingleton<_i823.CalculatorRepository>(
      () => _i277.CalculatorRepositoryImpl(gh<_i879.ApiServices>()),
    );
    gh.factory<_i344.GeneratePaymentScheduleUseCase>(
      () => _i344.GeneratePaymentScheduleUseCase(
        gh<_i823.CalculatorRepository>(),
      ),
    );
    gh.factory<_i204.RecalculateScheduleUseCase>(
      () => _i204.RecalculateScheduleUseCase(gh<_i823.CalculatorRepository>()),
    );
    gh.factory<_i365.CalculatorBloc>(
      () => _i365.CalculatorBloc(
        gh<_i344.GeneratePaymentScheduleUseCase>(),
        gh<_i204.RecalculateScheduleUseCase>(),
      ),
    );
    return this;
  }
}
