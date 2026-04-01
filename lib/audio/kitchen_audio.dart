import 'package:flutter/services.dart';

/// Haptic-only feedback for puzzle interactions.
final class KitchenAudio {
  KitchenAudio._();

  static final KitchenAudio instance = KitchenAudio._();

  Future<void> playCorrect() async {
    await HapticFeedback.mediumImpact();
  }

  Future<void> playWrong() async {
    await HapticFeedback.heavyImpact();
  }

  Future<void> playVictory() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    await HapticFeedback.mediumImpact();
  }

  Future<void> playTap() async {
    await HapticFeedback.lightImpact();
  }
}
