import 'package:chungyak_box/data/datasources/admob_services.dart';
import 'package:chungyak_box/presentation/layouts/responsive_layout.dart';
import 'package:chungyak_box/presentation/utils/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chungyak_box/presentation/viewmodels/calculator_bloc.dart';
import 'package:chungyak_box/presentation/viewmodels/calculator_event.dart';
import 'package:chungyak_box/presentation/viewmodels/calculator_state.dart';
import 'package:chungyak_box/domain/entities/payment_entity.dart';
import 'package:chungyak_box/domain/entities/payment_schedule_entity.dart';
import 'package:chungyak_box/presentation/screens/payment_detail_screen.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final mobileBody = Scaffold(
      appBar: AppBar(
        title: Text(
          '청약 인정회차 계산기',
          style: AppTextStyles.title.copyWith(color: colors.onPrimaryContainer),
        ),
        backgroundColor: colors.primaryContainer,
      ),
      body: BlocListener<CalculatorBloc, CalculatorState>(
        listener: (context, state) {
          if (state is CalculatorError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message, style: AppTextStyles.caption),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        child: Padding(
          padding: EdgeInsets.all(16.0.w),
          child: Column(
            children: [
              _DateFormFields(),
              SizedBox(height: 24.h),
              _GenerateButton(),
              SizedBox(height: 24.h),
              Expanded(
                child: BlocBuilder<CalculatorBloc, CalculatorState>(
                  builder: (context, state) {
                    if (state is CalculatorLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is CalculatorLoaded) {
                      return _ScheduleDetails(schedule: state.schedule);
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const SafeArea(child: BannerAdWidget()),
    );

    // final tabletBody = Scaffold(
    //   appBar: AppBar(title: const Text('청약 인정회차 계산기 - Tablet')),
    //   body: const Center(child: Placeholder()),
    // );

    return ResponsiveLayout(mobileBody: mobileBody, tabletBody: mobileBody);
  }
}

class _DateFormFields extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  Future<void> _pickDate(
    BuildContext context,
    Function(DateTime) onPicked,
    DateTime? initialDate,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );

    if (picked != null) {
      onPicked(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalculatorBloc, CalculatorState>(
      builder: (context, state) {
        final openDateController = TextEditingController(
          text: state.openDate?.toLocal().toString().split(' ')[0] ?? '',
        );
        final endDateController = TextEditingController(
          text: state.endDate?.toLocal().toString().split(' ')[0] ?? '',
        );

        return Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "계산 시작일",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today, size: 20.sp),
                ),
                controller: openDateController,
                onTap: () => _pickDate(
                  context,
                  (d) => context.read<CalculatorBloc>().add(OpenDateChanged(d)),
                  state.openDate,
                ),
                validator: (value) =>
                    (state.openDate == null) ? '계산 시작일을 선택하세요' : null,
              ),
              SizedBox(height: 16.h),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "계산 종료일",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today, size: 20.sp),
                ),
                controller: endDateController,
                onTap: () => _pickDate(
                  context,
                  (d) => context.read<CalculatorBloc>().add(EndDateChanged(d)),
                  state.endDate,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GenerateButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return BlocBuilder<CalculatorBloc, CalculatorState>(
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: AppButtonStyles.elevatedButtonStyle(colors),
            onPressed: () {
              if (state.openDate != null) {
                context.read<CalculatorBloc>().add(
                  GenerateSchedule(
                    openDate: state.openDate!,
                    dueDay: 1,
                    endDate: state.endDate,
                  ),
                );
              }
            },
            child: Text(
              "생성",
              style: AppTextStyles.body.copyWith(color: colors.onPrimary),
            ),
          ),
        );
      },
    );
  }
}

class _ScheduleDetails extends StatelessWidget {
  final PaymentScheduleEntity schedule;

  const _ScheduleDetails({required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ScheduleSummaryTitle(schedule: schedule),
        Expanded(child: _YearlyGroupedList(schedule: schedule)),
      ],
    );
  }
}

class _ScheduleSummaryTitle extends StatelessWidget {
  final PaymentScheduleEntity schedule;

