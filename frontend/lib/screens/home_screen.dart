import 'package:flutter/material.dart';
import 'package:frontend/screens/calculator_screen.dart';

onPressed(context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const Calculator()),
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(onPressed: null, icon: Icon(Icons.menu)),
        elevation: 2,
        backgroundColor: colors.primaryContainer,
        // foregroundColor: Colors.green,
        // title: const Text('청약 박스'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                  image: const DecorationImage(
                    image: AssetImage('assets/images/calculator.png'),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "청약 인정회차",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "공공분양 당첨 전략의 필수",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "주택청약 인정 회차는 공공분양(일반) 당첨의 필수 조건입니다. 인정 회차 계산기를 이용하여 나의 청약 인정 회차를 미리 확인해보세요.",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                          ),
                          onPressed: () => onPressed(context),
                          child: Text(
                            "청약 인정회차 계산기",
                            style: TextStyle(color: colors.onPrimary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
