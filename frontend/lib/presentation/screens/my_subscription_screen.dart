import 'dart:async';

import 'package:chungyak_box/di/injection.dart';
import 'package:chungyak_box/domain/entities/my_subscription_entity.dart';
import 'package:chungyak_box/domain/entities/recognition_calculation_result_entity.dart';
import 'package:chungyak_box/domain/entities/recognition_calculator_request_entity.dart';
import 'package:chungyak_box/domain/entities/recognition_round_record_entity.dart';
import 'package:chungyak_box/presentation/layouts/responsive_layout.dart';
import 'package:chungyak_box/presentation/viewmodels/calculator_bloc.dart';
import 'package:chungyak_box/presentation/viewmodels/calculator_event.dart';
import 'package:chungyak_box/presentation/viewmodels/calculator_state.dart';
import 'package:chungyak_box/presentation/viewmodels/my_subscription_bloc.dart';
import 'package:chungyak_box/presentation/viewmodels/my_subscription_event.dart';
import 'package:chungyak_box/presentation/viewmodels/my_subscription_state.dart';
import 'package:chungyak_box/presentation/widgets/calculator/bulk_change_dialog.dart';
import 'package:chungyak_box/presentation/widgets/calculator/detailed_history_list.dart';
import 'package:chungyak_box/presentation/widgets/calculator/result_actions_helper.dart';
import 'package:chungyak_box/presentation/widgets/payment_detail_bottom_sheet.dart';
import 'package:chungyak_box/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class MySubscriptionScreen extends StatefulWidget {
  const MySubscriptionScreen({super.key});

  @override
  State<MySubscriptionScreen> createState() => _MySubscriptionScreenState();
}

class _MySubscriptionScreenState extends State<MySubscriptionScreen> {
  bool _showNotification = true;
  bool _isSortAscending = false;
  String? _selectedYear;
  RecognitionCalculationResultEntity? _currentResult;
  int? _currentSubscriptionId;
  late final MySubscriptionBloc _mySubscriptionBloc;
  late final CalculatorBloc _calculatorBloc;

  @override
  void initState() {
    super.initState();
    _mySubscriptionBloc = getIt<MySubscriptionBloc>()
      ..add(LoadMySubscription());
    _calculatorBloc = getIt<CalculatorBloc>();
  }

  @override
  void dispose() {
    _mySubscriptionBloc.close();
    _calculatorBloc.close();
    super.dispose();
  }

