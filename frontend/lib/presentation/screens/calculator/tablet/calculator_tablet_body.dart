import 'package:chungyak_box/data/datasources/admob_services.dart';
import 'package:chungyak_box/presentation/layouts/main_layout.dart';
import 'package:chungyak_box/presentation/screens/calculator/calculator_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
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
  final PaymentAmountOption _paymentAmountOption =
      PaymentAmountOption.maxRecognized;
  bool _isGuideExpanded = true;

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

  Widget _buildGuideSection(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    const guides = [
      '납입일: 매월 청약 금액을 납부하기로 한 약속 일자를 선택합니다.',
      '시작년월: 주택청약통장 개설년월을 입력합니다.',
      '종료년월: 계산 종료년월을 입력합니다.',
    ];

    final double guideFontSize = (textTheme.bodyLarge?.fontSize ?? 14) + 1;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 6.h),
          childrenPadding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 12.h),
          initiallyExpanded: _isGuideExpanded,
          onExpansionChanged: (expanded) {
            setState(() => _isGuideExpanded = expanded);
          },
          title: Text(
            '입력 가이드',
            style: textTheme.titleLarge!.copyWith(color: colorScheme.primary),
          ),
          trailing: Icon(
            _isGuideExpanded
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down,
            color: colorScheme.primary,
          ),
          children: [
            SizedBox(height: 4.h),
            ...guides.map(
              (guide) => Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 2.h),
                      child: Text(
                        '-',
                        style: textTheme.bodyLarge?.copyWith(
                          fontSize: guideFontSize,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        guide,
                        style: textTheme.bodyLarge?.copyWith(
                          fontSize: guideFontSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: colorScheme.surface.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: RichText(
                text: TextSpan(
                  style: textTheme.bodyLarge?.copyWith(
                    fontSize: guideFontSize,
                    color: colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                  children: [
                    const TextSpan(text: '최대인정금액이 변경된 '),
                    TextSpan(
                      text: '2024년 11월을 기준',
                      style: textTheme.bodyLarge?.copyWith(
                        fontSize: guideFontSize,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.error,
                      ),
                    ),
                    const TextSpan(
                      text:
                          '으로 이전 내역은 10만원, 이후는 25만원의 납입 인정 금액으로 자동 생성됩니다. 금액 및 실제납입일 변경은 납입 내역 생성 후 계산 결과 화면에서 변경할 수 있습니다.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        );

        return BlocListener<CalculatorBloc, CalculatorState>(
          listener: (context, state) {
            if (state is CalculatorLoading) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(const SnackBar(content: Text('계산 중...')));
            } else if (state is InitialCalculationSuccess) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<CalculatorBloc>(),
                    child: const MainLayout(
                      title: '계산 결과',
                      bottomNavigationBar: SafeArea(child: BannerAdWidget()),
                      child: CalculatorResultScreen(),
                    ),
                  ),
                  settings: RouteSettings(
                    name: '/calculator/result',
                    arguments: state.result,
                  ),
                ),
              );
            } else if (state is CalculatorError) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text('오류: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
            }
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildGuideSection(context, colorScheme, textTheme),
                SizedBox(height: 20.h),
                Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    side: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 32.w,
                      vertical: 20.h,
                    ),
                    child: Column(
                      children: [
                        _buildFormRow(
                          label: Text('납입일 선택', style: textTheme.titleMedium),
                          input: DropdownButtonFormField<int>(
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
                              labelText: '1일 ~ 28일',
                            ),
                          ),
                        ),
                        Divider(height: 20.h),
                        _buildFormRow(
                          label: Text('시작년월', style: textTheme.titleMedium),
                          input: TextFormField(
                            controller: _startDateController,
                            readOnly: true,
                            onTap: () => _selectMonth(
                              context,
                              _startDateController,
                              true,
                            ),
                            decoration: inputDecoration.copyWith(
                              labelText: 'YYYY-MM',
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.calendar_today),
                                onPressed: () => _selectMonth(
                                  context,
                                  _startDateController,
                                  true,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Divider(height: 20.h),
                        _buildFormRow(
                          label: Text('종료년월', style: textTheme.titleMedium),
                          input: TextFormField(
                            controller: _endDateController,
                            readOnly: true,
                            onTap: () => _selectMonth(
                              context,
                              _endDateController,
                              false,
                            ),
                            decoration: inputDecoration.copyWith(
                              labelText: 'YYYY-MM',
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.calendar_today),
                                onPressed: () => _selectMonth(
                                  context,
                                  _endDateController,
                                  false,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
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

                        final requestEntity =
                            RecognitionCalculatorRequestEntity(
                              paymentDay: _selectedPaymentDay!,
                              startDate: _selectedStartDate!,
                              endDate: _selectedEndDate!,
                              paymentAmountOption: paymentAmountOptionString,
                              standardPaymentAmount: standardPaymentAmount,
                              payments: null,
                            );

                        context.read<CalculatorBloc>().add(
                          GenerateInitialResult(requestEntity: requestEntity),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: 18.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        textStyle: textTheme.titleMedium,
                      ),
                      child: const Text('납입 내역 생성'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
