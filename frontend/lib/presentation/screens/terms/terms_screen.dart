import 'package:chungyak_box/presentation/screens/terms/mobile/terms_mobile_body.dart';
import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  static String get routeName => '/terms';

  @override
  Widget build(BuildContext context) {
    // TODO: Implement responsive layout for tablet
    return Scaffold(
      appBar: AppBar(title: const Text('약관 동의')),
      body: const SafeArea(child: TermsMobileBody()),
    );
  }
}
