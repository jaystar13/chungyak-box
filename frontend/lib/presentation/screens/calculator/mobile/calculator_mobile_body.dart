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

class CalculatorMobileBody extends StatefulWidget {
  const CalculatorMobileBody({super.key});

  @override
  State<CalculatorMobileBody> createState() => _CalculatorMobileBodyState();
}

enum PaymentAmountOption { maxRecognized, customAmount }

class _CalculatorMobileBodyState extends State<CalculatorMobileBody> {
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
          // Set to the first day of the selected month
          _selectedStartDate = DateTime(pickedDate.year, pickedDate.month, 1);
          controller.text = DateFormat('yyyy-MM').format(_selectedStartDate!);
        } else {
          // Set to the last day of the selected month
          _selectedEndDate = DateTime(pickedDate.year, pickedDate.month + 1, 0);
          controller.text = DateFormat('yyyy-MM').format(_selectedEndDate!);
        }
      });
    }
  }

  Widget _buildGroupContainer({
    required BuildContext context,
    required String title,
    required Widget child,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(
            top: 12.h,
            bottom: 8.h,
          ), // Adjusted margin to make space for title
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.5),
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Padding(
            // Added padding for the child content
            padding: EdgeInsets.only(
              top: 12.h,
            ), // Push content down to avoid title overlap
            child: child,
          ),
        ),
        Positioned(
          left: 16.w, // Align with the padding of the container
          top: 0, // Position at the top edge
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            color:
                colorScheme.surface, // Background color to hide the border line
            child: Text(
              title,
              style: textTheme.titleMedium!.copyWith(
                color: colorScheme.primary,
                fontSize: 16.sp,
              ), // Emphasize title
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
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
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
          floatingLabelBehavior:
              FloatingLabelBehavior.auto, // Ensure floating label behavior
        );
        return BlocListener<CalculatorBloc, CalculatorState>(
          listener: (context, state) {
            if (state is CalculatorLoading) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('계산 중...')));
            } else if (state is RecognitionCalculated) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              Navigator.of(context).pushNamed(
                '/calculator/result',
                arguments: state.result, // Pass the result to the next screen
              );
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
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  DropdownButtonFormField<int>(
                    initialValue: _selectedPaymentDay,
                    items: List.generate(28, (index) => index + 1)
                        .map(
                          (day) => DropdownMenuItem(
                            value: day,
                            child: Text('$day일'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedPaymentDay = value),
                    decoration: inputDecoration.copyWith(
                      labelText:
                          '납입일 선택 (1일 ~ 28일)', // Use labelText for floating effect
                    ),
                  ),
                  SizedBox(height: 24.h),
                  TextFormField(
                    controller: _startDateController,
                    readOnly: true,
                    onTap: () =>
                        _selectMonth(context, _startDateController, true),
                    decoration: inputDecoration.copyWith(
                      labelText: '시작일', // Use labelText
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () =>
                            _selectMonth(context, _startDateController, true),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  TextFormField(
                    controller: _endDateController,
                    readOnly: true,
                    onTap: () =>
                        _selectMonth(context, _endDateController, false),
                    decoration: inputDecoration.copyWith(
                      labelText: '종료일', // Use labelText
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () =>
                            _selectMonth(context, _endDateController, false),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  _buildGroupContainer(
                    context: context,
                    title: '납입 금액',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '납입 내역 생성에 필요한 초기 납입 금액을 선택합니다. 최대 인정 금액은 2024년 11월 이전 10만원, 이후 25만원입니다.',
                          style: textTheme.bodyMedium!.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12.sp,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        CheckboxListTile(
                          title: Text(
                            '최대 인정금액으로 계산',
                            style: textTheme.bodyLarge!.copyWith(
                              fontSize: 14.sp,
                            ),
                          ),
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
                          title: Text(
                            '대표 금액을 입력하여 계산',
                            style: textTheme.bodyLarge!.copyWith(
                              fontSize: 14.sp,
                            ),
                          ),
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

                  SizedBox(height: 18.h),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_selectedPaymentDay == null ||
                            _selectedStartDate == null ||
                            _selectedEndDate == null) {
                          // Show an error or a snackbar indicating missing fields
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

                        final requestEntity =
                            RecognitionCalculatorRequestEntity(
                              paymentDay: _selectedPaymentDay!,
                              startDate: _selectedStartDate!,
                              endDate: _selectedEndDate!,
                              paymentAmountOption: paymentAmountOptionString,
                              standardPaymentAmount: standardPaymentAmount,
                              payments:
                                  null, // Assuming no custom payments for now
                            );

                        context.read<CalculatorBloc>().add(
                          CalculateRecognition(requestEntity: requestEntity),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        textStyle: textTheme.titleMedium!.copyWith(
                          fontSize: 16.sp,
                        ),
                      ),
                      child: const Text('납입 내역 생성'),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
            bottomNavigationBar: const SafeArea(child: BannerAdWidget()),
          ),
        );
      },
    );
  }
}
