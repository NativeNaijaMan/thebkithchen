# **Implementation Plan: The Broken Kitchen (Puzzle Redesign)**

This document is the **end-to-end build plan** for the redesigned memory-puzzle version of The Broken Kitchen. It stays aligned with **`GDD.md`** (what players experience) and **`DesignLanguage.md`** (how it looks and feels).

**Starting point:** The Flutter project currently uses **Flame** for a cooking sim with glitch mechanics. This redesign removes Flame and replaces the core gameplay with a pure-Flutter grid-based memory puzzle. The KitchenOS shell, navigation, theming, audio infrastructure, and persistence layer are retained.

---

## **Principles**

1. **Pure Flutter:** The puzzle grid is built with Flutter widgets (no Flame). This simplifies the architecture and removes the Flutter/Flame bridge complexity.
2. **Data-driven levels:** Every level is a JSON file. Adding or tuning levels requires no code changes.
3. **State machine clarity:** The puzzle has three distinct phases (memorize → recall → evaluate) with clean transitions.
4. **Retain the shell:** Terminal, splash, pause, order history, and settings screens stay largely intact with minor adjustments.
5. **Ship 20 levels:** Enough content for a credible store listing with a clear difficulty curve.

---

## **Phase 1 — Remove Flame & Clean Up**

**Goal:** Strip the Flame engine and all glitch-related code so the project compiles as a pure-Flutter app.

1. **Remove Flame dependencies**
   * Remove `flame` and `flame_audio` from `pubspec.yaml`. Add `audioplayers` if needed for sound.
   * Delete `lib/game/kitchen_game.dart` and `lib/game/countertop_scene.dart`.
   * Delete `lib/data/glitch_modifier.dart`.
   * Remove all glitch-related UI widgets (fleeing order up, tier3 dialogs, fake error layers, etc.).

2. **Simplify imports**
   * Remove all Flame imports and references across the codebase.
   * `line_screen.dart` will temporarily show a placeholder instead of `GameWidget`.

3. **Verify compilation**
   * The app should build and run, showing the Terminal with a stub gameplay screen.

---

## **Phase 2 — New Data Layer**

**Goal:** Define the level schema and kitchen item catalog that drives the entire puzzle.

1. **Level definition model** (`lib/data/level_definition.dart`)
   * New fields: `gridSize`, `memorizeSeconds`, `timerSeconds`, `recipeRequest`, `correctItemIds`, `distractorItemIds`, `minCorrectThreshold`.
   * Factory constructor from JSON. Static loader from `assets/levels/`.

2. **Kitchen item catalog** (`lib/data/kitchen_items.dart`)
   * A registry mapping item IDs to display names and emoji icons.
   * Used by the grid widget to render tiles.

3. **Campaign levels** (`lib/data/campaign_levels.dart`)
   * Expand to 20 level IDs (`level_01` through `level_20`).

4. **Level JSON files** (`assets/levels/`)
   * Author all 20 level files with escalating difficulty per the GDD tables.
   * Register all 20 in `pubspec.yaml` assets.

---

## **Phase 3 — Puzzle State Machine**

**Goal:** Build the runtime state that drives the memorize → recall → evaluate loop.

1. **PuzzleRunState** (`lib/state/kitchen_run_state.dart`)
   * Enum for phases: `memorize`, `recall`, `evaluating`, `won`, `lost`.
   * Grid state: shuffled list of item IDs placed in grid positions.
   * Selection tracking: set of selected tile indices.
   * Timer management: memorize countdown, recall countdown.
   * `tick(dt)` advances the active countdown; triggers phase transitions automatically (memorize → recall when memorize timer expires).
   * `selectTile(index)` / `deselectTile(index)` for player interaction.
   * `submitOrder()` triggers evaluation: count correct selections vs threshold.
   * `computeStars()` based on accuracy and time remaining.
   * Pause/resume support that freezes timers.

2. **Evaluation logic**
   * Count how many selected tiles match `correctItemIds`.
   * Count wrong selections (selected tiles that are distractors).
   * Win if correct >= `minCorrectThreshold`.
   * Star calculation per GDD Section 7.

---

## **Phase 4 — Puzzle Grid Widget**

**Goal:** The core visual component—a grid of tiles that shows items, flips, and accepts taps.

1. **PuzzleGrid widget** (`lib/ui/widgets/puzzle_grid.dart`)
   * Renders an N×N grid of `PuzzleTile` widgets.
   * During memorize: tiles show item icons face-up. No interaction.
   * During recall: tiles show card backs. Tappable. Selected tiles get a highlight border.
   * During evaluation: tiles flip to reveal contents. Correct selections glow green, wrong selections flash red, missed correct items pulse.

2. **PuzzleTile widget**
   * Animated flip between front (item icon) and back (uniform card back).
   * Selection state visual (border, glow).
   * Kitchen-themed card back design (KitchenOS pattern).

3. **Timer bar widget**
   * Horizontal bar that shrinks as time passes.
   * Color transitions: green → yellow → red as time runs low.
   * Pulses when below 25% time remaining.

---

## **Phase 5 — UI Integration**

**Goal:** Wire the puzzle into the existing screen flow.

1. **LineScreen** (`lib/ui/line_screen.dart`)
   * Replace `GameWidget` with `PuzzleGrid`.
   * Show recipe ticket at top (reuse ticket styling).
   * Show timer bar below grid.
   * Show "Submit Order" button during recall phase.
   * Phase transition: automatic (memorize timer expires → recall begins).

2. **Level complete overlay**
   * Show stars, accuracy (X/Y correct, Z wrong), time remaining.
   * "Next Ticket" and "Back to Terminal" buttons.

3. **Game over overlay**
   * Show failure reason (timeout or below threshold).
   * "Retry" and "Back to Terminal" buttons.

4. **Pause menu**
   * Freeze timer. Resume, Scrap Order, Back to Terminal.

5. **Order History**
   * Update to show 20 levels in a scrollable grid.

---

## **Phase 6 — Polish & Audio**

**Goal:** Make it feel satisfying and complete.

1. **Animations**
   * Tile flip animation (3D perspective transform).
   * Selection feedback (scale bounce on tap).
   * Evaluation reveal sequence (tiles flip one-by-one with stagger).
   * Star award animation.

2. **Audio**
   * Tile flip sound effect.
   * Correct selection chime.
   * Wrong selection buzz.
   * Timer urgency ticking (last 5 seconds).
   * Victory jingle on level complete.
   * Failure sound on game over.

3. **Visual polish**
   * Grid appears with a subtle entrance animation.
   * Timer bar smooth animation.
   * Ticket receipt styling for recipe display.

---

## **Phase 7 — Testing & Release**

1. **Playtest all 20 levels** — verify difficulty curve feels right.
2. **Device testing** — small phone, tall phone, tablet layout.
3. **Edge cases** — rapid tapping, pause during phase transition, back button behavior.
4. **Store readiness** — screenshots, description, privacy text.

---

## **Dependency and Documentation Alignment**

| Topic | Source of Truth |
| :--- | :--- |
| Player-facing loop, screens, items, recipes | `GDD.md` |
| Colors, type, spacing, components | `DesignLanguage.md` |
| Build order and engineering duties | This plan |
