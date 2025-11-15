import 'package:chungyak_box/data/models/recognition_calculator_request_model.dart';
import 'package:chungyak_box/data/models/recognition_calculation_result_model.dart';
import 'package:chungyak_box/domain/entities/custom_payment_input_entity.dart';
import 'package:chungyak_box/domain/entities/recognition_calculator_request_entity.dart';
import 'package:chungyak_box/domain/entities/recognition_calculation_result_entity.dart';
import 'package:chungyak_box/domain/entities/recognition_round_record_entity.dart';

extension CustomPaymentInputMapper on CustomPaymentInputModel {
  CustomPaymentInputEntity toEntity() {
    return CustomPaymentInputEntity(
      installmentNo: installmentNo,
      paidDate: DateTime.parse(paidDate),
      paidAmount: paidAmount,
    );
  }
}

extension CustomPaymentInputEntityMapper on CustomPaymentInputEntity {
  CustomPaymentInputModel toModel() {
    return CustomPaymentInputModel(
      installmentNo: installmentNo,
      paidDate: paidDate.toIso8601String().split('T').first,
      paidAmount: paidAmount,
    );
  }
}

extension RecognitionCalculatorRequestMapper on RecognitionCalculatorRequestModel {
  RecognitionCalculatorRequestEntity toEntity() {
    return RecognitionCalculatorRequestEntity(
      paymentDay: paymentDay,
      startDate: DateTime.parse(startDate),
      endDate: DateTime.parse(endDate),
      paymentAmountOption: paymentAmountOption,
      standardPaymentAmount: standardPaymentAmount,
      payments: payments?.map((e) => e.toEntity()).toList(),
    );
  }
}

extension RecognitionCalculatorRequestEntityMapper on RecognitionCalculatorRequestEntity {
  RecognitionCalculatorRequestModel toModel() {
    return RecognitionCalculatorRequestModel(
      paymentDay: paymentDay,
      startDate: startDate.toIso8601String().split('T').first,
      endDate: endDate.toIso8601String().split('T').first,
      paymentAmountOption: paymentAmountOption,
      standardPaymentAmount: standardPaymentAmount,
      payments: payments?.map((e) => e.toModel()).toList(),
    );
  }
}

extension RecognitionRoundRecordMapper on RecognitionRoundRecordModel {
  RecognitionRoundRecordEntity toEntity() {
    return RecognitionRoundRecordEntity(
      installmentNo: installmentNo,
      dueDate: DateTime.parse(dueDate),
      paidDate: DateTime.parse(paidDate),
      recognizedDate: DateTime.parse(recognizedDate),
      delayDays: delayDays,
      totalDelayDays: totalDelayDays,
      prepaidDays: prepaidDays,
      totalPrepaidDays: totalPrepaidDays,
      status: status,
      isRecognized: isRecognized,
      paidAmount: paidAmount,
      recognizedAmountForRound: recognizedAmountForRound,
    );
  }
}

extension RecognitionCalculationResultMapper on RecognitionCalculationResultModel {
  RecognitionCalculationResultEntity toEntity() {
    return RecognitionCalculationResultEntity(
      paymentDay: paymentDay,
      startDate: DateTime.parse(startDate),
      endDate: DateTime.parse(endDate),
      recognizedRounds: recognizedRounds,
      unrecognizedRounds: unrecognizedRounds,
      totalRecognizedAmount: totalRecognizedAmount,
      details: details.map((e) => e.toEntity()).toList(),
    );
  }
}
