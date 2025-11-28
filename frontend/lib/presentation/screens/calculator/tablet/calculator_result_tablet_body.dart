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

class YearlySummary {
  final String year;
  final List<MonthlyDetail> monthlyDetails;

  YearlySummary({required this.year, required this.monthlyDetails});
}

class MonthlyDetail {
  final RecognitionRoundRecordEntity recordEntity;

  MonthlyDetail({required this.recordEntity});
}

class CalculatorResultTabletBody extends StatefulWidget {
  const CalculatorResultTabletBody({super.key});

  @override
  State<CalculatorResultTabletBody> createState() =>
      _CalculatorResultTabletBodyState();
}

class _CalculatorResultTabletBodyState
    extends State<CalculatorResultTabletBody> {
  bool _showNotification = true;
  bool _isSortAscending = false;
  String? _selectedYear;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final Object? arguments = ModalRoute.of(context)!.settings.arguments;

    return BlocBuilder<CalculatorBloc, CalculatorState>(
      builder: (context, state) {
        final RecognitionCalculationResultEntity resultEntity;
        if (state is RecognitionCalculated) {
          resultEntity = state.result;
        } else if (arguments is RecognitionCalculationResultEntity) {
          resultEntity = arguments;
        } else {
          return Scaffold(
            appBar: AppBar(title: const Text('계산 결과')),
            body: const Center(child: Text('결과 데이터를 불러오는 데 실패했습니다.')),
          );
        }

        final sortedDetails = List<RecognitionRoundRecordEntity>.from(
          resultEntity.details,
        );
        sortedDetails.sort(
          (a, b) => _isSortAscending
              ? a.installmentNo.compareTo(b.installmentNo)
              : b.installmentNo.compareTo(a.installmentNo),
        );

        final Map<int, List<MonthlyDetail>> groupedByYear = {};
        for (var record in sortedDetails) {
          final year = record.dueDate.year;
          groupedByYear
              .putIfAbsent(year, () => [])
              .add(MonthlyDetail(recordEntity: record));
        }

        final yearlySummaries = groupedByYear.entries
            .map(
              (entry) => YearlySummary(
                year: entry.key.toString(),
                monthlyDetails: entry.value,
              ),
            )
            .toList();
        yearlySummaries.sort(
          (a, b) => _isSortAscending
              ? int.parse(a.year).compareTo(int.parse(b.year))
              : int.parse(b.year).compareTo(int.parse(a.year)),
        );

        if (_selectedYear == null && yearlySummaries.isNotEmpty) {
          _selectedYear = yearlySummaries.first.year;
        }

        final selectedYearSummary = yearlySummaries
            .where((s) => s.year == _selectedYear)
            .firstOrNull;

        return BlocListener<CalculatorBloc, CalculatorState>(
          listener: (context, state) {
            // Listener logic remains the same
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('계산 결과'),
              centerTitle: true,
              backgroundColor: colorScheme.primaryContainer,
            ),
            body: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummarySection(context, resultEntity),
                  SizedBox(height: 12.h),
                  if (_showNotification) _buildNotificationCard(context),
                  _buildDetailedHistoryTitle(context, resultEntity),
                  const Divider(),
                  SizedBox(height: 8.h),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left side: Year list (Master)
                        Expanded(
                          flex: 1,
                          child: _buildYearList(context, yearlySummaries),
                        ),
                        const VerticalDivider(width: 1),
                        // Right side: Details for selected year (Detail)
                        Expanded(
                          flex: 4,
                          child: _buildDetailsForYear(
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
            ),
            bottomNavigationBar: const SafeArea(child: BannerAdWidget()),
          ),
        );
      },
    );
  }

  // Extracted Widgets for Tablet Layout
  Widget _buildSummarySection(
    BuildContext context,
    RecognitionCalculationResultEntity resultEntity,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
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
              icon: Icon(
                Icons.info_outline,
                size: 18.sp,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              onPressed: () => _showCalculationInfoDialog(context),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(20.w),
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
                                '${NumberFormat('#,###').format(resultEntity.totalRecognizedAmount)}원',
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
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 36.sp,
                color: colorScheme.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Dismissible(
      key: const ValueKey('payment_date_notification'),
      onDismissed: (_) => setState(() => _showNotification = false),
      child: Card(
        margin: EdgeInsets.only(bottom: 12.h),
        color: colorScheme.surfaceContainer,
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '회차별 실제납입일 및 납입금액을 확인하고 변경해 주세요.',
                  style: textTheme.bodyMedium!.copyWith(
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: colorScheme.onSecondaryContainer,
                ),
                iconSize: 18.w,
                onPressed: () => setState(() => _showNotification = false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedHistoryTitle(
    BuildContext context,
    RecognitionCalculationResultEntity resultEntity,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
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
                _selectedYear = null; // Reset selection to re-init
              }),
            ),
          ],
        ),
        IconButton(
          icon: Icon(Icons.edit_calendar_outlined, size: 18.sp),
          onPressed: () => showDialog(
            context: context,
            builder: (_) => BlocProvider.value(
              value: BlocProvider.of<CalculatorBloc>(context),
              child: BulkChangeDialog(resultEntity: resultEntity),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildYearList(BuildContext context, List<YearlySummary> summaries) {
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

  Widget _buildDetailsForYear(
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
                  style: textTheme.bodyMedium!.copyWith(
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
                  DateFormat('yy.MM.dd').format(record.paidDate),
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
                IconButton(
                  icon: Icon(Icons.more_horiz, size: 18.sp),
                  onPressed: () => PaymentDetailBottomSheet.show(
                    context,
                    record: record,
                    resultEntity: resultEntity,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUnrecognizedRoundsInfo(int unrecognizedRounds) {
    // Helper method, remains the same
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
    // Helper method, remains the same
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
