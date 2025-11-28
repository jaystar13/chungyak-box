import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static final String baseUrl = dotenv.env['DOMAIN'] ?? 'about:blank';
}
