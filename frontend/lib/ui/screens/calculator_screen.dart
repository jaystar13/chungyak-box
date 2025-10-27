import 'package:chungyak_box/services/admob_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chungyak_box/models/calculator_model.dart';
import 'package:chungyak_box/models/payment_schdule_model.dart';
import 'package:chungyak_box/services/api_services.dart';

Future<dynamic> recalculateSchedule(
  DateTime? openDate,
  DateTime? endDate,
  dynamic schedule,
) async {
  final requestSchedule = PaymentScheduleRequest.fromResponse(
    openDate,
    endDate,
    schedule,
  );
  return await ApiServices.recalculateSchedule(requestSchedule);
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _formKey = GlobalKey<FormState>();

  DateTime? openDate, endDate;
  int? dueDay;

  dynamic schedule;

  // Controllers to avoid recreating on every build
  final TextEditingController _openDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  @override
  void dispose() {
    _openDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  /// Shows a SnackBar with given message and style based on error flag
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontSize: 14.sp)),
        backgroundColor: isError ? Colors.redAccent : null,
      ),
    );
  }

  /// Shows a date picker and calls the callback with picked date
  Future<void> _pickDate(
    Function(DateTime) onPicked, {
    DateTime? initialDate,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );

    if (picked != null) {
      setState(() {
        onPicked(picked);
      });
    }
  }

  /// Handles generate button press: validates form and fetches schedule
  Future<void> _onGenerate() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final request = CalculatorRequest(
        openDate: openDate!,
        dueDay: 1,
        endDate: endDate,
      );

      try {
        final result = await ApiServices.generatePaymentSchedule(request);
        setState(() {
          schedule = result;
        });
        // _showSnackBar("납입내역 생성 성공 ✅");
      } catch (e) {
        _showSnackBar("납입내역 생성 실패: $e", isError: true);
      }
    }
  }

  /// Opens detail sheet for selected payment using showModalBottomSheet
  void _openDetailSheet(dynamic payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).canvasColor,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: PaymentDetailScreen(
          schedule: schedule,
          openDate: openDate,
          endDate: endDate,
          onRefresh: (updatedSchedule) async {
            setState(() {
              schedule = updatedSchedule;
            });
          },
          payments: schedule.payments,
          currentIndex: schedule.payments.indexOf(payment),
        ),
      ),
    );
  }

  /// Updates the text controllers when dates change
  void _updateDateControllers() {
    _openDateController.text = openDate == null
        ? ''
        : openDate!.toLocal().toString().split(' ')[0];
    _endDateController.text = endDate == null
        ? ''
        : endDate!.toLocal().toString().split(' ')[0];
  }

  /// Builds the form fields for date inputs
  Widget _buildDateFormFields() {
    _updateDateControllers();
    return Column(
      children: [
        TextFormField(
          readOnly: true,
          decoration: InputDecoration(
            labelText: "계산 시작일",
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_today, size: 20.sp),
          ),
          controller: _openDateController,
          onTap: () => _pickDate(
            (d) => setState(() => openDate = d),
            initialDate: openDate ?? DateTime.now(),
          ),
          validator: (value) => (openDate == null) ? '계산 시작일을 선택하세요' : null,
        ),
        SizedBox(height: 16.h),
        TextFormField(
          readOnly: true,
          decoration: InputDecoration(
            labelText: "계산 종료일",
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.calendar_today, size: 20.sp),
          ),
          controller: _endDateController,
          onTap: () => _pickDate(
            (d) => setState(() => endDate = d),
            initialDate: endDate ?? DateTime.now(),
          ),
        ),
      ],
    );
  }

  /// Builds the generate button
  Widget _buildGenerateButton(ColorScheme colors) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: colors.primary),
        onPressed: _onGenerate,
        child: Text(
          "생성",
          style: TextStyle(color: colors.onPrimary, fontSize: 16.sp),
        ),
      ),
    );
  }

  /// Calculates yearly statistics for a list of payments
  Map<String, int> _calculateYearlyStats(List<dynamic> payments) {
    final totalDelayDays = payments.fold<int>(
      0,
      (sum, p) => sum + ((p.delayDays ?? 0) as int),
    );
    final totalPrepaidDays = payments.fold<int>(
      0,
      (sum, p) => sum + ((p.prepaidDays ?? 0) as int),
    );
    final totalDelayDayCount = payments.fold<int>(
      0,
      (count, p) => count + (p.delayDays != null && p.delayDays > 0 ? 1 : 0),
    );
    final totalPrepaidDayCount = payments.fold<int>(
      0,
      (count, p) =>
          count + (p.prepaidDays != null && p.prepaidDays > 0 ? 1 : 0),
    );
    final totalNormalCount = payments.fold<int>(
      0,
      (count, p) =>
          count +
          ((p.prepaidDays != null && p.prepaidDays == 0) &&
                  (p.delayDays != null && p.delayDays == 0)
              ? 1
              : 0),
    );

    return {
      'totalDelayDays': totalDelayDays,
      'totalPrepaidDays': totalPrepaidDays,
      'totalDelayDayCount': totalDelayDayCount,
      'totalPrepaidDayCount': totalPrepaidDayCount,
      'totalNormalCount': totalNormalCount,
    };
  }

  /// Builds the yearly grouped payment lists with stats
  List<Widget> _buildYearlyGroups() {
    Map<String, List<dynamic>> byYear = {};
    for (var p in schedule.payments) {
      final year = p.dueDate.substring(0, 4);
      byYear.putIfAbsent(year, () => []).add(p);
    }

    return byYear.entries.map((entry) {
      final year = entry.key;
      final payments = entry.value;
      final stats = _calculateYearlyStats(payments);

      return ExpansionTile(
        leading: _buildYearIcon(year, "normal"),
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
                // mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "정상 ${stats['totalNormalCount']}회",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "지연 ${stats['totalDelayDayCount']}회",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "선납 ${stats['totalPrepaidDayCount']}회",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.tertiary,
                        fontSize: 14.sp,
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
              payment.installmentNo.toString(),
              payment.delayDays != null && payment.delayDays > 0
                  ? "delay"
                  : (payment.prepaidDays != null && payment.prepaidDays > 0
                        ? "prepaid"
                        : "normal"),
              payment.isRecognized,
            ),
            subtitle: Text(
              "약정납입일 ${payment.dueDate ?? '-'}\n실제납입일 ${payment.paidDate}",
              style: TextStyle(fontSize: 13.sp),
            ),
            trailing: Icon(Icons.arrow_forward_ios, size: 18.sp),
            onTap: () => _openDetailSheet(payment),
          );
        }).toList(),
      );
    }).toList();
  }

  Widget _buildScheduleSummaryTitle() {
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
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(fontSize: 16.sp),
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
                                style: TextStyle(fontSize: 16.sp),
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
                                  style: TextStyle(fontSize: 13.sp),
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                "닫기",
                                style: TextStyle(fontSize: 14.sp),
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
                  final payments = List.from(
                    schedule.payments,
                  )..sort((a, b) => a.installmentNo.compareTo(b.installmentNo));

                  final minInstallment = payments.first.installmentNo;
                  final maxInstallment = payments.last.installmentNo;
                  _showBulkEditDialog(minInstallment, maxInstallment);
                },
              ),
            ),
          ],
        ),

        //const SizedBox(height: 4),
        Divider(thickness: 2.h, color: Theme.of(context).colorScheme.primary),
      ],
    );
  }

  void _showBulkEditDialog(int startNo, int endNo) {
    int selectedStart = startNo;
    int selectedEnd = endNo;
    String? selectedDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("실제납입일-일괄변경", style: TextStyle(fontSize: 16.sp)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text("변경 회차: ", style: TextStyle(fontSize: 14.sp)),
                      DropdownButton<int>(
                        value: selectedStart,
                        items:
                            List.generate(
                              endNo - startNo + 1,
                              (i) => startNo + i,
                            ).map((v) {
                              return DropdownMenuItem(
                                value: v,
                                child: Text(
                                  "$v",
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                              );
                            }).toList(),
                        onChanged: (v) => setState(() => selectedStart = v!),
                      ),
                      Text(" 부터 ", style: TextStyle(fontSize: 14.sp)),
                      DropdownButton<int>(
                        value: selectedEnd,
                        items:
                            List.generate(
                              endNo - startNo + 1,
                              (i) => startNo + i,
                            ).map((v) {
                              return DropdownMenuItem(
                                value: v,
                                child: Text(
                                  "$v",
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                              );
                            }).toList(),
                        onChanged: (v) => setState(() => selectedEnd = v!),
                      ),
                      Text(" 까지", style: TextStyle(fontSize: 14.sp)),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "실제납입일",
                      labelStyle: TextStyle(fontSize: 14.sp),
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today, size: 20.sp),
                    ),
                    style: TextStyle(fontSize: 14.sp),
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
                          selectedDate = picked
                              .toIso8601String()
                              .split('T')
                              .first;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("취소", style: TextStyle(fontSize: 14.sp)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () async {
                    if (selectedStart > selectedEnd) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "시작 회차는 종료 회차보다 클 수 없습니다.",
                            style: TextStyle(fontSize: 14.sp),
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
                            style: TextStyle(fontSize: 14.sp),
                          ),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    Navigator.of(context).pop();

                    await _applyBulkPaidDateChange(
                      selectedStart,
                      selectedEnd,
                      selectedDate!,
                    );
                  },
                  child: Text(
                    "확인",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<dynamic> _applyBulkPaidDateChange(
    int startNo,
    int endNo,
    String paidDate,
  ) async {
    // final updatedPayments = schedule.payments;
    for (var p in schedule.payments) {
      if (p.installmentNo >= startNo && p.installmentNo <= endNo) {
        p.paidDate = paidDate;
      }
    }

    try {
      final updated = await recalculateSchedule(openDate, endDate, schedule);
      setState(() {
        schedule = updated;
        paidDate = paidDate; // This line seems redundant, consider removing or clarifying its purpose.
      });
    } catch (e) {
      if (mounted) {
        _showSnackBar("재계산 실패: $e", isError: true);
      }
    }
  }

  Widget _buildYearIcon(String year, String status) {
    Color color = Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: 40.w,
      height: 40.w,
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
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
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstallmentNoIcon(
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
        color: recognizedColor.withValues(alpha: 0.15), // 은은한 배경색
        shape: BoxShape.rectangle,
        border: Border.all(color: recognizedColor, width: 2), // 진한 보더라인
      ),
      alignment: Alignment.center,
      child: Text(
        "$installmentNo회차",
        style: TextStyle(
          color: statusColor,
          fontWeight: FontWeight.bold,
          fontSize: 14.sp,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Typography.material2021().englishLike;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '청약 인정회차 계산기',
          style: textTheme.titleLarge?.copyWith(
            color: colors.onPrimaryContainer,
            fontSize: 20.sp,
          ),
        ),
        backgroundColor: colors.primaryContainer,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0.w),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildDateFormFields(),
              SizedBox(height: 24.h),
              _buildGenerateButton(colors),
              SizedBox(height: 24.h),
              if (schedule != null) ...[
                _buildScheduleSummaryTitle(),
                Expanded(child: ListView(children: _buildYearlyGroups())),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: const SafeArea(child: BannerAdWidget()),
    );
  }
}

class PaymentDetailScreen extends StatefulWidget {
  final dynamic schedule;
  // final dynamic payment;
  final DateTime? openDate;
  final DateTime? endDate;
  final Future<void> Function(dynamic schedule) onRefresh;

  final List<dynamic> payments;
  final int currentIndex;

  const PaymentDetailScreen({
    super.key,
    required this.schedule,
    // required this.payment,
    required this.openDate,
    required this.endDate,
    required this.onRefresh,
    required this.payments,
    required this.currentIndex,
  });

  @override
  State<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends State<PaymentDetailScreen> {
  late dynamic schedule;
  late String paidDate;
  late dynamic currentPayment;
  late TextEditingController _paidDateController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    schedule = widget.schedule;
    currentIndex = widget.currentIndex;
    currentPayment = schedule.payments[currentIndex];
    paidDate = currentPayment.paidDate ?? '';
    _paidDateController = TextEditingController(text: paidDate);
  }

  @override
  void dispose() {
    _paidDateController.dispose();
    super.dispose();
  }

  Future<void> _pickPaidDate() async {
    DateTime initialDate;
    try {
      initialDate = DateTime.parse(paidDate);
    } catch (_) {
      initialDate = DateTime.now();
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1980),
      lastDate: DateTime(2100),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked != null) {
      setState(() {
        paidDate = picked.toIso8601String().split('T')[0];
        _paidDateController.text = paidDate;
      });
      // 자동 저장
      await _onSave();
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontSize: 14.sp)),
        backgroundColor: isError ? Colors.redAccent : null,
      ),
    );
  }

  Future<void> _onSave() async {
    for (var p in schedule.payments) {
      if (p.installmentNo == currentPayment.installmentNo) {
        p.paidDate = paidDate;
        break;
      }
    }

    try {
      final updated = await recalculateSchedule(
        widget.openDate,
        widget.endDate,
        schedule,
      );

      if (mounted) {
        await widget.onRefresh(updated);
        final newCurrent = updated.payments.firstWhere(
          (p) => p.installmentNo == currentPayment.installmentNo,
        );
        setState(() {
          schedule = updated;
          currentPayment = newCurrent;
          paidDate = paidDate;
        });
        // _showSnackBar("재계산 성공");
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar("재계산 실패: $e", isError: true);
      }
    }
  }

  void _goToPayment(int newIndex) {
    if (newIndex < 0 || newIndex >= widget.payments.length) return;
    setState(() {
      currentIndex = newIndex;
      currentPayment = schedule.payments[newIndex];
      paidDate = currentPayment.paidDate ?? '';
      _paidDateController.text = paidDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = currentPayment;
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 32.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: currentIndex > 0
                        ? () => _goToPayment(currentIndex - 1)
                        : null,
                    child: const Text("이전"),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "${p.installmentNo} 회차 상세",
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(fontSize: 16.sp),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: currentIndex < widget.payments.length - 1
                        ? () => _goToPayment(currentIndex + 1)
                        : null,
                    child: const Text("다음"),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: '닫기',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  final offsetAnimation = Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(animation);
                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
                child: Card(
                  key: ValueKey(currentIndex),
                  margin: EdgeInsets.only(bottom: 16.0.w),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      children: [
                        _InfoRow(title: "회차", value: "${p.installmentNo}"),
                        SizedBox(height: 8.h),
                        _InfoRow(title: "약정납입일", value: p.dueDate ?? '-'),
                        SizedBox(height: 8.h),
                        _InfoRow(title: "실제납입일", value: p.paidDate ?? '-'),
                        SizedBox(height: 8.h),
                        _InfoRow(title: "지연일", value: "${p.delayDays ?? '-'}일"),
                        SizedBox(height: 8.h),
                        _InfoRow(
                          title: "지연일 합계",
                          value: "${p.totalDelayDays ?? '-'}일",
                        ),
                        SizedBox(height: 8.h),
                        _InfoRow(
                          title: "선납일",
                          value: "${p.prepaidDays ?? '-'}일",
                        ),
                        SizedBox(height: 8.h),
                        _InfoRow(
                          title: "선납일 합계",
                          value: "${p.totalPrepaidDays ?? '-'}일",
                        ),
                        SizedBox(height: 8.h),
                        _InfoRow(
                          title: "납입인정일",
                          value: p.recognizedDate ?? '-',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              TextFormField(
                readOnly: true,
                controller: _paidDateController,
                onTap: _pickPaidDate,
                decoration: InputDecoration(
                  labelText: "실제 납입일-변경",
                  labelStyle: TextStyle(fontSize: 14.sp),
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today, size: 20.sp),
                ),
                style: TextStyle(fontSize: 14.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Info row with left title and right value, styled for PaymentDetailScreen
class _InfoRow extends StatelessWidget {
  final String title;
  final String value;
  const _InfoRow({required this.title, required this.value});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
        ),
      ],
    );
  }
}