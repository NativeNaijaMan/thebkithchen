import 'package:shared_preferences/shared_preferences.dart';

/// Persists stars and light settings. Offline-only; matches GDD privacy posture.
class ProgressStore {
  ProgressStore(this._prefs);

  final SharedPreferences _prefs;

  static Future<ProgressStore> load() async {
    final prefs = await SharedPreferences.getInstance();
    return ProgressStore(prefs);
  }

  int starsForLevel(String levelId) {
    return _prefs.getInt(_starsKey(levelId)) ?? 0;
  }

  /// Keeps the best stars earned per level (1–3).
  Future<void> mergeBestStars(String levelId, int stars) async {
    final clamped = stars.clamp(0, 3);
    final current = starsForLevel(levelId);
    if (clamped > current) {
      await _prefs.setInt(_starsKey(levelId), clamped);
    }
  }

  /// After the first full boot, splash uses a shorter delay (Phase 5).
  bool get hasCompletedSplashBoot => _prefs.getBool('splash_boot_done') ?? false;

  Future<void> markSplashBootDone() async {
    await _prefs.setBool('splash_boot_done', true);
  }

  /// Optional one-time Health & Safety acknowledgment (Phase 5).
  bool get healthSafetyAcknowledged =>
      _prefs.getBool('health_safety_ack') ?? false;

  Future<void> setHealthSafetyAcknowledged() async {
    await _prefs.setBool('health_safety_ack', true);
  }

  String? get lastPlayedLevelId => _prefs.getString('last_played_level');

  Future<void> setLastPlayedLevelId(String levelId) async {
    await _prefs.setString('last_played_level', levelId);
  }

  /// Level 1 always unlocked; later shifts unlock after any stars on the prior ticket.
  bool isLevelUnlocked(String levelId, List<String> campaignOrder) {
    final idx = campaignOrder.indexOf(levelId);
    if (idx < 0) return false;
    if (idx == 0) return true;
    final prev = campaignOrder[idx - 1];
    return starsForLevel(prev) >= 1;
  }

  String? clockInLevelId(List<String> campaignOrder) {
    final last = lastPlayedLevelId;
    if (last != null &&
        campaignOrder.contains(last) &&
        isLevelUnlocked(last, campaignOrder)) {
      return last;
    }
    for (final id in campaignOrder) {
      if (isLevelUnlocked(id, campaignOrder)) {
        return id;
      }
    }
    return campaignOrder.isNotEmpty ? campaignOrder.first : null;
  }

  String _starsKey(String levelId) => 'stars_$levelId';
}
