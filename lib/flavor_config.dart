import 'package:flutter_dotenv/flutter_dotenv.dart';

enum AppFlavor { dev, stg, prod }

class FlavorConfig {
  static AppFlavor? _flavor;
  
  static AppFlavor get flavor => _flavor!;
  
  static String get envFile {
    switch (_flavor) {
      case AppFlavor.dev:
        return '.env.dev';
      case AppFlavor.stg:
        return '.env.stg';
      case AppFlavor.prod:
        return '.env.prod';
      default:
        return '.env.prod';
    }
  }

  static Future<void> initialize(AppFlavor flavor) async {
    _flavor = flavor;
    await dotenv.load(fileName: envFile);
  }

  static String get apiUrl => dotenv.env['API_URL'] ?? '';
  static String get appName => dotenv.env['APP_NAME'] ?? 'The Last King';
}
