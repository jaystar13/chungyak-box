import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:chungyak_box/routes/app_routes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:chungyak_box/core/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chungyak_box/presentation/viewmodels/auth_bloc.dart';
import 'package:chungyak_box/presentation/viewmodels/auth_event.dart';
import 'package:chungyak_box/presentation/viewmodels/login_bloc.dart';

import 'package:chungyak_box/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  configureDependencies();
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
        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(
              create: (context) => getIt<AuthBloc>()..add(const AppStarted()),
            ),
            BlocProvider<LoginBloc>(create: (context) => getIt<LoginBloc>()),
          ],
          child: MaterialApp(
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(1.0)),
                child: child!,
              );
            },
            initialRoute: Routes.home,
            onGenerateRoute: Routes.generateRoute,
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
          ),
        );
      },
    );
  }
}
