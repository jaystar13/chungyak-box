class CalculatorRequestModel {
  final String openDate;
  final int dueDay;
  final String endDate;

  CalculatorRequestModel({
    required this.openDate,
    required this.dueDay,
    required this.endDate,
  });

  Map<String, dynamic> toJson() {
    return {'open_date': openDate, 'due_day': dueDay, 'end_date': endDate};
  }
}