  const _ScheduleSummaryTitle({required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      "납입내역(총인정 회차: ${schedule.totalInstallments}회)",
                      style: AppTextStyles.body,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Column(
                            children: [
                              Text(
                                "인정회차 계산 방법",
                                style: AppTextStyles.body,
                              ),
                              Divider(thickness: 1.h),
                            ],
                          ),
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
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
                                  style: AppTextStyles.small,
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                "닫기",
                                style: AppTextStyles.caption,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Icon(
                      Icons.info_outline,
                      size: 18.sp,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            Tooltip(
              message: "일괄변경",
              child: IconButton(
                icon: Icon(
                  Icons.edit_calendar,
                  size: 18.sp,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => BlocProvider.value(
                      value: BlocProvider.of<CalculatorBloc>(context),
                      child: _BulkEditDialog(schedule: schedule),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        Divider(thickness: 2.h, color: Theme.of(context).colorScheme.primary),
      ],
    );
  }
}

class _BulkEditDialog extends StatefulWidget {
  final PaymentScheduleEntity schedule;

  const _BulkEditDialog({required this.schedule});

  @override
  __BulkEditDialogState createState() => __BulkEditDialogState();
}

class __BulkEditDialogState extends State<_BulkEditDialog> {
  late int selectedStart;
  late int selectedEnd;
  String? selectedDate;

  @override
  void initState() {
    super.initState();
    final payments = widget.schedule.payments
      ..sort((a, b) => a.installmentNo.compareTo(b.installmentNo));
    selectedStart = payments.first.installmentNo;
    selectedEnd = payments.last.installmentNo;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text("실제납입일-일괄변경", style: AppTextStyles.body),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text("변경 회차: ", style: AppTextStyles.caption),
              DropdownButton<int>(
                value: selectedStart,
                items:
                    List.generate(
                      selectedEnd - selectedStart + 1,
                      (i) => selectedStart + i,
                    ).map((v) {
                      return DropdownMenuItem(
                        value: v,
                        child: Text("$v", style: AppTextStyles.caption),
                      );
                    }).toList(),
                onChanged: (v) => setState(() => selectedStart = v!),
              ),
              Text(" 부터 ", style: AppTextStyles.caption),
              DropdownButton<int>(
                value: selectedEnd,
                items:
                    List.generate(
                      widget.schedule.payments.length,
                      (i) => widget.schedule.payments[i].installmentNo,
                    ).where((v) => v >= selectedStart).map((v) {
                      return DropdownMenuItem(
                        value: v,
                        child: Text("$v", style: AppTextStyles.caption),
                      );
                    }).toList(),
                onChanged: (v) => setState(() => selectedEnd = v!),
              ),
              Text(" 까지", style: AppTextStyles.caption),
            ],
          ),
          SizedBox(height: 16.h),
          TextFormField(
            readOnly: true,
            decoration: InputDecoration(
              labelText: "실제납입일",
              labelStyle: AppTextStyles.caption,
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.calendar_today, size: 20.sp),
            ),
            style: AppTextStyles.caption,
            controller: TextEditingController(text: selectedDate ?? ''),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1950),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() {
                  selectedDate = picked.toIso8601String().split('T').first;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("취소", style: AppTextStyles.caption),
        ),
        ElevatedButton(
          style: AppButtonStyles.elevatedButtonStyle(colors),
          onPressed: () {
            if (selectedStart > selectedEnd) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "시작 회차는 종료 회차보다 클 수 없습니다.",
                    style: AppTextStyles.caption,
                  ),
                  backgroundColor: Colors.redAccent,
                ),
              );
              return;
            }
            if (selectedDate == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "실제납입일을 선택하세요.",
                    style: AppTextStyles.caption,
                  ),
                  backgroundColor: Colors.redAccent,
                ),
              );
              return;
            }

            final bloc = context.read<CalculatorBloc>();
            final currentState = bloc.state;

            final updatedPayments = widget.schedule.payments.map((p) {
              if (p.installmentNo >= selectedStart &&
                  p.installmentNo <= selectedEnd) {
                return PaymentEntity(
                  installmentNo: p.installmentNo,
                  dueDate: p.dueDate,
                  paidDate: selectedDate!,
                  delayDays: p.delayDays,
                  totalDelayDays: p.totalDelayDays,
                  prepaidDays: p.prepaidDays,
                  totalPrepaidDays: p.totalPrepaidDays,
                  recognizedDate: p.recognizedDate,
                  isRecognized: p.isRecognized,
                );
              }
              return p;
            }).toList();

            final updatedSchedule = PaymentScheduleEntity(
              totalInstallments: widget.schedule.totalInstallments,
              totalDelayDays: widget.schedule.totalDelayDays,
              totalPrepaidDays: widget.schedule.totalPrepaidDays,
              payments: updatedPayments,
            );

            bloc.add(
              RecalculateSchedule(
                openDate: currentState.openDate!,
                endDate: currentState.endDate,
                schedule: updatedSchedule,
              ),
            );

            Navigator.of(context).pop();
          },
          child: Text(
            "확인",
            style: AppTextStyles.caption.copyWith(color: colors.onPrimary),
          ),
        ),
      ],
    );
  }
}

