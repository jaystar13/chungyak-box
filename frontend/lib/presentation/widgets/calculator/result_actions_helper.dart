import 'dart:math' as math;

import 'package:chungyak_box/domain/entities/custom_payment_input_entity.dart';
import 'package:chungyak_box/domain/entities/recognition_calculation_result_entity.dart';
import 'package:chungyak_box/domain/entities/recognition_calculator_request_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum ResultAction {
  bulkChange,
  addRound,
}

class ResultActionsHelper {
  static Future<ResultAction?> showActionSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return showModalBottomSheet<ResultAction>(
      context: context,
      showDragHandle: true,
      backgroundColor: colorScheme.surface,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    Icons.edit_calendar_outlined,
                    color: colorScheme.primary,
                  ),
                  title: Text('일괄변경', style: textTheme.titleMedium),
                  subtitle: Text(
                    '회차별 정보를 한 번에 수정할게요.',
                    style: textTheme.bodySmall,
                  ),
                  onTap: () => Navigator.of(bottomSheetContext).pop(
                    ResultAction.bulkChange,
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.playlist_add,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  title: Text('회차추가', style: textTheme.titleMedium),
                  subtitle: Text(
                    '현재 계산 내역에 다음 회차를 추가해요.',
                    style: textTheme.bodySmall,
                  ),
                  onTap: () => Navigator.of(bottomSheetContext).pop(
                    ResultAction.addRound,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static RecognitionCalculatorRequestEntity? buildAddRoundRequest(
    RecognitionCalculationResultEntity resultEntity,
  ) {
    if (resultEntity.details.isEmpty) {
      return null;
    }

    final sortedRecords = List.from(resultEntity.details)
      ..sort((a, b) => a.installmentNo.compareTo(b.installmentNo));

    final lastRecord = sortedRecords.last;
    final nextInstallmentNo = lastRecord.installmentNo + 1;
    final nextDueDate = _addMonths(lastRecord.dueDate);
    final nextPaidDate =
        lastRecord.paidDate != null ? _addMonths(lastRecord.paidDate!) : nextDueDate;

    final updatedPayments = [
      ...sortedRecords.map(
        (record) => CustomPaymentInputEntity(
          installmentNo: record.installmentNo,
          paidDate: record.paidDate ?? record.dueDate,
          paidAmount: record.paidAmount,
        ),
      ),
      CustomPaymentInputEntity(
        installmentNo: nextInstallmentNo,
        paidDate: nextPaidDate,
        paidAmount: lastRecord.paidAmount,
      ),
    ];

    return RecognitionCalculatorRequestEntity(
      paymentDay: resultEntity.paymentDay,
      startDate: resultEntity.startDate,
      endDate: _addMonths(resultEntity.endDate),
      paymentAmountOption: 'custom',
      standardPaymentAmount: null,
      payments: updatedPayments,
    );
  }

  static DateTime _addMonths(DateTime base, [int months = 1]) {
    final totalMonths = base.month + months;
    final yearOffset = (totalMonths - 1) ~/ 12;
    final targetYear = base.year + yearOffset;
    final targetMonth = ((totalMonths - 1) % 12) + 1;
    final lastDayInMonth = DateUtils.getDaysInMonth(targetYear, targetMonth);
    final targetDay = math.min(base.day, lastDayInMonth);
    return DateTime(targetYear, targetMonth, targetDay);
  }
}
