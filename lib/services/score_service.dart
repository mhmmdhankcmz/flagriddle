import 'package:shared_preferences/shared_preferences.dart';

class ScoreService {
  static const String _highScoreKey = 'highScore';
  static const String _totalGamesKey = 'totalGames';
  static const String _totalCorrectKey = 'totalCorrect';
  static const String _totalQuestionsKey = 'totalQuestions';

  static Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_highScoreKey) ?? 0;
  }

  static Future<bool> saveScore(int score, int totalQuestions) async {
    final prefs = await SharedPreferences.getInstance();

    // Update total statistics
    int totalGames = prefs.getInt(_totalGamesKey) ?? 0;
    int totalCorrect = prefs.getInt(_totalCorrectKey) ?? 0;
    int totalQuestionsPlayed = prefs.getInt(_totalQuestionsKey) ?? 0;

    await prefs.setInt(_totalGamesKey, totalGames + 1);
    await prefs.setInt(_totalCorrectKey, totalCorrect + score);
    await prefs.setInt(_totalQuestionsKey, totalQuestionsPlayed + totalQuestions);

    // Check and update high score
    int currentHighScore = prefs.getInt(_highScoreKey) ?? 0;
    int percentage = (score * 100) ~/ totalQuestions;

    if (percentage > currentHighScore) {
      await prefs.setInt(_highScoreKey, percentage);
      return true; // New high score!
    }
    return false;
  }

  static Future<Map<String, int>> getStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'highScore': prefs.getInt(_highScoreKey) ?? 0,
      'totalGames': prefs.getInt(_totalGamesKey) ?? 0,
      'totalCorrect': prefs.getInt(_totalCorrectKey) ?? 0,
      'totalQuestions': prefs.getInt(_totalQuestionsKey) ?? 0,
    };
  }

  static Future<void> resetStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_highScoreKey);
    await prefs.remove(_totalGamesKey);
    await prefs.remove(_totalCorrectKey);
    await prefs.remove(_totalQuestionsKey);
  }
}