class _YearlyGroupedList extends StatelessWidget {
  final PaymentScheduleEntity schedule;

  const _YearlyGroupedList({required this.schedule});

  Map<String, int> _calculateYearlyStats(List<PaymentEntity> payments) {
    return {
      'totalDelayDays': payments.fold(0, (sum, p) => sum + p.delayDays),
      'totalPrepaidDays': payments.fold(0, (sum, p) => sum + p.prepaidDays),
      'totalDelayDayCount': payments.where((p) => p.delayDays > 0).length,
      'totalPrepaidDayCount': payments.where((p) => p.prepaidDays > 0).length,
      'totalNormalCount': payments
          .where((p) => p.delayDays == 0 && p.prepaidDays == 0)
          .length,
    };
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<PaymentEntity>> byYear = {};
    for (var p in schedule.payments) {
      final year = p.dueDate.substring(0, 4);
      byYear.putIfAbsent(year, () => []).add(p);
    }

    return ListView(
      children: byYear.entries.map((entry) {
        final year = entry.key;
        final payments = entry.value;
        final stats = _calculateYearlyStats(payments);

        return ExpansionTile(
          leading: _buildYearIcon(context, year, "normal"),
          shape: Border(
            bottom: BorderSide(
              color: Theme.of(context).colorScheme.secondary,
              width: 0.5.w,
            ),
          ),
          title: Padding(
            padding: EdgeInsets.all(8.0.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "정상 ${stats['totalNormalCount']}회",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "지연 ${stats['totalDelayDayCount']}회",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "선납 ${stats['totalPrepaidDayCount']}회",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption.copyWith(
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          children: payments.map((payment) {
            return ListTile(
              contentPadding: EdgeInsets.only(left: 32.w, right: 24.w),
              leading: _buildInstallmentNoIcon(
                context,
                payment.installmentNo.toString(),
                payment.delayDays > 0
                    ? "delay"
                    : (payment.prepaidDays > 0 ? "prepaid" : "normal"),
                payment.isRecognized,
              ),
              subtitle: Text(
                "약정납입일 ${payment.dueDate}\n실제납입일 ${payment.paidDate}",
                style: AppTextStyles.small,
              ),
              trailing: Icon(Icons.arrow_forward_ios, size: 18.sp),
              onTap: () => _openDetailSheet(context, schedule, payment),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  Widget _buildYearIcon(BuildContext context, String year, String status) {
    Color color = Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: 40.w,
      height: 40.w,
      child: Container(
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            year,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.small.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstallmentNoIcon(
    BuildContext context,
    String installmentNo,
    String status,
    bool isRecognized,
  ) {
    Color recognizedColor = isRecognized
        ? Theme.of(context).colorScheme.primary
        : Colors.grey.shade400;
    Color statusColor = isRecognized
        ? (status == "delay"
              ? Theme.of(context).colorScheme.error
              : status == "prepaid"
              ? Theme.of(context).colorScheme.tertiary
              : Theme.of(context).colorScheme.primary)
        : Colors.grey;

    return Container(
      width: 54.w,
      height: 36.h,
      decoration: BoxDecoration(
        color: recognizedColor.withAlpha(38),
        shape: BoxShape.rectangle,
        border: Border.all(color: recognizedColor, width: 2),
      ),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          "$installmentNo회차",
          style: AppTextStyles.caption.copyWith(
            color: statusColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _openDetailSheet(
    BuildContext context,
    PaymentScheduleEntity schedule,
    PaymentEntity payment,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).canvasColor,
      builder: (ctx) => BlocProvider.value(
        value: BlocProvider.of<CalculatorBloc>(context),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: PaymentDetailScreen(
            schedule: schedule,
            openDate: context.read<CalculatorBloc>().state.openDate,
            endDate: context.read<CalculatorBloc>().state.endDate,
            currentIndex: schedule.payments.indexOf(payment),
          ),
        ),
      ),
    );
  }
}
