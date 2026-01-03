
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/scenario.dart';
import '../data/scenarios_data.dart';
import '../services/shared_preference_service.dart';

class GameState {
  final int money;
  final int army;
  final int people;
  final int religion;
  final bool isGameOver;
  final String? gameOverReason;
  final List<Scenario> scenarioDeck;
  final int currentScenarioIndex;
  final int yearsReigned;
  final int highScore;
  final int swipesSinceLastAd;
  final int nextAdThreshold;
  final bool showAd;

  GameState({
    this.money = 50,
    this.army = 50,
    this.people = 50,
    this.religion = 50,
    this.isGameOver = false,
    this.gameOverReason,
    required this.scenarioDeck,
    this.currentScenarioIndex = 0,
    this.yearsReigned = 0,
    this.highScore = 0,
    this.swipesSinceLastAd = 0,
    this.nextAdThreshold = 5, // Initial default, will be randomized
    this.showAd = false,
  });

  GameState copyWith({
    int? money,
    int? army,
    int? people,
    int? religion,
    bool? isGameOver,
    String? gameOverReason,
    List<Scenario>? scenarioDeck,
    int? currentScenarioIndex,
    int? yearsReigned,
    int? highScore,
    int? swipesSinceLastAd,
    int? nextAdThreshold,
    bool? showAd,
  }) {
    return GameState(
      money: money ?? this.money,
      army: army ?? this.army,
      people: people ?? this.people,
      religion: religion ?? this.religion,
      isGameOver: isGameOver ?? this.isGameOver,
      gameOverReason: gameOverReason ?? this.gameOverReason,
      scenarioDeck: scenarioDeck ?? this.scenarioDeck,
      currentScenarioIndex: currentScenarioIndex ?? this.currentScenarioIndex,
      yearsReigned: yearsReigned ?? this.yearsReigned,
      highScore: highScore ?? this.highScore,
      swipesSinceLastAd: swipesSinceLastAd ?? this.swipesSinceLastAd,
      nextAdThreshold: nextAdThreshold ?? this.nextAdThreshold,
      showAd: showAd ?? this.showAd,
    );
  }
}

class GameNotifier extends StateNotifier<GameState> {
  final SharedPreferenceService _prefsService;

  GameNotifier(this._prefsService) : super(GameState(scenarioDeck: List.from(initialScenarios))) {
    _loadHighScore();
    _randomizeNextThreshold();
  }

  Future<void> _loadHighScore() async {
    final highScore = await _prefsService.getHighScore();
    state = state.copyWith(highScore: highScore);
  }
  
  void _randomizeNextThreshold() {
    // Random between 2 and 9 inclusive (x > 1, x < 10)
    // Random().nextInt(max) returns 0 to max-1
    // We want 2,3,4,5,6,7,8,9. 
    // Range size is 8. (9 - 2 + 1)
    // nextInt(8) -> 0..7
    // + 2 -> 2..9
    final next = Random().nextInt(8) + 2;
    state = state.copyWith(nextAdThreshold: next, swipesSinceLastAd: 0);
  }

  void adShown() {
    state = state.copyWith(showAd: false);
    _randomizeNextThreshold();
  }

  void makeChoice(Choice choice) {
    if (state.isGameOver) return;

    final newMoney = (state.money + choice.effect.money).clamp(0, 100);
    final newArmy = (state.army + choice.effect.army).clamp(0, 100);
    final newPeople = (state.people + choice.effect.people).clamp(0, 100);
    final newReligion = (state.religion + choice.effect.religion).clamp(0, 100);
    
    final newYearsReigned = state.yearsReigned + 1; // Each card is 1 year (or turn)
    
    // Check Ad Logic
    int currentSwipes = state.swipesSinceLastAd + 1;
    bool shouldShowAd = false;
    if (currentSwipes >= state.nextAdThreshold) {
      shouldShowAd = true;
      // We don't reset swipes here, we wait for adShown() to confirm it was handled
    }

    // check game over
    String? reason;
    if (newMoney <= 0) reason = "Ngân khố cạn kiệt, vương triều sụp đổ.";
    if (newArmy <= 0) reason = "Quân đội tan rã, giặc ngoại xâm chiếm đóng.";
    if (newPeople <= 0) reason = "Dân chúng nổi loạn, lật đổ ngai vàng.";
    if (newReligion <= 0) reason = "Thần linh ruồng bỏ, tai ương giáng xuống.";
    
    if (reason != null) {
      _checkAndSaveHighScore(newYearsReigned);
      state = state.copyWith(
        money: newMoney,
        army: newArmy,
        people: newPeople,
        religion: newReligion,
        yearsReigned: newYearsReigned,
        isGameOver: true,
        gameOverReason: reason,
        swipesSinceLastAd: currentSwipes, // Persist swipe count even on game over? logic choice.
        showAd: shouldShowAd,
      );
    } else {
       // Move to next card
      int nextIndex = state.currentScenarioIndex + 1;
      if (nextIndex >= state.scenarioDeck.length) {
         nextIndex = 0;
         state.scenarioDeck.shuffle();
      }

      state = state.copyWith(
        money: newMoney,
        army: newArmy,
        people: newPeople,
        religion: newReligion,
        yearsReigned: newYearsReigned,
        currentScenarioIndex: nextIndex,
        swipesSinceLastAd: currentSwipes,
        showAd: shouldShowAd,
      );
    }
  }

  Future<void> _checkAndSaveHighScore(int currentScore) async {
    if (currentScore > state.highScore) {
      await _prefsService.saveHighScore(currentScore);
      state = state.copyWith(highScore: currentScore); // Update locally immediately
    }
  }

  void restartGame() {
    // Keep high score from previous state
    state = GameState(
      scenarioDeck: List.from(initialScenarios)..shuffle(),
      highScore: state.highScore,
    );
  }
}

final sharedPreferencesServiceProvider = Provider<SharedPreferenceService>((ref) {
  throw UnimplementedError(); // Override in main
});

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  final prefsService = ref.watch(sharedPreferencesServiceProvider);
  return GameNotifier(prefsService);
});
