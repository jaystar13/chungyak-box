import 'package:chungyak_box/domain/usecases/save_housing_subscription_detail_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chungyak_box/presentation/viewmodels/calculator_event.dart';
import 'package:chungyak_box/presentation/viewmodels/calculator_state.dart';
import 'package:chungyak_box/domain/usecases/calculate_recognition_use_case.dart';
import 'package:chungyak_box/core/result.dart';
import 'package:injectable/injectable.dart';

@injectable
class CalculatorBloc extends Bloc<CalculatorEvent, CalculatorState> {
  final CalculateRecognitionUseCase _calculateRecognitionUseCase;
  final SaveHousingSubscriptionDetailUseCase
  _saveHousingSubscriptionDetailUseCase;

  CalculatorBloc(
    this._calculateRecognitionUseCase,
    this._saveHousingSubscriptionDetailUseCase,
  ) : super(CalculatorInitial()) {
    on<OpenDateChanged>(_onOpenDateChanged);
    on<EndDateChanged>(_onEndDateChanged);
    on<GenerateInitialResult>(_onGenerateInitialResult);
    on<CalculateRecognition>(_onCalculateRecognition);
    on<SaveCalculationResult>(_onSaveCalculationResult);
    on<CalculationStateReset>(_onCalculationStateReset);
  }

  void _onCalculationStateReset(
    CalculationStateReset event,
    Emitter<CalculatorState> emit,
  ) {
    if (state is CalculatorAuthRequired) {
      final currentState = state as CalculatorAuthRequired;
      emit(RecognitionCalculated(currentState.result));
    }
  }

  void _onOpenDateChanged(
    OpenDateChanged event,
    Emitter<CalculatorState> emit,
  ) {
    emit(CalculatorInitial(openDate: event.date, endDate: state.endDate));
  }

  void _onEndDateChanged(EndDateChanged event, Emitter<CalculatorState> emit) {
    emit(CalculatorInitial(openDate: state.openDate, endDate: event.date));
  }

  Future<void> _onGenerateInitialResult(
    GenerateInitialResult event,
    Emitter<CalculatorState> emit,
  ) async {
    final requestStartDate = event.requestEntity.startDate;
    final requestEndDate = event.requestEntity.endDate;

    emit(
      CalculatorLoading(openDate: requestStartDate, endDate: requestEndDate),
    );
    final result = await _calculateRecognitionUseCase(event.requestEntity);

    if (result is Success) {
      emit(
        InitialCalculationSuccess(
          (result as Success).data,
          openDate: requestStartDate,
          endDate: requestEndDate,
        ),
      );
    } else {
      emit(
        CalculatorError(
          (result as Error).message,
          openDate: requestStartDate,
          endDate: requestEndDate,
        ),
      );
    }
  }

  Future<void> _onCalculateRecognition(
    CalculateRecognition event,
    Emitter<CalculatorState> emit,
  ) async {
    final requestStartDate = event.requestEntity.startDate;
    final requestEndDate = event.requestEntity.endDate;

    emit(
      CalculatorLoading(openDate: requestStartDate, endDate: requestEndDate),
    );
    final result = await _calculateRecognitionUseCase(event.requestEntity);

    if (result is Success) {
      emit(
        RecognitionCalculated(
          (result as Success).data,
          openDate: requestStartDate,
          endDate: requestEndDate,
        ),
      );
    } else {
      emit(
        CalculatorError(
          (result as Error).message,
          openDate: requestStartDate,
          endDate: requestEndDate,
        ),
      );
    }
  }

  Future<void> _onSaveCalculationResult(
    SaveCalculationResult event,
    Emitter<CalculatorState> emit,
  ) async {
    emit(CalculatorSaving());
    final result = await _saveHousingSubscriptionDetailUseCase(event.result);

    if (result is Success) {
      emit(CalculatorSaveSuccess());
    } else if (result is Error && (result).message == "AUTH_REQUIRED") {
      emit(CalculatorAuthRequired(event.result));
    } else {
      emit(CalculatorSaveError((result as Error).message));
    }
  }
}
