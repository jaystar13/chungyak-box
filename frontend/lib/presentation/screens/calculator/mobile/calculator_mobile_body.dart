import 'package:chungyak_box/presentation/layouts/main_layout.dart';
import 'package:chungyak_box/presentation/screens/calculator/calculator_result_screen.dart';
import 'package:chungyak_box/data/datasources/admob_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
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

class _CalculatorMobileBodyState extends State<CalculatorMobileBody> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  int? _selectedPaymentDay;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  bool _isGuideExpanded = true;

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
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
            } else if (state is InitialCalculationSuccess) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<CalculatorBloc>(), // Use existing BLoC
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
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('오류: ${state.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                    ),
                    child: ExpansionTile(
                      tilePadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      childrenPadding:
                          EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                      initiallyExpanded: _isGuideExpanded,
                      onExpansionChanged: (expanded) {
                        setState(() => _isGuideExpanded = expanded);
                      },
                      title: Text(
                        '입력 가이드',
                        style: textTheme.titleMedium!.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                      trailing: Icon(
                        _isGuideExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: colorScheme.primary,
                      ),
                      children: [
                        SizedBox(height: 8.h),
                        ...[
                          '납입일: 매월 청약 금액을 납부하기로 한 약속 일자를 선택합니다.',
                          '시작년월: 주택청약통장 개설년월을 입력합니다.',
                          '종료년월: 계산 종료년월을 입력합니다.',
                        ].map(
                          (guide) => Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 6.w,
                                  height: 6.w,
                                  margin: EdgeInsets.only(top: 6.h),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    guide,
                                    style: textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: colorScheme.surface.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            '최대인정금액이 변경된 2024년 11월을 기준으로 이전 내역은 10만원, 이후는 25만원의 납입 인정 금액으로 자동 생성됩니다. 금액 및 실제납입일 변경은 납입 내역 생성 후 계산 결과 화면에서 변경할 수 있습니다.',
                            style: textTheme.bodySmall!.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                DropdownButtonFormField<int>(
                  initialValue: _selectedPaymentDay,
                  items: List.generate(28, (index) => index + 1)
                      .map(
                        (day) =>
                            DropdownMenuItem(value: day, child: Text('$day일')),
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
                    labelText: '시작년월', // Use labelText
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
                  onTap: () => _selectMonth(context, _endDateController, false),
                  decoration: inputDecoration.copyWith(
                    labelText: '종료년월', // Use labelText
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () =>
                          _selectMonth(context, _endDateController, false),
                    ),
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

                      final requestEntity = RecognitionCalculatorRequestEntity(
                        paymentDay: _selectedPaymentDay!,
                        startDate: _selectedStartDate!,
                        endDate: _selectedEndDate!,
                        paymentAmountOption: 'maximum',
                        standardPaymentAmount: null,
                        payments: null, // Assuming no custom payments for now
                      );

                      context.read<CalculatorBloc>().add(
                        GenerateInitialResult(requestEntity: requestEntity),
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
        );
      },
    );
  }
}
