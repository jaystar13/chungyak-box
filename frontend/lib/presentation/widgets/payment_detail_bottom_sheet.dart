import 'package:chungyak_box/domain/entities/custom_payment_input_entity.dart';
import 'package:chungyak_box/domain/entities/recognition_calculation_result_entity.dart';
import 'package:chungyak_box/domain/entities/recognition_calculator_request_entity.dart';
import 'package:chungyak_box/domain/entities/recognition_round_record_entity.dart';
import 'package:chungyak_box/presentation/viewmodels/calculator_bloc.dart';
import 'package:chungyak_box/presentation/viewmodels/calculator_event.dart';
import 'package:chungyak_box/presentation/viewmodels/calculator_state.dart';
import 'package:chungyak_box/presentation/widgets/info_row.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'date_picker_dialog.dart';

class PaymentDetailBottomSheet extends StatefulWidget {
  // The specific record being edited
  final RecognitionRoundRecordEntity record;
  // The full result entity for context and recalculation
  final RecognitionCalculationResultEntity resultEntity;

  const PaymentDetailBottomSheet({
    super.key,
    required this.record,
    required this.resultEntity,
  });

  static Future<void> show(
    BuildContext context, {
    required RecognitionRoundRecordEntity record,
    required RecognitionCalculationResultEntity resultEntity,
  }) async {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    final bloc = BlocProvider.of<CalculatorBloc>(context);

    if (isTablet) {
      // For tablets, show as a dialog
      await showDialog(
        context: context,
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: AlertDialog(
            contentPadding: EdgeInsets.zero,
            insetPadding: EdgeInsets.symmetric(
              horizontal: 40.w,
              vertical: 24.h,
            ),
            content: SizedBox(
              width: 600.w, // Set a specific width for the dialog on tablets
              child: PaymentDetailBottomSheet(
                record: record,
                resultEntity: resultEntity,
              ),
            ),
          ),
        ),
      );
    } else {
      // For mobile, show as a modal bottom sheet
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: PaymentDetailBottomSheet(
            record: record,
            resultEntity: resultEntity,
          ),
        ),
      );
    }
  }

  @override
  State<PaymentDetailBottomSheet> createState() =>
      _PaymentDetailBottomSheetState();
}

class _PaymentDetailBottomSheetState extends State<PaymentDetailBottomSheet> {
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

  @override
  void initState() {
    super.initState();
    _paidDateController = TextEditingController();
    _paidAmountController = TextEditingController();

    // Initialize local payment list from the widget's result entity
    _localPayments = widget.resultEntity.details
        .map(
          (record) => CustomPaymentInputEntity(
            installmentNo: record.installmentNo,
            paidDate: record.paidDate,
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
    _currentRecord = newRecord;
    paidDate = _currentRecord.paidDate;
    paidAmount = _currentRecord.paidAmount;
    _paidDateController.text = DateFormat('yyyy-MM-dd').format(paidDate);
    _paidAmountController.text = NumberFormat('#,###').format(paidAmount);
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

  // Dispatches the recalculation event to the BLoC
  void _dispatchRecalculation() {
    _commitCurrentChanges();

    final requestEntity = RecognitionCalculatorRequestEntity(
      paymentDay: widget.resultEntity.paymentDay,
      startDate: widget.resultEntity.startDate,
      endDate: widget.resultEntity.endDate,
      paymentAmountOption: 'custom',
      standardPaymentAmount: null,
      payments: _localPayments,
    );

    context.read<CalculatorBloc>().add(
      CalculateRecognition(requestEntity: requestEntity),
    );
  }

  void _navigateToPrevious() {
    final currentIndex = _localPayments.indexWhere(
      (r) => r.installmentNo == _currentRecord.installmentNo,
    );
    if (currentIndex > 0) {
      _dispatchRecalculation();
      setState(() {
        _isNavigatingForward = false;
        // Find the record from the original widget list to maintain consistency
        final previousRecord = widget.resultEntity.details[currentIndex - 1];
        _updateStateForRecord(previousRecord);
      });
    }
  }

  void _navigateToNext() {
    final currentIndex = _localPayments.indexWhere(
      (r) => r.installmentNo == _currentRecord.installmentNo,
    );
    final lastIndex = _localPayments.length - 1;
    if (currentIndex < lastIndex) {
      _dispatchRecalculation();
      setState(() {
        _isNavigatingForward = true;
        // Find the record from the original widget list to maintain consistency
        final nextRecord = widget.resultEntity.details[currentIndex + 1];
        _updateStateForRecord(nextRecord);
      });
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

    return BlocListener<CalculatorBloc, CalculatorState>(
      listener: (context, state) {
        if (state is RecognitionCalculated) {
          setState(() {
            // Update the local source of truth
            _localPayments = state.result.details
                .map(
                  (record) => CustomPaymentInputEntity(
                    installmentNo: record.installmentNo,
                    paidDate: record.paidDate,
                    paidAmount: record.paidAmount,
                  ),
                )
                .toList();

            // Find the record the user is currently looking at in the new list
            final newCurrentRecord = state.result.details.firstWhere(
              (r) => r.installmentNo == _currentRecord.installmentNo,
              orElse: () => state.result.details.first,
            );

            // Update the entire UI state with the new, recalculated data
            _updateStateForRecord(newCurrentRecord);
          });
        }
      },
      child: SafeArea(
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
                BlocBuilder<CalculatorBloc, CalculatorState>(
                  builder: (context, state) {
                    final isLoading = state is CalculatorLoading;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: hasPrevious ? _navigateToPrevious : null,
                          child: const Text("이전"),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              "${_currentRecord.installmentNo} 회차 상세",
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontSize: 16.sp),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: hasNext ? _navigateToNext : null,
                          child: const Text("다음"),
                        ),
                        if (isLoading)
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
                          SizedBox(width: 20.w + 8.w), // To keep layout stable
                        IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: '닫기',
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    );
                  },
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
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
                                value: DateFormat(
                                  'yyyy-MM-dd',
                                ).format(_currentRecord.paidDate),
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
                                value: DateFormat(
                                  'yyyy-MM-dd',
                                ).format(_currentRecord.recognizedDate),
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
                            symbol: '', // No symbol in the input field
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
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).unfocus(),
                      ),
                      SizedBox(height: 24.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _dispatchRecalculation,
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
      ),
    );
  }
}
