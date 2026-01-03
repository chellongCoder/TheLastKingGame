import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/game_screen.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/game_provider.dart';
import 'services/shared_preference_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  
  final prefs = await SharedPreferences.getInstance();
  final prefsService = SharedPreferenceService(prefs);

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesServiceProvider.overrideWithValue(prefsService),
      ],
      child: const TheLastKingApp(),
    ),
  );
}

class TheLastKingApp extends StatelessWidget {
  const TheLastKingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vị Vua Cuối Cùng',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
        textTheme: GoogleFonts.medievalSharpTextTheme(), // English medieval font for feel? Or Robobo/Merriweather for vn
      ),
      home: const GameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
