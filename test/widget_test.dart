// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.


import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:magnetic_event/main.dart';
import 'package:magnetic_event/providers/game_provider.dart';
import 'package:magnetic_event/services/shared_preference_service.dart';
import 'package:magnetic_event/utils/ad_helper.dart';

class MockSharedPreferenceService extends Fake implements SharedPreferenceService {
  int _score = 0;
  @override
  Future<int> getHighScore() async => _score;
  @override
  Future<void> saveHighScore(int score) async => _score = score;
}

void main() {
  testWidgets('Game starts with resources and no crash', (WidgetTester tester) async {
    AdHelper.isTestMode = true;
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
           sharedPreferencesServiceProvider.overrideWithValue(MockSharedPreferenceService()),
        ],
        child: const TheLastKingApp(),
      ),
    );

    // Verify that our game starts with resources.
    expect(find.text('Tiền'), findsOneWidget);
    expect(find.text('Quân'), findsOneWidget);
  });
}
