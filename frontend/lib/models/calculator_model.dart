class CalculatorRequest {
  final DateTime openDate;
  final int dueDay;
  final DateTime endDate;

  CalculatorRequest({
    required this.openDate,
    required this.dueDay,
    DateTime? endDate,
  }) : endDate = endDate ?? DateTime.now();

  Map<String, dynamic> toJson() {
    String formatDate(DateTime date) =>
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    return {
      'open_date': formatDate(openDate),
      'due_day': dueDay,
      'end_date': formatDate(endDate),
    };
  }
}
