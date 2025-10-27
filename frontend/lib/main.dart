import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:chungyak_box/ui/screens/home_screen.dart';
import 'package:chungyak_box/ui/screens/calculator_screen.dart';
import 'package:chungyak_box/ui/routes.dart'; // ✅ 새로 추가
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:chungyak_box/core/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 광고 초기화
  MobileAds.instance.initialize();

  // Firebase 초기화
  await Firebase.initializeApp();

  // 현재는 세로 레이아웃만 허용
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.0)),
              child: child!,
            );
          },

          initialRoute: Routes.home,
          routes: {
            Routes.home: (context) => const HomeScreen(),
            Routes.calculator: (context) => const CalculatorScreen(),
          },

          locale: const Locale('ko', 'KR'),
          supportedLocales: const [Locale('en', 'US'), Locale('ko', 'KR')],
          localizationsDelegates: const [
            // AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}