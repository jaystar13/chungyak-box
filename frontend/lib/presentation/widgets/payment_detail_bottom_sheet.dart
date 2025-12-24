import 'package:chungyak_box/domain/entities/custom_payment_input_entity.dart';
import 'package:chungyak_box/domain/entities/recognition_calculation_result_entity.dart';
import 'package:chungyak_box/domain/entities/recognition_calculator_request_entity.dart';
import 'package:chungyak_box/domain/entities/recognition_round_record_entity.dart';
import 'package:chungyak_box/presentation/widgets/info_row.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'date_picker_dialog.dart';

class PaymentDetailBottomSheet extends StatefulWidget {
  final RecognitionRoundRecordEntity record;
  final RecognitionCalculationResultEntity resultEntity;
  final Future<RecognitionCalculationResultEntity> Function(
    RecognitionCalculatorRequestEntity requestEntity,
  )
  onRecalculate;

  const PaymentDetailBottomSheet({
    super.key,
    required this.record,
    required this.resultEntity,
    required this.onRecalculate,
  });

  static Future<void> show(
    BuildContext context, {
    required RecognitionRoundRecordEntity record,
    required RecognitionCalculationResultEntity resultEntity,
    required Future<RecognitionCalculationResultEntity> Function(
      RecognitionCalculatorRequestEntity requestEntity,
    )
    onRecalculate,
  }) async {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    if (isTablet) {
      // For tablets, show as a dialog
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          contentPadding: EdgeInsets.zero,
          insetPadding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 24.h),
          content: SizedBox(
            width: 600.w, // Set a specific width for the dialog on tablets
            child: PaymentDetailBottomSheet(
              record: record,
              resultEntity: resultEntity,
              onRecalculate: onRecalculate,
            ),
          ),
        ),
      );
    } else {
      // For mobile, show as a modal bottom sheet
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => PaymentDetailBottomSheet(
          record: record,
          resultEntity: resultEntity,
          onRecalculate: onRecalculate,
        ),
      );
    }
  }

  @override
  State<PaymentDetailBottomSheet> createState() =>
      _PaymentDetailBottomSheetState();
}

class _PaymentDetailBottomSheetState extends State<PaymentDetailBottomSheet> {
  late RecognitionCalculationResultEntity _currentResult;
  // Currently displayed record
  late RecognitionRoundRecordEntity _currentRecord;

  // Unsaved changes for the current record
  late DateTime paidDate;
  late int paidAmount;

  // Local mutable copy of all payment data
  late List<CustomPaymentInputEntity> _localPayments;

  late final TextEditingController _paidDateController;
  late final TextEditingController _paidAmountController;

  bool _isNavigatingForward = true;
  int? _targetInstallmentNo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _paidDateController = TextEditingController();
    _paidAmountController = TextEditingController();
    _currentResult = widget.resultEntity;

    // Initialize local payment list from the widget's result entity
    _localPayments = _currentResult.details
        .map(
          (record) => CustomPaymentInputEntity(
            installmentNo: record.installmentNo,
            paidDate: _editablePaidDate(record),
            paidAmount: record.paidAmount,
          ),
        )
        .toList();

