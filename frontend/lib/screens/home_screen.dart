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
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        // elevation: 2,
        // backgroundColor: Colors.white,
        // foregroundColor: Colors.green,
        // title: const Text('청약 박스'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => onPressed(context),
                    child: Text("청약 인정금액 계산기"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
