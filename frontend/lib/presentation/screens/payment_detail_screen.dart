import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chungyak_box/domain/entities/payment_entity.dart';
import 'package:chungyak_box/domain/entities/payment_schedule_entity.dart';
import 'package:chungyak_box/presentation/viewmodels/calculator_bloc.dart';
import 'package:chungyak_box/presentation/viewmodels/calculator_event.dart';
import 'package:chungyak_box/presentation/widgets/info_row.dart';

class PaymentDetailScreen extends StatefulWidget {
  final PaymentScheduleEntity schedule;
  final DateTime? openDate;
  final DateTime? endDate;
  final int currentIndex;

  const PaymentDetailScreen({
    super.key,
    required this.schedule,
    required this.openDate,
    required this.endDate,
    required this.currentIndex,
  });

  @override
  State<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends State<PaymentDetailScreen> {
  late PaymentScheduleEntity schedule;
  late String paidDate;
  late PaymentEntity currentPayment;
  late TextEditingController _paidDateController;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    schedule = widget.schedule;
    currentIndex = widget.currentIndex;
    currentPayment = schedule.payments[currentIndex];
    paidDate = currentPayment.paidDate;
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
      await _onSave();
    }
  }

  Future<void> _onSave() async {
    final updatedPayments = schedule.payments.map((p) {
      if (p.installmentNo == currentPayment.installmentNo) {
        return PaymentEntity(
          installmentNo: p.installmentNo,
          dueDate: p.dueDate,
          paidDate: paidDate,
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
      totalInstallments: schedule.totalInstallments,
      totalDelayDays: schedule.totalDelayDays,
      totalPrepaidDays: schedule.totalPrepaidDays,
      payments: updatedPayments,
    );

    context.read<CalculatorBloc>().add(RecalculateSchedule(
          openDate: widget.openDate!,
          endDate: widget.endDate,
          schedule: updatedSchedule,
        ));
  }

  void _goToPayment(int newIndex) {
    if (newIndex < 0 || newIndex >= schedule.payments.length) return;
    setState(() {
      currentIndex = newIndex;
      currentPayment = schedule.payments[newIndex];
      paidDate = currentPayment.paidDate;
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16.sp),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: currentIndex < schedule.payments.length - 1
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
              Card(
                margin: EdgeInsets.only(bottom: 16.0.w),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      InfoRow(title: "회차", value: "${p.installmentNo}"),
                      SizedBox(height: 8.h),
                      InfoRow(title: "약정납입일", value: p.dueDate),
                      SizedBox(height: 8.h),
                      InfoRow(title: "실제납입일", value: p.paidDate),
                      SizedBox(height: 8.h),
                      InfoRow(title: "지연일", value: "${p.delayDays}일"),
                      SizedBox(height: 8.h),
                      InfoRow(title: "지연일 합계", value: "${p.totalDelayDays}일"),
                      SizedBox(height: 8.h),
                      InfoRow(title: "선납일", value: "${p.prepaidDays}일"),
                      SizedBox(height: 8.h),
                      InfoRow(title: "선납일 합계", value: "${p.totalPrepaidDays}일"),
                      SizedBox(height: 8.h),
                      InfoRow(title: "납입인정일", value: p.recognizedDate),
                    ],
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