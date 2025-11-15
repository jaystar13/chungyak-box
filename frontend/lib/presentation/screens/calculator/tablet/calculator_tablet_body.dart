import 'package:chungyak_box/data/datasources/admob_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:chungyak_box/presentation/widgets/date_picker_dialog.dart';

import 'package:chungyak_box/presentation/viewmodels/calculator_bloc.dart';
import 'package:chungyak_box/presentation/viewmodels/calculator_event.dart';
import 'package:chungyak_box/presentation/viewmodels/calculator_state.dart';
import 'package:chungyak_box/domain/entities/recognition_calculator_request_entity.dart';

class CalculatorTabletBody extends StatefulWidget {
  const CalculatorTabletBody({super.key});

  @override
  State<CalculatorTabletBody> createState() => _CalculatorTabletBodyState();
}

enum PaymentAmountOption { maxRecognized, customAmount }

class _CalculatorTabletBodyState extends State<CalculatorTabletBody> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _customAmountController = TextEditingController();

  int? _selectedPaymentDay;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  PaymentAmountOption _paymentAmountOption = PaymentAmountOption.maxRecognized;

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _customAmountController.dispose();
    super.dispose();
  }

  Future<void> _selectMonth(
    BuildContext context,
    TextEditingController controller,
    bool isStartDate,
  ) async {
    final pickedDate = await showCustomMonthPicker(
      context: context,
      initialDate:
          (isStartDate ? _selectedStartDate : _selectedEndDate) ??
          DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _selectedStartDate = DateTime(pickedDate.year, pickedDate.month, 1);
          controller.text = DateFormat('yyyy-MM').format(_selectedStartDate!);
        } else {
          _selectedEndDate = DateTime(pickedDate.year, pickedDate.month + 1, 0);
          controller.text = DateFormat('yyyy-MM').format(_selectedEndDate!);
        }
      });
    }
  }

  Widget _buildFormRow({required Widget label, required Widget input}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.only(right: 24.w, top: 12.h),
              child: label,
            ),
          ),
          Expanded(flex: 3, child: input),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: colorScheme.onSurface.withValues(alpha: 0.04),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: colorScheme.outline.withValues(alpha: 0.5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
    );

    return BlocListener<CalculatorBloc, CalculatorState>(
      listener: (context, state) {
        if (state is CalculatorLoading) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('계산 중...')));
        } else if (state is RecognitionCalculated) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          Navigator.of(
            context,
          ).pushNamed('/calculator/result', arguments: state.result);
        } else if (state is CalculatorError) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('오류: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('청약 납입 계산기'),
          centerTitle: true,
          backgroundColor: colorScheme.primaryContainer,
          elevation: 2,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 24.h),
          child: Column(
            children: [
              _buildFormRow(
                label: Text('납입일 선택', style: textTheme.titleMedium),
                input: DropdownButtonFormField<int>(
                  initialValue: _selectedPaymentDay,
                  items: List.generate(28, (index) => index + 1)
                      .map(
                        (day) =>
                            DropdownMenuItem(value: day, child: Text('$day일')),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedPaymentDay = value),
                  decoration: inputDecoration.copyWith(hintText: '1일 ~ 28일'),
                ),
              ),
              const Divider(),
              _buildFormRow(
                label: Text('시작일', style: textTheme.titleMedium),
                input: TextFormField(
                  controller: _startDateController,
                  readOnly: true,
                  onTap: () =>
                      _selectMonth(context, _startDateController, true),
                  decoration: inputDecoration.copyWith(
                    hintText: 'YYYY-MM',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () =>
                          _selectMonth(context, _startDateController, true),
                    ),
                  ),
                ),
              ),
              const Divider(),
              _buildFormRow(
                label: Text('종료일', style: textTheme.titleMedium),
                input: TextFormField(
                  controller: _endDateController,
                  readOnly: true,
                  onTap: () => _selectMonth(context, _endDateController, false),
                  decoration: inputDecoration.copyWith(
                    hintText: 'YYYY-MM',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () =>
                          _selectMonth(context, _endDateController, false),
                    ),
                  ),
                ),
              ),
              const Divider(),
              _buildFormRow(
                label: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('납입 금액', style: textTheme.titleMedium),
                    SizedBox(height: 8.h),
                    Text(
                      '납입 내역 생성에 필요한 초기 납입 금액을 선택합니다. 최대 인정 금액은 2024년 11월 이전 10만원, 이후 25만원입니다.',
                      style: textTheme.bodyMedium!.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                input: Column(
                  children: [
                    CheckboxListTile(
                      title: Text('최대 인정금액으로 계산', style: textTheme.bodyLarge),
                      value:
                          _paymentAmountOption ==
                          PaymentAmountOption.maxRecognized,
                      onChanged: (bool? value) {
                        if (value == true) {
                          setState(
                            () => _paymentAmountOption =
                                PaymentAmountOption.maxRecognized,
                          );
                        }
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      activeColor: colorScheme.primary,
                    ),
                    CheckboxListTile(
                      title: Text('대표 금액을 입력하여 계산', style: textTheme.bodyLarge),
                      value:
                          _paymentAmountOption ==
                          PaymentAmountOption.customAmount,
                      onChanged: (bool? value) {
                        if (value == true) {
                          setState(
                            () => _paymentAmountOption =
                                PaymentAmountOption.customAmount,
                          );
                        }
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      activeColor: colorScheme.primary,
                    ),
                    if (_paymentAmountOption ==
                        PaymentAmountOption.customAmount)
                      Padding(
                        padding: EdgeInsets.only(
                          top: 8.h,
                          left: 16.w,
                          right: 16.w,
                        ),
                        child: TextFormField(
                          controller: _customAmountController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            CurrencyTextInputFormatter.currency(
                              locale: 'ko',
                              symbol: '',
                              decimalDigits: 0,
                            ),
                          ],
                          decoration: inputDecoration.copyWith(
                            labelText: '월 대표 납입액 입력',
                            suffixText: '원',
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_selectedPaymentDay == null ||
                          _selectedStartDate == null ||
                          _selectedEndDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('모든 필수 필드를 입력해주세요.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      String paymentAmountOptionString;
                      int? standardPaymentAmount;

                      if (_paymentAmountOption ==
                          PaymentAmountOption.maxRecognized) {
                        paymentAmountOptionString = 'maximum';
                      } else {
                        paymentAmountOptionString = 'standard';
                        final cleanedAmount = _customAmountController.text
                            .replaceAll(RegExp(r'[^0-9]'), '');
                        standardPaymentAmount = int.tryParse(cleanedAmount);
                        if (standardPaymentAmount == null ||
                            standardPaymentAmount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('유효한 납입액을 입력해주세요.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                      }

                      final requestEntity = RecognitionCalculatorRequestEntity(
                        paymentDay: _selectedPaymentDay!,
                        startDate: _selectedStartDate!,
                        endDate: _selectedEndDate!,
                        paymentAmountOption: paymentAmountOptionString,
                        standardPaymentAmount: standardPaymentAmount,
                        payments: null,
                      );

                      context.read<CalculatorBloc>().add(
                        CalculateRecognition(requestEntity: requestEntity),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: EdgeInsets.symmetric(
                        horizontal: 32.w,
                        vertical: 16.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      textStyle: textTheme.titleMedium,
                    ),
                    child: const Text('납입 내역 생성'),
                  ),
                ],
              ),
            ],
          ),
        ),
        bottomNavigationBar: const SafeArea(child: BannerAdWidget()),
      ),
    );
  }
}
