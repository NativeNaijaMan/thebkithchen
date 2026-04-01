import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/level_definition.dart';
import 'progress_store.dart';

/// Phases of a puzzle round.
enum PuzzlePhase { memorize, recall, evaluating, won, lost }

/// Represents one tile on the puzzle grid.
class PuzzleTile {
  PuzzleTile({required this.index, required this.itemId});

  final int index;
  final String? itemId;

  bool get isEmpty => itemId == null;
}

/// Per-level runtime state shared by the puzzle grid widget and overlays.
class KitchenRunState extends ChangeNotifier {
  KitchenRunState({
    required this.level,
    required this.progress,
  }) {
    _buildGrid();
  }

  final LevelDefinition level;
  final ProgressStore progress;

  PuzzlePhase phase = PuzzlePhase.memorize;

  late final List<PuzzleTile> tiles;

  final Set<int> selectedIndices = {};

  double _memorizeRemaining = 0;
  double _recallRemaining = 0;
  bool isPaused = false;

  int correctCount = 0;
  int wrongCount = 0;
  Set<int> correctTileIndices = {};

  String? loseReason;

  double get memorizeRemaining => _memorizeRemaining;
  double get recallRemaining => _recallRemaining;

  double get recallFraction =>
      level.timerSeconds > 0
          ? (_recallRemaining / level.timerSeconds).clamp(0.0, 1.0)
          : 0.0;

  void _buildGrid() {
    final totalCells = level.gridSize * level.gridSize;
    final rng = Random();

    final correctIds = List<String>.from(level.correctItemIds);
    final distractorIds = List<String>.from(level.distractorItemIds);
    distractorIds.shuffle(rng);

    final allItems = <String?>[];
    allItems.addAll(correctIds);

    final remainingSlots = totalCells - correctIds.length;
    for (var i = 0; i < remainingSlots && i < distractorIds.length; i++) {
      allItems.add(distractorIds[i]);
    }
    while (allItems.length < totalCells) {
      allItems.add(null);
    }

    allItems.shuffle(rng);

    tiles = List.generate(
      totalCells,
      (i) => PuzzleTile(index: i, itemId: allItems[i]),
    );

    correctTileIndices = {
      for (final tile in tiles)
        if (tile.itemId != null && level.correctItemIds.contains(tile.itemId))
          tile.index,
    };

    _memorizeRemaining = level.memorizeSeconds;
    _recallRemaining = level.timerSeconds;
  }

  void tick(double dt) {
    if (isPaused) return;

    if (phase == PuzzlePhase.memorize) {
      _memorizeRemaining -= dt;
      if (_memorizeRemaining <= 0) {
        _memorizeRemaining = 0;
        phase = PuzzlePhase.recall;
      }
      notifyListeners();
      return;
    }

    if (phase == PuzzlePhase.recall) {
      _recallRemaining -= dt;
      if (_recallRemaining <= 0) {
        _recallRemaining = 0;
        _evaluateSelection();
        if (phase != PuzzlePhase.won) {
          phase = PuzzlePhase.lost;
          loseReason = 'TIMEOUT';
        }
      }
      notifyListeners();
      return;
    }
  }

  void toggleTile(int index) {
    if (phase != PuzzlePhase.recall || isPaused) return;
    if (selectedIndices.contains(index)) {
      selectedIndices.remove(index);
    } else {
      selectedIndices.add(index);
    }
    notifyListeners();

    _checkAutoSubmit();
  }

  void _checkAutoSubmit() {
    final selectedCorrect = selectedIndices
        .where((idx) => correctTileIndices.contains(idx))
        .length;
    if (selectedCorrect == level.correctItemIds.length) {
      submitOrder();
    }
  }

  void submitOrder() {
    if (phase != PuzzlePhase.recall) return;

    phase = PuzzlePhase.evaluating;
    _evaluateSelection();

    if (correctCount >= level.minCorrectThreshold) {
      phase = PuzzlePhase.won;
    } else {
      phase = PuzzlePhase.lost;
      loseReason = 'NOT_ENOUGH_CORRECT';
    }
    notifyListeners();
  }

  void _evaluateSelection() {
    correctCount = 0;
    wrongCount = 0;
    for (final idx in selectedIndices) {
      if (correctTileIndices.contains(idx)) {
        correctCount++;
      } else {
        wrongCount++;
      }
    }
  }

  void setPaused(bool value) {
    if (isPaused == value) return;
    isPaused = value;
    notifyListeners();
  }

  int computeStars() {
    if (phase != PuzzlePhase.won) return 0;
    final allCorrect = correctCount == level.correctItemIds.length;
    final noWrong = wrongCount == 0;
    final timeBonus = _recallRemaining > level.timerSeconds * 0.5;

    if (allCorrect && noWrong && timeBonus) return 3;
    if (wrongCount <= 1) return 2;
    return 1;
  }

  Future<void> persistStarsIfBest() async {
    final stars = computeStars();
    await progress.mergeBestStars(level.id, stars);
  }
}
