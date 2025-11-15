import 'package:chungyak_box/domain/entities/custom_payment_input_entity.dart';
import 'package:chungyak_box/domain/entities/recognition_calculation_result_entity.dart';
import 'package:chungyak_box/domain/entities/recognition_calculator_request_entity.dart';
import 'package:chungyak_box/presentation/viewmodels/calculator_bloc.dart';
import 'package:chungyak_box/presentation/viewmodels/calculator_event.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:chungyak_box/presentation/widgets/date_picker_dialog.dart';

class BulkChangeDialog extends StatefulWidget {
  final RecognitionCalculationResultEntity resultEntity;

  const BulkChangeDialog({super.key, required this.resultEntity});

  @override
  State<BulkChangeDialog> createState() => _BulkChangeDialogState();
}

class _BulkChangeDialogState extends State<BulkChangeDialog> {
  late int _selectedStart;
  late int _selectedEnd;
  DateTime? _selectedDate;
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final records = widget.resultEntity.details
      ..sort((a, b) => a.installmentNo.compareTo(b.installmentNo));
    _selectedStart = records.first.installmentNo;
    _selectedEnd = records.last.installmentNo;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _applyChanges() {
    final newAmountText = _amountController.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
    final newAmount = newAmountText.isNotEmpty
        ? int.tryParse(newAmountText)
        : null;

    if (_selectedDate == null && newAmount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("변경할 납입일 또는 납입금액을 입력하세요."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final bloc = context.read<CalculatorBloc>();

    // Convert the full list of result records to input entities
    final updatedPayments = widget.resultEntity.details.map((record) {
      // If the record is within the selected range, apply changes
      if (record.installmentNo >= _selectedStart &&
          record.installmentNo <= _selectedEnd) {
        return CustomPaymentInputEntity(
          installmentNo: record.installmentNo,
          // Use new date if provided, otherwise keep the old one
          paidDate: _selectedDate ?? record.paidDate,
          // Use new amount if provided, otherwise keep the old one
          paidAmount: newAmount ?? record.paidAmount,
        );
      }
      // Otherwise, keep the original payment data
      return CustomPaymentInputEntity(
        installmentNo: record.installmentNo,
        paidDate: record.paidDate,
        paidAmount: record.paidAmount,
      );
    }).toList();

    // Create the request entity for recalculation
    final requestEntity = RecognitionCalculatorRequestEntity(
      paymentDay: widget.resultEntity.paymentDay,
      startDate: widget.resultEntity.startDate,
      endDate: widget.resultEntity.endDate,
      paymentAmountOption: 'custom',
      standardPaymentAmount: null,
      payments: updatedPayments,
    );

    // Dispatch the event
    bloc.add(CalculateRecognition(requestEntity: requestEntity));

    // Close the dialog
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final records = widget.resultEntity.details;

    return AlertDialog(
      title: Text("납입정보 일괄변경", style: textTheme.titleMedium),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("변경 회차: ", style: textTheme.bodyMedium),
                DropdownButton<int>(
                  value: _selectedStart,
                  items: records.map((record) {
                    return DropdownMenuItem<int>(
                      value: record.installmentNo,
                      child: Text(
                        "${record.installmentNo}회",
                        style: textTheme.bodyMedium,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedStart = value;
                        if (_selectedEnd < _selectedStart) {
                          _selectedEnd = _selectedStart;
                        }
                      });
                    }
                  },
                ),
                Text(" ~ ", style: textTheme.bodyMedium),
                DropdownButton<int>(
                  value: _selectedEnd,
                  items: records
                      .where((r) => r.installmentNo >= _selectedStart)
                      .map((record) {
                        return DropdownMenuItem<int>(
                          value: record.installmentNo,
                          child: Text(
                            "${record.installmentNo}회",
                            style: textTheme.bodyMedium,
                          ),
                        );
                      })
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedEnd = value;
                      });
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 16.h),
            TextFormField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: "변경할 납입일 (선택)",
                labelStyle: textTheme.bodyMedium,
                border: const OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today, size: 20.sp),
              ),
              controller: TextEditingController(
                text: _selectedDate == null
                    ? ''
                    : DateFormat('yyyy.MM.dd').format(_selectedDate!),
              ),
              onTap: () async {
                final picked = await showCustomDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
            ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                CurrencyTextInputFormatter.currency(
                  locale: 'ko',
                  symbol: '',
                  decimalDigits: 0,
                ),
              ],
              decoration: InputDecoration(
                labelText: "변경할 납입금액 (선택)",
                labelStyle: textTheme.bodyMedium,
                border: const OutlineInputBorder(),
                suffixText: '원',
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("취소"),
        ),
        ElevatedButton(
          onPressed: _applyChanges,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
          child: const Text("적용"),
        ),
      ],
    );
  }
}
