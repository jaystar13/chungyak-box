import 'package:chungyak_box/data/models/payment_model.dart';
import 'package:chungyak_box/data/models/payment_schedule_model.dart';
import 'package:chungyak_box/domain/entities/payment_entity.dart';
import 'package:chungyak_box/domain/entities/payment_schedule_entity.dart';

extension PaymentMapper on PaymentModel {
  PaymentEntity toEntity() {
    return PaymentEntity(
      installmentNo: installmentNo,
      dueDate: dueDate,
      paidDate: paidDate,
      delayDays: delayDays,
      totalDelayDays: totalDelayDays,
      prepaidDays: prepaidDays,
      totalPrepaidDays: totalPrepaidDays,
      recognizedDate: recognizedDate,
      isRecognized: isRecognized,
    );
  }
}

extension PaymentScheduleMapper on PaymentScheduleModel {
  PaymentScheduleEntity toEntity() {
    return PaymentScheduleEntity(
      totalInstallments: totalInstallments,
      totalDelayDays: totalDelayDays,
      totalPrepaidDays: totalPrepaidDays,
      payments: payments.map((e) => e.toEntity()).toList(),
    );
  }
}

extension PaymentEntityMapper on PaymentEntity {
  PaymentModel toModel() {
    return PaymentModel(
      installmentNo: installmentNo,
      dueDate: dueDate,
      paidDate: paidDate,
      delayDays: delayDays,
      totalDelayDays: totalDelayDays,
      prepaidDays: prepaidDays,
      totalPrepaidDays: totalPrepaidDays,
      recognizedDate: recognizedDate,
      isRecognized: isRecognized,
    );
  }
}

extension PaymentScheduleEntityMapper on PaymentScheduleEntity {
  PaymentScheduleModel toModel() {
    return PaymentScheduleModel(
      totalInstallments: totalInstallments,
      totalDelayDays: totalDelayDays,
      totalPrepaidDays: totalPrepaidDays,
      payments: payments.map((e) => e.toModel()).toList(),
    );
  }
}