  void _ensureResultInitialized(MySubscriptionEntity subscription) {
    if (_currentResult == null || _currentSubscriptionId != subscription.id) {
      _currentSubscriptionId = subscription.id;
      _currentResult = _mapSubscriptionToResult(subscription);
      _selectedYear = null;
    }
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

  Future<RecognitionCalculationResultEntity> _applyAndPersist(
    RecognitionCalculatorRequestEntity request,
  ) async {
    final updatedResult = await _requestRecalculation(request);
    await _saveResult(updatedResult);
    _mySubscriptionBloc.add(LoadMySubscription());
    return updatedResult;
  }

  Future<RecognitionCalculationResultEntity> _applyAndPersistWithFeedback(
    RecognitionCalculatorRequestEntity request,
  ) async {
    try {
      final result = await _applyAndPersist(request);
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(content: Text('청약 내역이 저장되었습니다.')));
      }
      return result;
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                '저장에 실패했습니다. 다시 시도해주세요. (${_readableError(error)})',
              ),
            ),
          );
      }
      rethrow;
    }
  }

  String _readableError(Object error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return '알 수 없는 오류';
  }

  Future<void> _saveResult(RecognitionCalculationResultEntity result) async {
    final completer = Completer<void>();
    StreamSubscription<CalculatorState>? subscription;

    subscription = _calculatorBloc.stream.listen((state) {
      if (state is CalculatorSaveSuccess) {
        if (!completer.isCompleted) {
          completer.complete();
        }
        subscription?.cancel();
      } else if (state is CalculatorSaveError) {
        if (!completer.isCompleted) {
          completer.completeError(Exception(state.message));
        }
        subscription?.cancel();
      } else if (state is CalculatorAuthRequired) {
        if (!completer.isCompleted) {
          completer.completeError(Exception('로그인이 필요합니다.'));
        }
        subscription?.cancel();
      }
    });

    _calculatorBloc.add(SaveCalculationResult(result));

    try {
      await completer.future;
    } finally {
      await subscription.cancel();
    }
  }

  Future<RecognitionCalculationResultEntity> _requestRecalculation(
    RecognitionCalculatorRequestEntity request,
  ) async {
    final completer = Completer<RecognitionCalculationResultEntity>();
    StreamSubscription<CalculatorState>? subscription;

    subscription = _calculatorBloc.stream.listen((state) {
      if (state is RecognitionCalculated) {
        if (!completer.isCompleted) {
          completer.complete(state.result);
        }
        subscription?.cancel();
      } else if (state is CalculatorError) {
        if (!completer.isCompleted) {
          completer.completeError(Exception(state.message));
        }
        subscription?.cancel();
      }
    });

    _calculatorBloc.add(CalculateRecognition(requestEntity: request));

    final result = await completer.future.whenComplete(() {
      subscription?.cancel();
    });

    if (mounted) {
      setState(() {
        _currentResult = result;
      });
    }

    return result;
  }

  RecognitionCalculationResultEntity _mapSubscriptionToResult(
    MySubscriptionEntity subscription,
  ) {
    return RecognitionCalculationResultEntity(
      paymentDay: subscription.paymentDay,
      startDate: subscription.startDate,
      endDate: subscription.endDate,
      recognizedRounds: subscription.recognizedRounds,
      unrecognizedRounds: subscription.unrecognizedRounds,
      totalRecognizedAmount: subscription.totalRecognizedAmount,
      details: subscription.details,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MySubscriptionBloc>.value(value: _mySubscriptionBloc),
        BlocProvider<CalculatorBloc>.value(value: _calculatorBloc),
      ],
      child: BlocBuilder<MySubscriptionBloc, MySubscriptionState>(
        builder: (context, state) {
          final textTheme = Theme.of(context).textTheme;
          final colorScheme = Theme.of(context).colorScheme;
          if (state is MySubscriptionLoading ||
              state is MySubscriptionInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MySubscriptionLoaded) {
            final subscription = state.subscription;
            if (subscription == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '저장된 청약 내역이 없습니다.',
                      style: textTheme.bodyMedium!.copyWith(fontSize: 16.sp),
                    ),
                    SizedBox(height: 12.h),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, Routes.calculator);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                        textStyle: textTheme.bodyMedium!.copyWith(
                          fontSize: 14.sp,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      child: const Text('청약 인정금액 계산기로 이동'),
                    ),
                  ],
                ),
              );
            }

            _ensureResultInitialized(subscription);
            final resultEntity = _currentResult!;

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

            final yearlySummaries = buildYearlySummaries(
              sortedDetails,
              isSortAscending: _isSortAscending,
            );

            final numberFormat = NumberFormat('#,###');

            if (_selectedYear == null && yearlySummaries.isNotEmpty) {
              _selectedYear = yearlySummaries.first.year;
            }

            YearlySummary? selectedYearSummary;
            for (final summary in yearlySummaries) {
              if (summary.year == _selectedYear) {
                selectedYearSummary = summary;
                break;
              }
            }

            return ResponsiveLayout(
              mobileBody: _buildMobileLayout(
                context,
                subscription,
                resultEntity,
                yearlySummaries,
                numberFormat,
                textTheme,
                colorScheme,
              ),
              tabletBody: _buildTabletLayout(
                context,
                subscription,
                resultEntity,
                yearlySummaries,
                selectedYearSummary,
                numberFormat,
              ),
            );
          } else if (state is MySubscriptionError) {
            return Center(
              child: Text(
                '오류가 발생했습니다: ${state.message}',
                style: textTheme.bodyMedium!.copyWith(
                  fontSize: 16.sp,
                  color: colorScheme.error,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    MySubscriptionEntity subscription,
    RecognitionCalculationResultEntity resultEntity,
    List<YearlySummary> yearlySummaries,
    NumberFormat numberFormat,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '계산 요약',
                    style: textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                '${DateFormat('yyyy.MM.dd HH:mm').format(subscription.createdAt)}에 저장',
                style: textTheme.bodyMedium!.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
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
                                  '${numberFormat.format(resultEntity.totalRecognizedAmount)}원',
                              style: textTheme.titleLarge!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                            TextSpan(
                              text: ' (${resultEntity.recognizedRounds}회차)',
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
              ],
            ),
          ),
          SizedBox(height: 12.h),
          if (_showNotification)
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
                        color: colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                      onPressed: () {
                        setState(() {
                          _isSortAscending = !_isSortAscending;
                          _selectedYear = null;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(
                  width: 48.w,
                  height: 48.h,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.tune, color: colorScheme.primary),
                    onPressed: () async {
                      final action = await ResultActionsHelper.showActionSheet(
                        context,
                      );

                      if (action == ResultAction.bulkChange) {
                        showDialog(
                          context: context,
                          builder: (_) => BlocProvider.value(
                            value: _calculatorBloc,
                            child: BulkChangeDialog(
                              resultEntity: resultEntity,
                              onRecalculate: _applyAndPersistWithFeedback,
                            ),
                          ),
                        );
                      } else if (action == ResultAction.addRound) {
                        final request =
                            ResultActionsHelper.buildAddRoundRequest(
                              resultEntity,
                            );
                        if (request == null) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              const SnackBar(content: Text('추가할 회차 정보가 없습니다.')),
                            );
                          return;
                        }
                        try {
                          await _applyAndPersistWithFeedback(request);
                        } catch (_) {}
                      }
                    },
                  ),
                ),
              ],
            ),
          const Divider(),
          SizedBox(height: 8.h),
          Expanded(
            child: DetailedHistoryList(
              summaries: yearlySummaries,
              resultEntity: resultEntity,
              onRecalculate: _applyAndPersistWithFeedback,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(
    BuildContext context,
    MySubscriptionEntity subscription,
    RecognitionCalculationResultEntity resultEntity,
    List<YearlySummary> yearlySummaries,
    YearlySummary? selectedYearSummary,
    NumberFormat numberFormat,
  ) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTabletSummarySection(
            context,
            subscription,
            resultEntity,
            numberFormat,
          ),
          SizedBox(height: 12.h),
          _buildTabletDetailedHistoryTitle(context, resultEntity),
          const Divider(),
          SizedBox(height: 8.h),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: _buildTabletYearList(context, yearlySummaries),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  flex: 4,
                  child: _buildTabletDetailsForYear(
                    context,
                    selectedYearSummary,
                    resultEntity,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletSummarySection(
    BuildContext context,
    MySubscriptionEntity subscription,
    RecognitionCalculationResultEntity resultEntity,
    NumberFormat numberFormat,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '계산 요약',
              style: textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${DateFormat('yyyy.MM.dd HH:mm').format(subscription.createdAt)}에 저장',
              style: textTheme.bodyMedium!.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(20.w, 12.w, 10.w, 12.w),
          decoration: BoxDecoration(
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.5),
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${DateFormat('yyyy.MM').format(resultEntity.startDate)} ~ ${DateFormat('yyyy.MM').format(resultEntity.endDate)} 매월${resultEntity.paymentDay}일',
                      style: textTheme.bodyLarge,
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text:
                                '${numberFormat.format(resultEntity.totalRecognizedAmount)}원',
                            style: textTheme.headlineSmall!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          TextSpan(
                            text: ' (${resultEntity.recognizedRounds}회차)',
                            style: textTheme.bodyLarge,
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabletDetailedHistoryTitle(
    BuildContext context,
    RecognitionCalculationResultEntity resultEntity,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.only(right: 12.w),
      child: Row(
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
                icon: Icon(
                  Icons.swap_vert,
                  size: 18.sp,
                  color: colorScheme.onSurface.withValues(alpha: 0.8),
                ),
                onPressed: () => setState(() {
                  _isSortAscending = !_isSortAscending;
                  _selectedYear = null;
                }),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.tune, size: 18.sp, color: colorScheme.primary),
            onPressed: () async {
              final action = await ResultActionsHelper.showActionSheet(context);

              if (action == ResultAction.bulkChange) {
                showDialog(
                  context: context,
                  builder: (_) => BlocProvider.value(
                    value: _calculatorBloc,
                    child: BulkChangeDialog(
                      resultEntity: resultEntity,
                      onRecalculate: _applyAndPersistWithFeedback,
                    ),
                  ),
                );
              } else if (action == ResultAction.addRound) {
                final request = ResultActionsHelper.buildAddRoundRequest(
                  resultEntity,
                );
                if (request == null) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(content: Text('추가할 회차 정보가 없습니다.')),
                    );
                  return;
                }
                try {
                  await _applyAndPersistWithFeedback(request);
                } catch (_) {}
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabletYearList(
    BuildContext context,
    List<YearlySummary> summaries,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView.builder(
      itemCount: summaries.length,
      itemBuilder: (context, index) {
        final summary = summaries[index];
        final isSelected = summary.year == _selectedYear;
        return ListTile(
          title: Text('${summary.year}년'),
          selected: isSelected,
          selectedTileColor: colorScheme.primary.withValues(alpha: 0.1),
          onTap: () => setState(() => _selectedYear = summary.year),
        );
      },
    );
  }

  Widget _buildTabletDetailsForYear(
    BuildContext context,
    YearlySummary? summary,
    RecognitionCalculationResultEntity resultEntity,
  ) {
    if (summary == null) {
      return const Center(child: Text('연도를 선택하세요.'));
    }
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: DataTable(
        columnSpacing: 20.w,
        columns: ['회차', '납입일', '납입금액', '상태', '인정여부', '']
            .map(
              (label) => DataColumn(
                label: Text(
                  label,
                  style: textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
            .toList(),
        rows: summary.monthlyDetails.map((detail) {
          final record = detail.recordEntity;
          return DataRow(
            cells: [
              DataCell(
                Text(
                  '${record.installmentNo}회',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DataCell(
                Text(
                  record.paidDate != null
                      ? DateFormat('yy.MM.dd').format(record.paidDate!)
                      : '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DataCell(
                Text(
                  '${NumberFormat('#,###').format(record.paidAmount)}원',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DataCell(
                Text(
                  record.status,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: record.status == '지연'
                        ? Colors.red
                        : record.status == '선납'
                        ? Colors.blue
                        : Colors.green,
                  ),
                ),
              ),
              DataCell(
                Text(
                  record.isRecognized ? '인정' : '미인정',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: record.isRecognized ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DataCell(
                Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(Icons.more_horiz, size: 16.sp),
                      onPressed: () => PaymentDetailBottomSheet.show(
                        context,
                        record: record,
                        resultEntity: resultEntity,
                        onRecalculate: _applyAndPersistWithFeedback,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
