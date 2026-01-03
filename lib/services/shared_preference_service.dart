import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceService {
  final SharedPreferences _prefs;

  SharedPreferenceService(this._prefs);

  static const _highScoreKey = 'high_score';

  Future<void> saveHighScore(int score) async {
    await _prefs.setInt(_highScoreKey, score);
  }

  Future<int> getHighScore() async {
    return _prefs.getInt(_highScoreKey) ?? 0;
  }
}
