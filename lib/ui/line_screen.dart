import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../app/kitchen_os_theme.dart';
import '../data/campaign_levels.dart';
import '../data/level_definition.dart';
import '../state/kitchen_run_state.dart';
import '../state/progress_store.dart';
import 'widgets/pos_terminal_button.dart';
import 'widgets/puzzle_grid.dart';

class LineScreen extends StatefulWidget {
  const LineScreen({
    super.key,
    required this.levelId,
    required this.progress,
  });

  final String levelId;
  final ProgressStore progress;

  @override
  State<LineScreen> createState() => _LineScreenState();
}

class _LineScreenState extends State<LineScreen>
    with SingleTickerProviderStateMixin {
  KitchenRunState? _run;
  LevelDefinition? _level;
  late final Ticker _ticker;
  late String _currentLevelId;
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _currentLevelId = widget.levelId;
    _boot(_currentLevelId);
  }

  Future<void> _boot(String levelId) async {
    final level = await LevelDefinition.loadFromAssets(levelId);
    if (!mounted) return;
    final run = KitchenRunState(level: level, progress: widget.progress);
    run.addListener(_onRunChanged);
    setState(() {
      _level = level;
      _run = run;
    });
    await widget.progress.setLastPlayedLevelId(levelId);
    _restartTicker();
  }

  void _restartTicker() {
    _ticker.stop();
    _lastElapsed = Duration.zero;
    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;
    _run?.tick(dt);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _run?.removeListener(_onRunChanged);
    super.dispose();
  }

  void _onRunChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _persistWinAndClose() async {
    final r = _run;
    if (r != null && r.phase == PuzzlePhase.won) {
      await r.persistStarsIfBest();
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  String? _getNextLevelId() {
    final idx = kCampaignLevelIds.indexOf(_currentLevelId);
    if (idx < 0 || idx >= kCampaignLevelIds.length - 1) return null;
    return kCampaignLevelIds[idx + 1];
  }

  Future<void> _goToNextLevel() async {
    final r = _run;
    if (r != null && r.phase == PuzzlePhase.won) {
      await r.persistStarsIfBest();
    }

    if (!mounted) return;
    final nextId = _getNextLevelId();
    if (nextId == null) {
      Navigator.of(context).pop();
      return;
    }

    _run?.removeListener(_onRunChanged);
    _ticker.stop();

    _currentLevelId = nextId;
    await _boot(nextId);
  }

  void _restartShift() {
    final level = _level;
    if (level == null) return;
    _run?.removeListener(_onRunChanged);
    _ticker.stop();
    final run = KitchenRunState(level: level, progress: widget.progress);
    run.addListener(_onRunChanged);
    setState(() {
      _run = run;
    });
    _restartTicker();
  }

  void _openPause() {
    _run?.setPaused(true);
    _ticker.muted = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _HaltOrderDialog(
        onResume: () {
          Navigator.of(ctx).pop();
          _run?.setPaused(false);
          _ticker.muted = false;
        },
        onRestart: () {
          Navigator.of(ctx).pop();
          _restartShift();
        },
        onTerminal: () {
          Navigator.of(ctx).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _submitOrder() {
    _run?.submitOrder();
  }

  @override
  Widget build(BuildContext context) {
    final run = _run;
    if (run == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isMemorize = run.phase == PuzzlePhase.memorize;
    final isRecall = run.phase == PuzzlePhase.recall;
    final isWon = run.phase == PuzzlePhase.won;
    final isLost = run.phase == PuzzlePhase.lost;

    return Scaffold(
      backgroundColor: KitchenOsColors.countertopOffWhite,
      body: SafeArea(
        child: Column(
          children: [
            _TicketHeader(run: run),
            if (isMemorize)
              _PhaseIndicator(
                label: 'MEMORIZE',
                sublabel:
                    '${run.memorizeRemaining.ceil()}s \u2014 study the items!',
                color: KitchenOsColors.mintAppliance,
              ),
            if (isRecall)
              _PhaseIndicator(
                label: 'RECALL',
                sublabel: 'Tap the correct items from memory!',
                color: KitchenOsColors.yolkYellow,
              ),
            if (isRecall || isMemorize)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: PuzzleTimerBar(
                  fraction: isMemorize
                      ? (run.memorizeRemaining / run.level.memorizeSeconds)
                          .clamp(0.0, 1.0)
                      : run.recallFraction,
                ),
              ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: PuzzleGrid(runState: run),
                ),
              ),
            ),
            if (isRecall)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: PosTerminalButton(
                        label:
                            'SUBMIT ORDER (${run.selectedIndices.length} selected)',
                        onPressed:
                            run.selectedIndices.isEmpty ? null : _submitOrder,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 56,
                      child: PosTerminalButton(
                        label: '\u23f8',
                        secondary: true,
                        onPressed: _openPause,
                      ),
                    ),
                  ],
                ),
              ),
            if (isMemorize)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 56,
                    child: PosTerminalButton(
                      label: '\u23f8',
                      secondary: true,
                      onPressed: _openPause,
                    ),
                  ),
                ),
              ),
            if (isWon)
              _WinBanner(
                run: run,
                hasNextLevel: _getNextLevelId() != null,
                onContinue: _persistWinAndClose,
                onNextLevel: _goToNextLevel,
              ),
            if (isLost)
              _LoseBanner(
                run: run,
                onRetry: _restartShift,
                onTerminal: () => Navigator.of(context).pop(),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _TicketHeader extends StatelessWidget {
  const _TicketHeader({required this.run});

  final KitchenRunState run;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Material(
        elevation: 4,
        shadowColor: Colors.black26,
        color: Colors.transparent,
        child: ClipPath(
          clipper: const _ReceiptTearClipper(tooth: 7, tearDepth: 10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
            decoration: const BoxDecoration(
              color: KitchenOsColors.receiptWhite,
              border: Border(
                top: BorderSide(
                  color: KitchenOsColors.terminalCharcoal,
                  width: 2,
                ),
                left: BorderSide(
                  color: KitchenOsColors.terminalCharcoal,
                  width: 1,
                ),
                right: BorderSide(
                  color: KitchenOsColors.terminalCharcoal,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  run.level.name.toUpperCase(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontFamily: 'SpaceMono',
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  run.level.recipeRequest,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontFamily: 'SpaceMono',
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  run.level.objectiveText,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontFamily: 'SpaceMono',
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PhaseIndicator extends StatelessWidget {
  const _PhaseIndicator({
    required this.label,
    required this.sublabel,
    required this.color,
  });

  final String label;
  final String sublabel;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFamily: 'SpaceMono',
                    color: KitchenOsColors.terminalCharcoal,
                  ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                sublabel,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontFamily: 'SpaceMono',
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WinBanner extends StatelessWidget {
  const _WinBanner({
    required this.run,
    required this.hasNextLevel,
    required this.onContinue,
    required this.onNextLevel,
  });

  final KitchenRunState run;
  final bool hasNextLevel;
  final VoidCallback onContinue;
  final VoidCallback onNextLevel;

  @override
  Widget build(BuildContext context) {
    final stars = run.computeStars();
    final total = run.level.correctItemIds.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: KitchenOsColors.receiptWhite,
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'ORDER UP!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: KitchenOsColors.successGreen,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '${run.correctCount}/$total correct \u00b7 ${run.wrongCount} wrong',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'MICHELIN STARS: ${'★' * stars}${'☆' * (3 - stars)}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              if (hasNextLevel)
                PosTerminalButton(
                  label: 'NEXT LEVEL',
                  onPressed: onNextLevel,
                ),
              if (hasNextLevel) const SizedBox(height: 8),
              PosTerminalButton(
                label: 'BACK TO TERMINAL',
                secondary: hasNextLevel,
                onPressed: onContinue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoseBanner extends StatelessWidget {
  const _LoseBanner({
    required this.run,
    required this.onRetry,
    required this.onTerminal,
  });

  final KitchenRunState run;
  final VoidCallback onRetry;
  final VoidCallback onTerminal;

  @override
  Widget build(BuildContext context) {
    final reason = run.loseReason ?? 'UNKNOWN';
    final copy = reason == 'TIMEOUT'
        ? 'Time ran out!'
        : 'Not enough correct items selected.';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: KitchenOsColors.receiptWhite,
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'HEALTH INSPECTION FAILED',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: KitchenOsColors.panicRed,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(copy, style: Theme.of(context).textTheme.bodyLarge),
              if (run.loseReason == 'NOT_ENOUGH_CORRECT') ...[
                const SizedBox(height: 4),
                Text(
                  '${run.correctCount}/${run.level.minCorrectThreshold} needed',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
              const SizedBox(height: 12),
              PosTerminalButton(
                label: 'RETRY SHIFT',
                onPressed: onRetry,
              ),
              const SizedBox(height: 8),
              PosTerminalButton(
                label: 'BACK TO TERMINAL',
                secondary: true,
                onPressed: onTerminal,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HaltOrderDialog extends StatelessWidget {
  const _HaltOrderDialog({
    required this.onResume,
    required this.onRestart,
    required this.onTerminal,
  });

  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onTerminal;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Material(
          color: KitchenOsColors.receiptWhite,
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'HALT ORDER',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                PosTerminalButton(
                  label: 'RESUME SHIFT',
                  onPressed: onResume,
                ),
                const SizedBox(height: 12),
                PosTerminalButton(
                  label: 'SCRAP ORDER (RESTART)',
                  secondary: true,
                  onPressed: onRestart,
                ),
                const SizedBox(height: 12),
                PosTerminalButton(
                  label: 'BACK TO TERMINAL',
                  secondary: true,
                  onPressed: onTerminal,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReceiptTearClipper extends CustomClipper<Path> {
  const _ReceiptTearClipper({
    required this.tooth,
    required this.tearDepth,
  });

  final double tooth;
  final double tearDepth;

  @override
  Path getClip(Size size) {
    final path = Path()..moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - tearDepth);
    var x = size.width;
    final yBase = size.height - tearDepth;
    var toggle = false;
    while (x > 0) {
      x -= tooth;
      if (x < 0) x = 0;
      final y = toggle ? yBase + tearDepth * 0.55 : yBase;
      toggle = !toggle;
      path.lineTo(x, y);
    }
    path.lineTo(0, yBase);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _ReceiptTearClipper oldClipper) {
    return oldClipper.tooth != tooth || oldClipper.tearDepth != tearDepth;
  }
}
