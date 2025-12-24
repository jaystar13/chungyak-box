import 'package:chungyak_box/domain/entities/recognition_calculation_result_entity.dart';
import 'package:chungyak_box/domain/entities/recognition_calculator_request_entity.dart';
import 'package:chungyak_box/domain/entities/recognition_round_record_entity.dart';
import 'package:chungyak_box/presentation/widgets/payment_detail_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class YearlySummary {
  final String year;
  final List<MonthlyDetail> monthlyDetails;

  YearlySummary({required this.year, required this.monthlyDetails});
}

class MonthlyDetail {
  final RecognitionRoundRecordEntity recordEntity;

  MonthlyDetail({required this.recordEntity});
}

List<YearlySummary> buildYearlySummaries(
  List<RecognitionRoundRecordEntity> details, {
  required bool isSortAscending,
}) {
  final Map<int, List<MonthlyDetail>> groupedByYear = {};
  for (var record in details) {
    final year = record.dueDate.year;
    groupedByYear
        .putIfAbsent(year, () => [])
        .add(MonthlyDetail(recordEntity: record));
  }

  final yearlySummaries = groupedByYear.entries.map((entry) {
    return YearlySummary(
      year: entry.key.toString(),
      monthlyDetails: entry.value,
    );
  }).toList();

  yearlySummaries.sort((a, b) {
    if (isSortAscending) {
      return int.parse(a.year).compareTo(int.parse(b.year));
    } else {
      return int.parse(b.year).compareTo(int.parse(a.year));
    }
  });

  return yearlySummaries;
}

class DetailedHistoryList extends StatelessWidget {
  final List<YearlySummary> summaries;
  final RecognitionCalculationResultEntity resultEntity;
  final Future<RecognitionCalculationResultEntity> Function(
    RecognitionCalculatorRequestEntity request,
  ) onRecalculate;

  const DetailedHistoryList({
    super.key,
    required this.summaries,
    required this.resultEntity,
    required this.onRecalculate,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListView.builder(
      itemCount: summaries.length,
      itemBuilder: (context, index) {
        final summary = summaries[index];
        final expandAll = summaries.length == 1;
        final yearlyRecognizedRounds = summary.monthlyDetails
            .where((d) => d.recordEntity.isRecognized)
            .length;
        final yearlyTotalAmount = summary.monthlyDetails.fold<int>(
          0,
          (sum, d) => sum + d.recordEntity.recognizedAmountForRound,
        );

        final yearlyUnrecognizedRounds = summary.monthlyDetails
            .where((d) => !d.recordEntity.isRecognized)
            .length;

        return ExpansionTile(
          tilePadding: EdgeInsets.zero,
          shape: Border.all(color: Colors.transparent),
          collapsedShape: Border.all(color: Colors.transparent),
          initiallyExpanded: expandAll,
          leading: Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.secondaryContainer,
            ),
            child: Text(
              summary.year,
              style: textTheme.bodyLarge!.copyWith(
                color: colorScheme.onSecondaryContainer,
                fontSize: 14.sp,
              ),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '인정금액 ${NumberFormat('#,###').format(yearlyTotalAmount)}원 ($yearlyRecognizedRounds회)',
                style: textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Text(
                  yearlyUnrecognizedRounds > 0
                      ? '미인정회차 $yearlyUnrecognizedRounds회 있음'
                      : '미인정회차 없음',
                  style: textTheme.bodyMedium!.copyWith(
                    color: yearlyUnrecognizedRounds > 0
                        ? colorScheme.error
                        : colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          children: summary.monthlyDetails.map((detail) {
            return _MonthlyDetailRow(
              detail: detail,
              resultEntity: resultEntity,
              onRecalculate: onRecalculate,
            );
          }).toList(),
        );
      },
    );
  }
}

class _MonthlyDetailRow extends StatelessWidget {
  final MonthlyDetail detail;
  final RecognitionCalculationResultEntity resultEntity;
  final Future<RecognitionCalculationResultEntity> Function(
    RecognitionCalculatorRequestEntity request,
  ) onRecalculate;

  const _MonthlyDetailRow({
    required this.detail,
    required this.resultEntity,
    required this.onRecalculate,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final record = detail.recordEntity;

    return Padding(
      padding: EdgeInsets.only(left: 16.w, top: 8.h, bottom: 8.h),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  record.installmentNo.toString().padLeft(2, '0'),
                  style: textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${record.dueDate.month}월',
                  style: textTheme.bodySmall!.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    style: textTheme.bodyMedium!.copyWith(fontSize: 13.sp),
                    children: [
                      TextSpan(
                        text: record.status,
                        style: TextStyle(
                          color: record.status == '지연'
                              ? colorScheme.error
                              : record.status == '선납'
                                  ? colorScheme.tertiary
                                  : record.status == '미납'
                                      ? colorScheme.error
                                      : colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: ' / '),
                      TextSpan(
                        text: _recognitionStatus(record),
                        style: textTheme.bodyMedium!.copyWith(
                          color: record.isRecognized
                              ? colorScheme.primary
                              : colorScheme.error,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${NumberFormat('#,###').format(record.paidAmount)}원',
                  style: textTheme.bodyMedium!.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              PaymentDetailBottomSheet.show(
                context,
                record: record,
                resultEntity: resultEntity,
                onRecalculate: onRecalculate,
              );
            },
            child: const Icon(Icons.more_horiz),
          ),
        ],
      ),
    );
  }

  String _recognitionStatus(RecognitionRoundRecordEntity record) {
    if (record.isRecognized) {
      return '회차인정';
    }

    if (record.recognizedDate == null) {
      return '회차미인정';
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysRemaining = record.recognizedDate!.difference(today).inDays;

    if (daysRemaining > 0) {
      return '회차미인정(D-$daysRemaining일)';
    }

    return '회차미인정';
  }
}
