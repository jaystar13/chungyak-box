import 'dart:async';
import 'package:chungyak_box/domain/entities/recognition_calculation_result_entity.dart';
import 'package:chungyak_box/domain/entities/recognition_calculator_request_entity.dart';
import 'package:chungyak_box/domain/entities/recognition_round_record_entity.dart';
import 'package:chungyak_box/presentation/viewmodels/calculator_bloc.dart';
import 'package:chungyak_box/presentation/viewmodels/calculator_event.dart';
import 'package:chungyak_box/presentation/viewmodels/calculator_state.dart';
import 'package:chungyak_box/presentation/widgets/calculator/detailed_history_list.dart';
import 'package:chungyak_box/presentation/widgets/calculator/result_actions_helper.dart';
import 'package:chungyak_box/presentation/widgets/calculator/bulk_change_dialog.dart';
import 'package:chungyak_box/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

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
  late final CalculatorBloc _calculatorBloc;

  @override
  void initState() {
    super.initState();
    _calculatorBloc = context.read<CalculatorBloc>();
  }

  Future<bool> _showAuthDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('로그인 필요'),
          content: const Text('계산 결과를 저장하려면 로그인이 필요합니다.\n로그인 페이지로 이동하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(dialogContext).pop(true); // Indicate confirmation
              },
            ),
          ],
        );
      },
    );

    if (result == true) {
      // User confirmed, navigate to login and await result
      final loginResult = await Navigator.of(
        context,
      ).pushNamed(Routes.login, arguments: {'from': Routes.calculatorResult});
      return loginResult == true;
    }

    return false;
  }

  Future<bool> _showSaveConfirmationDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('확인'),
          content: const Text('나의 청약으로 저장하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<bool> _showSaveSuccessDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('저장 완료'),
          content:
              const Text('저장이 완료되었습니다. 나의 청약내역에서 확인하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('아니오'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CalculatorBloc, CalculatorState>(
      listener: (context, state) async {
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
        } else if (state is CalculatorSaving) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(const SnackBar(content: Text('계산 결과를 저장 중...')));
        } else if (state is CalculatorSaveSuccess) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          final shouldMove = await _showSaveSuccessDialog(context);
          if (!context.mounted) {
            return;
          }
          if (shouldMove) {
            Navigator.of(context).pushNamed(Routes.mySubscriptions);
          }
        } else if (state is CalculatorSaveError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text('계산 결과 저장 실패: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
        } else if (state is CalculatorAuthRequired) {
          final loginSuccess = await _showAuthDialog(context);

          if (loginSuccess) {
            // Add a short delay to allow auth state to propagate
            await Future.delayed(const Duration(milliseconds: 500));
            // If login was successful, retry saving the result.
            _calculatorBloc.add(SaveCalculationResult(state.result));
          } else {
            // If login was cancelled, just reset the state to stop showing the dialog.
            _calculatorBloc.add(const CalculationStateReset());
          }
        }
      },
      child: BlocBuilder<CalculatorBloc, CalculatorState>(
        buildWhen: (previous, current) {
          // Only rebuild the UI for states that affect the displayed data.
          // Ignore saving-related states to prevent the UI from resetting.
          return current is RecognitionCalculated ||
              current is InitialCalculationSuccess ||
              current is CalculatorLoading ||
              current is CalculatorError;
        },
        builder: (context, state) {
          final colorScheme = Theme.of(context).colorScheme;
          final textTheme = Theme.of(context).textTheme;
          final Object? arguments = ModalRoute.of(context)!.settings.arguments;

          final RecognitionCalculationResultEntity? nullableResultEntity;
          if (state is RecognitionCalculated) {
            nullableResultEntity = state.result;
          } else if (state is InitialCalculationSuccess) {
            nullableResultEntity = state.result;
          } else if (arguments is RecognitionCalculationResultEntity) {
            nullableResultEntity = arguments;
          } else {
            nullableResultEntity = null;
          }

          if (nullableResultEntity == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '결과 데이터를 불러오는 데 실패했습니다.\n이전 화면에서 다시 시도해주세요.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final RecognitionCalculationResultEntity resultEntity =
              nullableResultEntity;

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
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              Icons.save_alt_outlined,
                              size: 36.w,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.8,
                              ),
                            ),
                            onPressed: () async {
                              final shouldSave =
                                  await _showSaveConfirmationDialog(context);

                              if (shouldSave) {
                                _calculatorBloc.add(
                                  SaveCalculationResult(resultEntity),
                                );
                              }
                            },
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
                            color: colorScheme.onSurface.withValues(alpha: 0.8),
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
                      width: 48.w,
                      height: 48.h,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.tune, color: colorScheme.primary),
                        onPressed: () async {
                          final action =
                              await ResultActionsHelper.showActionSheet(
                                context,
                              );

                          if (action == ResultAction.bulkChange) {
                            // Keeps current bulk change flow but makes it selectable.
                            showDialog(
                              context: context,
                              builder: (_) => BlocProvider.value(
                                value: BlocProvider.of<CalculatorBloc>(context),
                                child: BulkChangeDialog(
                                  resultEntity: resultEntity,
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
                                  const SnackBar(
                                    content: Text('추가할 회차 정보가 없습니다.'),
                                  ),
                                );
                              return;
                            }
                            _calculatorBloc.add(
                              CalculateRecognition(requestEntity: request),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
                Divider(),
                SizedBox(height: 8.h),
                Expanded(
                  child: DetailedHistoryList(
                    summaries: yearlySummaries,
                    resultEntity: resultEntity,
                    onRecalculate: _requestRecalculation,
                  ),
                ),
              ],
            ),
          );
        },
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

  Future<RecognitionCalculationResultEntity> _requestRecalculation(
    RecognitionCalculatorRequestEntity request,
  ) {
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

    return completer.future.whenComplete(() {
      subscription?.cancel();
    });
  }
}
