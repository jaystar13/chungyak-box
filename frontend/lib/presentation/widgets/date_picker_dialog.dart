import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

Future<DateTime?> showCustomDatePicker({
  required BuildContext context,
  DateTime? initialDate,
}) async {
  final colorScheme = Theme.of(context).colorScheme;
  DateTime? pickedDate;

  return await showDialog<DateTime?>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.r),
        ),
        contentPadding: EdgeInsets.all(20.r),
        content: SizedBox(
          width: 320.w,
          height: 380.h,
          child: SfDateRangePicker(
            onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
              if (args.value is DateTime) {
                pickedDate = args.value;
              }
            },
            selectionMode: DateRangePickerSelectionMode.single,
            initialSelectedDate: initialDate,
            initialDisplayDate: initialDate,
            headerStyle: DateRangePickerHeaderStyle(
              textAlign: TextAlign.center,
              textStyle: Theme.of(context).textTheme.titleMedium,
            ),
            monthViewSettings: const DateRangePickerMonthViewSettings(
              firstDayOfWeek: 7,
            ),
            showNavigationArrow: true,
            view: DateRangePickerView.month,
            selectionColor: colorScheme.primary,
            todayHighlightColor: colorScheme.primary,
          ),
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
            child: const Text('취소'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: colorScheme.primary),
            child: const Text('확인'),
            onPressed: () {
              Navigator.of(context).pop(pickedDate);
            },
          ),
        ],
      );
    },
  );
}

Future<DateTime?> showCustomMonthPicker({
  required BuildContext context,
  DateTime? initialDate,
}) async {
  final colorScheme = Theme.of(context).colorScheme;
  return await showMonthPicker(
    context: context,
    initialDate: initialDate ?? DateTime.now(),
    firstDate: DateTime(2000),
    // lastDate: DateTime.now().add(const Duration(days: 365)),
    monthPickerDialogSettings: MonthPickerDialogSettings(
      headerSettings: PickerHeaderSettings(
        headerBackgroundColor: colorScheme.primaryContainer,
        headerSelectedIntervalTextStyle: TextStyle(
          color: colorScheme.onPrimaryContainer,
          fontSize: 14,
        ),
        headerCurrentPageTextStyle: TextStyle(
          color: colorScheme.onPrimaryContainer,
          fontSize: 18,
        ),
      ),
    ),
  );
}
