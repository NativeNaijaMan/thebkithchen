import 'dart:convert';

import 'package:flutter/services.dart';

/// Puzzle level data loaded from `assets/levels/*.json`.
class LevelDefinition {
  const LevelDefinition({
    required this.id,
    required this.name,
    required this.recipeRequest,
    required this.objectiveText,
    required this.gridSize,
    required this.memorizeSeconds,
    required this.timerSeconds,
    required this.correctItemIds,
    required this.distractorItemIds,
    required this.minCorrectThreshold,
  });

  final String id;
  final String name;

  /// The recipe the player must fulfill (e.g. "Fry an Egg").
  final String recipeRequest;

  /// Hint text shown on the ticket.
  final String objectiveText;

  /// Grid dimension (e.g. 4 means 4x4).
  final int gridSize;

  /// How long items are visible during the memorize phase.
  final double memorizeSeconds;

  /// Countdown for the recall phase.
  final double timerSeconds;

  /// Item IDs the player needs to select.
  final List<String> correctItemIds;

  /// Distractor item IDs that fill the remaining grid cells.
  final List<String> distractorItemIds;

  /// Minimum correct selections required to pass.
  final int minCorrectThreshold;

  factory LevelDefinition.fromJson(Map<String, dynamic> json) {
    return LevelDefinition(
      id: json['id'] as String,
      name: json['name'] as String,
      recipeRequest: json['recipeRequest'] as String,
      objectiveText: json['objectiveText'] as String,
      gridSize: (json['gridSize'] as num).toInt(),
      memorizeSeconds: (json['memorizeSeconds'] as num).toDouble(),
      timerSeconds: (json['timerSeconds'] as num).toDouble(),
      correctItemIds:
          (json['correctItemIds'] as List<dynamic>).cast<String>(),
      distractorItemIds:
          (json['distractorItemIds'] as List<dynamic>).cast<String>(),
      minCorrectThreshold: (json['minCorrectThreshold'] as num).toInt(),
    );
  }

  static Future<LevelDefinition> loadFromAssets(String levelId) async {
    final raw = await rootBundle.loadString('assets/levels/$levelId.json');
    final map = json.decode(raw) as Map<String, dynamic>;
    return LevelDefinition.fromJson(map);
  }
}