    // Set the initial record to display
    _updateStateForRecord(widget.record);
  }

  @override
  void dispose() {
    _paidDateController.dispose();
    _paidAmountController.dispose();
    super.dispose();
  }

  // Helper to update the UI state for a given record
  void _updateStateForRecord(RecognitionRoundRecordEntity newRecord) {
    // The displayed data should be the new, calculated record
    _currentRecord = newRecord;

    // But the form fields should reflect the latest user *input* from our
    // local source of truth for inputs.
    final currentInput = _localPayments.firstWhere(
      (p) => p.installmentNo == newRecord.installmentNo,
      orElse: () => CustomPaymentInputEntity(
        installmentNo: newRecord.installmentNo,
        paidDate: _editablePaidDate(newRecord),
        paidAmount: newRecord.paidAmount,
      ),
    );

    paidDate = currentInput.paidDate;
    paidAmount = currentInput.paidAmount;
    _paidDateController.text = DateFormat('yyyy-MM-dd').format(paidDate);
    _paidAmountController.text = NumberFormat('#,###').format(paidAmount);
  }

  DateTime _editablePaidDate(RecognitionRoundRecordEntity record) {
    return record.paidDate ?? record.dueDate;
  }

  String _displayPaidDate(RecognitionRoundRecordEntity record) {
    final paid = record.paidDate;
    if (paid == null) {
      return '-';
    }
    return DateFormat('yyyy-MM-dd').format(paid);
  }

  String _displayRecognizedDate(RecognitionRoundRecordEntity record) {
    final recognized = record.recognizedDate;
    if (recognized == null) {
      return '-';
    }
    return DateFormat('yyyy-MM-dd').format(recognized);
  }

  // Saves the current UI changes to the local payment list
  void _commitCurrentChanges() {
    final index = _localPayments.indexWhere(
      (p) => p.installmentNo == _currentRecord.installmentNo,
    );
    if (index != -1) {
      _localPayments[index] = CustomPaymentInputEntity(
        installmentNo: _currentRecord.installmentNo,
        paidDate: paidDate,
        paidAmount: paidAmount,
      );
    }
  }

  Future<void> _dispatchRecalculation() async {
    if (_isLoading) return;
    _commitCurrentChanges();

    final requestEntity = RecognitionCalculatorRequestEntity(
      paymentDay: _currentResult.paymentDay,
      startDate: _currentResult.startDate,
      endDate: _currentResult.endDate,
      paymentAmountOption: 'custom',
      standardPaymentAmount: null,
      payments: _localPayments,
    );

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await widget.onRecalculate(requestEntity);
      if (!mounted) {
        return;
      }
      setState(() {
        _currentResult = result;
        _localPayments = result.details
            .map(
              (record) => CustomPaymentInputEntity(
                installmentNo: record.installmentNo,
                paidDate: _editablePaidDate(record),
                paidAmount: record.paidAmount,
              ),
            )
            .toList();

        RecognitionRoundRecordEntity recordToShow;
        if (_targetInstallmentNo != null) {
          recordToShow = result.details.firstWhere(
            (r) => r.installmentNo == _targetInstallmentNo,
            orElse: () => result.details.first,
          );
          _targetInstallmentNo = null;
        } else {
          recordToShow = result.details.firstWhere(
            (r) => r.installmentNo == _currentRecord.installmentNo,
            orElse: () => result.details.first,
          );
        }
        _updateStateForRecord(recordToShow);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('재계산에 실패했습니다. 다시 시도해주세요.')));
    }
  }

  void _navigateToPrevious() {
    if (_isLoading) return;
    final currentIndex = _localPayments.indexWhere(
      (r) => r.installmentNo == _currentRecord.installmentNo,
    );
    if (currentIndex > 0) {
      _commitCurrentChanges();
      final previousInstallmentNo =
          _localPayments[currentIndex - 1].installmentNo;
      _targetInstallmentNo = previousInstallmentNo;

      setState(() {
        _isNavigatingForward = false;
      });

      _dispatchRecalculation();
    }
  }

  void _navigateToNext() {
    if (_isLoading) return;
    final currentIndex = _localPayments.indexWhere(
      (r) => r.installmentNo == _currentRecord.installmentNo,
    );
    final lastIndex = _localPayments.length - 1;
    if (currentIndex < lastIndex) {
      _commitCurrentChanges();
      final nextInstallmentNo = _localPayments[currentIndex + 1].installmentNo;
      _targetInstallmentNo = nextInstallmentNo;

      setState(() {
        _isNavigatingForward = true;
      });

      _dispatchRecalculation();
    }
  }

  Future<void> _pickPaidDate() async {
    final pickedDate = await showCustomDatePicker(
      context: context,
      initialDate: paidDate,
    );

    if (pickedDate != null) {
      setState(() {
        paidDate = pickedDate;
        _paidDateController.text = DateFormat('yyyy-MM-dd').format(paidDate);
      });
      _commitCurrentChanges();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _localPayments.indexWhere(
      (r) => r.installmentNo == _currentRecord.installmentNo,
    );
    final bool hasPrevious = currentIndex > 0;
    final bool hasNext = currentIndex < _localPayments.length - 1;

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16.w,
            16.w,
            16.w,
            32.w + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: hasPrevious && !_isLoading
                        ? _navigateToPrevious
                        : null,
                    child: const Text("이전"),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "${_currentRecord.installmentNo} 회차 상세",
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(fontSize: 16.sp),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: hasNext && !_isLoading ? _navigateToNext : null,
                    child: const Text("다음"),
                  ),
                  if (_isLoading)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.0,
                        ),
                      ),
                    )
                  else
                    SizedBox(width: 20.w + 8.w),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: '닫기',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  final offsetAnimation = (Tween<Offset>(
                    begin: _isNavigatingForward
                        ? const Offset(1.0, 0.0)
                        : const Offset(-1.0, 0.0),
                    end: Offset.zero,
                  )).animate(animation);
                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
                child: Column(
                  key: ValueKey<int>(_currentRecord.installmentNo),
                  children: [
                    SizedBox(height: 12.h),
                    Card(
                      margin: EdgeInsets.only(bottom: 16.0.w),
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          children: [
                            InfoRow(
                              title: "회차",
                              value: "${_currentRecord.installmentNo}",
                            ),
                            SizedBox(height: 8.h),
                            InfoRow(
                              title: "약정납입일",
                              value: DateFormat(
                                'yyyy-MM-dd',
                              ).format(_currentRecord.dueDate),
                            ),
                            SizedBox(height: 8.h),
                            InfoRow(
                              title: "실제납입일",
                              value: _displayPaidDate(_currentRecord),
                            ),
                            SizedBox(height: 8.h),
                            InfoRow(
                              title: "납입금액",
                              value:
                                  "${NumberFormat('#,###').format(_currentRecord.paidAmount)}원",
                            ),
                            SizedBox(height: 8.h),
                            InfoRow(
                              title: "인정금액",
                              value:
                                  "${NumberFormat('#,###').format(_currentRecord.recognizedAmountForRound)}원",
                            ),
                            SizedBox(height: 8.h),
                            InfoRow(
                              title: "지연일",
                              value: "${_currentRecord.delayDays}일",
                            ),
                            SizedBox(height: 8.h),
                            InfoRow(
                              title: "지연일 합계",
                              value: "${_currentRecord.totalDelayDays}일",
                            ),
                            SizedBox(height: 8.h),
                            InfoRow(
                              title: "선납일",
                              value: "${_currentRecord.prepaidDays}일",
                            ),
                            SizedBox(height: 8.h),
                            InfoRow(
                              title: "선납일 합계",
                              value: "${_currentRecord.totalPrepaidDays}일",
                            ),
                            SizedBox(height: 8.h),
                            InfoRow(
                              title: "납입인정일",
                              value: _displayRecognizedDate(_currentRecord),
                            ),
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
                        border: const OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today, size: 20.sp),
                      ),
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _paidAmountController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      inputFormatters: [
                        CurrencyTextInputFormatter.currency(
                          locale: 'ko',
                          symbol: '',
                          decimalDigits: 0,
                        ),
                      ],
                      decoration: InputDecoration(
                        labelText: "납입금액-변경",
                        labelStyle: TextStyle(fontSize: 14.sp),
                        border: const OutlineInputBorder(),
                        suffixText: '원',
                      ),
                      style: TextStyle(fontSize: 14.sp),
                      textAlign: TextAlign.right,
                      onChanged: (value) {
                        setState(() {
                          paidAmount =
                              int.tryParse(
                                value.replaceAll(RegExp(r'[^0-9]'), ''),
                              ) ??
                              0;
                        });
                        _commitCurrentChanges();
                      },
                      onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                    ),
                    SizedBox(height: 24.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _dispatchRecalculation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          textStyle: Theme.of(
                            context,
                          ).textTheme.titleMedium!.copyWith(fontSize: 16.sp),
                        ),
                        child: const Text('재계산'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
