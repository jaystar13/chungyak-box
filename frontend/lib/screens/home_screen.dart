import 'package:chungyak_box/services/admob_services.dart';
import 'package:flutter/material.dart';
import 'package:chungyak_box/screens/calculator_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
        leading: Builder(
          builder: (context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: Icon(Icons.menu, color: colors.onPrimaryContainer),
            );
          },
        ),
        elevation: 2,
        backgroundColor: colors.primaryContainer,
        // foregroundColor: Colors.green,
        // title: const Text('청약 박스'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: kToolbarHeight + MediaQuery.of(context).padding.top,
              color: colors.primaryContainer,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: MediaQuery.of(context).padding.top,
              ),
              // child: Text(
              //   '청약 박스',
              //   style: TextStyle(
              //     color: colors.onPrimaryContainer,
              //     fontSize: 18,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
            ),
            ListTile(
              leading: Icon(Icons.calculate, color: colors.onSurface),
              title: Text(
                '청약 인정회차 계산기',
                style: TextStyle(color: colors.onSurface),
              ),
              onTap: () {
                Navigator.pop(context);
                onPressed(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.email, color: colors.onSurface),
              title: Text('문의하기', style: TextStyle(color: colors.onSurface)),
              onTap: () async {
                Navigator.pop(context);
                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: 'rasccolii@gmail.com',
                  query:
                      'subject=[문의사항]&body=안녕하세요, 청약 계산소 앱에 문의사항이 있어 연락드립니다.',
                );
                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                }
              },
            ),
            const Divider(),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<PackageInfo>(
                    future: PackageInfo.fromPlatform(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final info = snapshot.data!;
                        return Text(
                          '버전 ${info.version}',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        );
                      } else {
                        return Text(
                          '버전 확인 중...',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        );
                      }
                    },
                  ),
                  SizedBox(height: 4),
                  Text(
                    '© 2025 Chungyak Box',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
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
      bottomNavigationBar: const SafeArea(child: BannerAdWidget()),
    );
  }
}
