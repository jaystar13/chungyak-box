// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:chungyak_box/screens/home_screen.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Timer(const Duration(seconds: 2), () {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const HomeScreen()),
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.primaryContainer,
//       body: Center(
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             SvgPicture.asset(
//               'assets/icons/app_logo_transparent.svg', // 변환한 SVG 파일 경로
//               width: 30,
//               height: 30,
//               colorFilter: const ColorFilter.mode(
//                 Colors.white, // 색상 변경 가능
//                 BlendMode.srcIn,
//               ),
//             ),
//             const SizedBox(width: 10),
//             const Text("청약박스", style: TextStyle(fontSize: 20)),
//           ],
//         ),
//       ),
//     );
//   }
// }
