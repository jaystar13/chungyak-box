import 'package:chungyak_box/data/datasources/admob_services.dart';
import 'package:chungyak_box/domain/entities/recognition_calculation_result_entity.dart';
import 'package:chungyak_box/domain/entities/recognition_round_record_entity.dart';
import 'package:chungyak_box/presentation/viewmodels/calculator_bloc.dart';
import 'package:chungyak_box/presentation/viewmodels/calculator_state.dart';
import 'package:chungyak_box/presentation/widgets/payment_detail_bottom_sheet.dart';
import 'package:chungyak_box/presentation/widgets/calculator/bulk_change_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

// Helper class to hold transformed data for yearly summary display
class YearlySummary {
  final String year;
  final List<MonthlyDetail> monthlyDetails;

  YearlySummary({required this.year, required this.monthlyDetails});
}

// Helper class to hold transformed data for monthly detail display
class MonthlyDetail {
  final RecognitionRoundRecordEntity recordEntity;

  MonthlyDetail({required this.recordEntity});
}

class CalculatorResultMobileBody extends StatefulWidget {
  const CalculatorResultMobileBody({super.key});

  @override
  State<CalculatorResultMobileBody> createState() =>
      _CalculatorResultMobileBodyState();
}

class _CalculatorResultMobileBodyState
    extends State<CalculatorResultMobileBody> {
  bool _showNotification = true;
  bool _isSortAscending = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final Object? arguments = ModalRoute.of(context)!.settings.arguments;

    return BlocBuilder<CalculatorBloc, CalculatorState>(
      builder: (context, state) {
        // Determine the result entity: use the one from the state if available,
        // otherwise fall back to the initial arguments.
        final RecognitionCalculationResultEntity resultEntity;
        if (state is RecognitionCalculated) {
          resultEntity = state.result;
        } else if (arguments is RecognitionCalculationResultEntity) {
          resultEntity = arguments;
        } else {
          // Handle case where arguments are not passed or state is not what we expect
          return Scaffold(
            appBar: AppBar(title: const Text('계산 결과')),
            body: const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '결과 데이터를 불러오는 데 실패했습니다.\n이전 화면에서 다시 시도해주세요.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        // Create a mutable, sorted list of details
        final sortedDetails = List<RecognitionRoundRecordEntity>.from(
          resultEntity.details,
        );
        sortedDetails.sort((a, b) {
          if (_isSortAscending) {
            return a.installmentNo.compareTo(b.installmentNo);
          } else {
            return b.installmentNo.compareTo(a.installmentNo);
          }
        });

        // Transform sortedDetails into List<YearlySummary>
        final Map<int, List<MonthlyDetail>> groupedByYear = {};
        for (var record in sortedDetails) {
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

        // Sort yearly summaries by year
        yearlySummaries.sort((a, b) {
          if (_isSortAscending) {
            return int.parse(a.year).compareTo(int.parse(b.year));
          } else {
            return int.parse(b.year).compareTo(int.parse(a.year));
          }
        });

        return BlocListener<CalculatorBloc, CalculatorState>(
          listener: (context, state) {
            if (state is CalculatorLoading) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(const SnackBar(content: Text('재계산 중...')));
            } else if (state is RecognitionCalculated) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            } else if (state is CalculatorError) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text('오류: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('계산 결과'),
              centerTitle: true,
              backgroundColor: colorScheme.primaryContainer,
            ),
            body: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '계산 요약',
                        style: textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          Icons.info_outline,
                          size: 24.sp,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        onPressed: () => _showCalculationInfoDialog(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.5),
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${DateFormat('yyyy.MM').format(resultEntity.startDate)} ~ ${DateFormat('yyyy.MM').format(resultEntity.endDate)} 매월${resultEntity.paymentDay}일',
                                style: textTheme.bodyMedium,
                              ),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          '${NumberFormat('#,###').format(resultEntity.totalRecognizedAmount)}원',
                                      style: textTheme.titleLarge!.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          ' (${resultEntity.recognizedRounds}회차)',
                                      style: textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              _buildUnrecognizedRoundsInfo(
                                resultEntity.unrecognizedRounds,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 36.w,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  if (_showNotification)
                    Dismissible(
                      key: const ValueKey('payment_date_notification'),
                      onDismissed: (direction) {
                        setState(() {
                          _showNotification = false;
                        });
                      },
                      child: Card(
                        margin: EdgeInsets.only(bottom: 12.h),
                        color: colorScheme.surfaceContainer,
                        child: Padding(
                          padding: EdgeInsets.all(6.w),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '회차별 실제납입일 및 납입금액을 확인하고 변경해 주세요.',
                                  style: textTheme.bodyMedium!.copyWith(
                                    color: colorScheme.onSecondaryContainer,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: colorScheme.onSecondaryContainer,
                                ),
                                iconSize: 18.w,
                                onPressed: () {
                                  setState(() {
                                    _showNotification = false;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            '상세 내역',
                            style: textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              Icons.swap_vert,
                              size: 24.sp,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.8,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _isSortAscending = !_isSortAscending;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        // Wrap IconButton in SizedBox for consistent tap target size
                        width: 48.w, // Standard tap target size
                        height: 48.h, // Standard tap target size
                        child: IconButton(
                          padding: EdgeInsets.zero, // Remove default padding
                          icon: Icon(Icons.edit_calendar_outlined),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => BlocProvider.value(
                                value: BlocProvider.of<CalculatorBloc>(context),
                                child: BulkChangeDialog(
                                  resultEntity: resultEntity,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  Divider(),
                  SizedBox(height: 8.h),
                  Expanded(
                    child: _buildDetailedHistory(
                      context,
                      yearlySummaries,
                      resultEntity, // Pass resultEntity
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: const SafeArea(child: BannerAdWidget()),
          ),
        );
      },
    );
  }

  Widget _buildDetailedHistory(
    BuildContext context,
    List<YearlySummary> summaries,
    RecognitionCalculationResultEntity resultEntity, // Pass resultEntity
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListView.builder(
      itemCount: summaries.length,
      itemBuilder: (context, index) {
        final summary = summaries[index];
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
              _buildUnrecognizedRoundsInfo(yearlyUnrecognizedRounds),
            ],
          ),
          children: summary.monthlyDetails.map((detail) {
            return _buildMonthlyDetailRow(
              context,
              detail,
              resultEntity, // Pass resultEntity
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildMonthlyDetailRow(
    BuildContext context,
    MonthlyDetail detail,
    RecognitionCalculationResultEntity resultEntity, // Pass resultEntity
  ) {
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
                        text:
                            '납입일 ${DateFormat('yyyy.MM.dd').format(record.paidDate)} ',
                      ),
                      TextSpan(
                        text: record.status,
                        style: TextStyle(
                          color: record.status == '지연'
                              ? colorScheme.error
                              : record.status == '선납'
                              ? colorScheme.tertiary
                              : colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text:
                            '${NumberFormat('#,###').format(record.paidAmount)}원',
                        style: textTheme.bodyMedium!.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 13.sp,
                        ),
                      ),
                      TextSpan(
                        text: () {
                          if (record.isRecognized) {
                            return ' (인정)';
                          } else {
                            final now = DateTime.now();
                            final today = DateTime(
                              now.year,
                              now.month,
                              now.day,
                            );
                            final difference = record.recognizedDate.difference(
                              today,
                            );
                            final daysRemaining = difference.inDays;

                            if (daysRemaining > 0) {
                              return ' (미인정, D-$daysRemaining일)';
                            } else {
                              return ' (미인정)'; // recognizedDate is today or in the past
                            }
                          }
                        }(),
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
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              PaymentDetailBottomSheet.show(
                context,
                record: record,
                resultEntity: resultEntity,
              );
            },
            child: Icon(Icons.more_horiz),
          ),
        ],
      ),
    );
  }

  Widget _buildUnrecognizedRoundsInfo(int unrecognizedRounds) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (unrecognizedRounds > 0) {
      return Padding(
        padding: EdgeInsets.only(top: 4.h),
        child: Text(
          '미인정회차 $unrecognizedRounds회 있음',
          style: textTheme.bodyMedium!.copyWith(color: colorScheme.error),
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.only(top: 4.h),
        child: Text('미인정회차 없음', style: textTheme.bodyMedium),
      );
    }
  }

  void _showCalculationInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("인정회차 계산 방법"),
          content: const SingleChildScrollView(
            child: Text(
              "- 계산식\n"
              "약정납입일+((연체총일수 - 선납총일수)/회차)\n\n"
              "1. 약정납입일: 매월 납입하기로 약속한 날짜\n"
              "2. 연체총일수: 실제 납입일이 약정납입일보다 늦은 경우, 그 차이의 합\n"
              "3. 선납총일수: 실제 납입일이 약정납입일보다 빠른 경우, 그 차이의 합(최대 2년, 720일)\n"
              "4. 회차: 납입해야 하는 총 회차 수\n\n"
              "예시:\n"
              "- 약정납입일: 2025-01-01\n"
              "- 실제납입일: 2026-01-01 (365일 지연납입)\n"
              "- 회차: 10회\n"
              "- 해당회차 인정일 계산식:\n"
              "2025-01-01 + ((365 - 0) / 10)\n"
              "= 2025-02-05(36.5일 지연되어 인정)\n\n"
              "이 계산기는 이러한 규칙을 적용하여 각 회차별 인정회차를 계산합니다.\n\n"
              "* 계산 결과는 참고용이며, 실제 인정회차와 다를 수 있습니다.",
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("확인"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
