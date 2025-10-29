import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chungyak_box/presentation/viewmodels/calculator_event.dart';
import 'package:chungyak_box/presentation/viewmodels/calculator_state.dart';
import 'package:chungyak_box/domain/usecases/generate_payment_schedule_use_case.dart';
import 'package:chungyak_box/domain/usecases/recalculate_schedule_use_case.dart';
import 'package:chungyak_box/core/result.dart';
import 'package:injectable/injectable.dart';

@injectable
class CalculatorBloc extends Bloc<CalculatorEvent, CalculatorState> {
  final GeneratePaymentScheduleUseCase _generatePaymentScheduleUseCase;
  final RecalculateScheduleUseCase _recalculateScheduleUseCase;

  CalculatorBloc(
    this._generatePaymentScheduleUseCase,
    this._recalculateScheduleUseCase,
  ) : super(CalculatorInitial()) {
    on<OpenDateChanged>(_onOpenDateChanged);
    on<EndDateChanged>(_onEndDateChanged);
    on<GenerateSchedule>(_onGenerateSchedule);
    on<RecalculateSchedule>(_onRecalculateSchedule);
  }

  void _onOpenDateChanged(OpenDateChanged event, Emitter<CalculatorState> emit) {
    emit(CalculatorInitial(openDate: event.date, endDate: state.endDate));
  }

  void _onEndDateChanged(EndDateChanged event, Emitter<CalculatorState> emit) {
    emit(CalculatorInitial(openDate: state.openDate, endDate: event.date));
  }

  Future<void> _onGenerateSchedule(
    GenerateSchedule event,
    Emitter<CalculatorState> emit,
  ) async {
    emit(CalculatorLoading(openDate: event.openDate, endDate: event.endDate));
    final result = await _generatePaymentScheduleUseCase(
      event.openDate,
      event.dueDay,
      event.endDate,
    );

    if (result is Success) {
      emit(CalculatorLoaded((result as Success).data, openDate: event.openDate, endDate: event.endDate));
    } else {
      emit(CalculatorError((result as Error).message, openDate: event.openDate, endDate: event.endDate));
    }
  }

  Future<void> _onRecalculateSchedule(
    RecalculateSchedule event,
    Emitter<CalculatorState> emit,
  ) async {
    emit(CalculatorLoading(openDate: event.openDate, endDate: event.endDate));
    final result = await _recalculateScheduleUseCase(
      event.openDate,
      event.endDate,
      event.schedule,
    );

    if (result is Success) {
      emit(CalculatorLoaded((result as Success).data, openDate: event.openDate, endDate: event.endDate));
    } else {
      emit(CalculatorError((result as Error).message, openDate: event.openDate, endDate: event.endDate));
    }
  }
}
