import 'package:flutter/material.dart';
import 'package:frontend/models/calculator_model.dart';
import 'package:frontend/models/payment_schdule_model.dart';
import 'package:frontend/services/api_services.dart';

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  final _formKey = GlobalKey<FormState>();

  DateTime? openDate, endDate;
  int? dueDay;

  dynamic schedule;

  Future<void> _pickDate(
    Function(DateTime) onPicked, {
    DateTime? initialDate,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );

    if (picked != null) {
      setState(() {
        onPicked(picked);
      });
    }
  }

  Future<void> _onGenerate() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final request = CalculatorRequest(
        openDate: openDate!,
        dueDay: 1,
        endDate: endDate,
      );

      try {
        final result = await ApiServices.generatePaymentSchedule(request);
        setState(() {
          schedule = result;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("납입내역 생성 성공 ✅")));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("납입내역 생성 실패: $e")));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("입력값을 확인하세요")));
    }
  }

  Future<void> _showEditDialog(int installmentNo) async {
    final paidDate = schedule.payments
        .firstWhere((p) => p.installmentNo == installmentNo)
        .paidDate;
    DateTime? picked = await showDatePicker(
      context: context,
      // initialDate: DateTime.now(),
      initialDate: DateTime.parse(paidDate),
      firstDate: DateTime(1980),
      lastDate: DateTime(2100),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );

    if (picked != null) {
      PaymentScheduleRequest requestSchdule =
          PaymentScheduleRequest.fromResponse(schedule);

      final updatePayment = requestSchdule.payments.firstWhere(
        (p) => p.installmentNo == installmentNo,
      );
      updatePayment.paidDate = picked.toIso8601String().split('T')[0];

      try {
        final updated = await ApiServices.recalculateSchedule(requestSchdule);
        setState(() {
          schedule = updated;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("재계산 성공")));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("재계산 실패: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('청약 인정금액 계산기')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      openDate == null
                          ? "계산 시작일을 선택하세요"
                          : "계산 시작일: ${openDate!.toLocal().toString().split(' ')[0]}",
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _pickDate(
                      (d) => openDate = d,
                      initialDate: DateTime.now(),
                    ),
                    child: const Text("날짜 선택"),
                  ),
                ],
              ),
              // const SizedBox(height: 16),
              // TextFormField(
              //   decoration: const InputDecoration(
              //     labelText: "납입일자 (1~28일)",
              //     border: OutlineInputBorder(),
              //   ),
              //   keyboardType: TextInputType.number,
              //   validator: (val) {
              //     if (val == null || val.isEmpty) {
              //       return '납입일자를 입력하세요';
              //     }
              //     final day = int.tryParse(val);
              //     if (day == null || day < 1 || day > 28) {
              //       return '1에서 28 사이의 숫자를 입력하세요';
              //     }
              //     return null;
              //   },
              //   onSaved: (val) => dueDay = int.tryParse(val!),
              // ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      endDate == null
                          ? "계산 종료일을 선택하세요"
                          : "계산 종료일: ${endDate!.toLocal().toString().split(' ')[0]}",
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _pickDate(
                      (d) => endDate = d,
                      initialDate: DateTime.now(),
                    ),
                    child: const Text("날짜 선택"),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onGenerate,
                  child: const Text("생성"),
                ),
              ),
              const SizedBox(height: 24),
              if (schedule != null) ...[
                Expanded(child: ListView(children: _buildYearlyGroups())),
                Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            Text(
                              "총 회차: ${schedule.totalInstallments} 연체총합: ${schedule.totalDelayDays}일 선납총합: ${schedule.totalPrepaidDays}일",
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildYearlyGroups() {
    Map<String, List<dynamic>> byYear = {};
    for (var p in schedule.payments) {
      final year = p.dueDate.substring(0, 4);
      byYear.putIfAbsent(year, () => []).add(p);
    }

    return byYear.entries.map((entry) {
      final year = entry.key;
      final payments = entry.value;
      final totalDelayDays = payments.fold<int>(
        0,
        (sum, p) => sum + ((p.delayDays ?? 0) as int),
      );
      final totalPrepaidDays = payments.fold<int>(
        0,
        (sum, p) => sum + ((p.prepaidDays ?? 0) as int),
      );
      return ExpansionTile(
        title: Text("$year년 (연체합: $totalDelayDays일, 선납합: $totalPrepaidDays일)"),
        children: payments.asMap().entries.map((e) {
          final payment = e.value;
          return ListTile(
            title: Text("${payment.installmentNo} 회차: ${payment.dueDate}"),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("실제: ${payment.paidDate ?? '-'}"),
                Text(
                  "연체: ${payment.delayDays}일 연체합: ${payment.totalDelayDays}일 선납: ${payment.prepaidDays}일 선납합: ${payment.totalPrepaidDays}일",
                ),
                Text("인정: ${payment.recognizedDate ?? '-'}"),
              ],
            ),
            trailing: const Icon(Icons.edit, size: 18),
            onTap: () => _showEditDialog(payment.installmentNo),
          );
        }).toList(),
      );
    }).toList();
  }
}
