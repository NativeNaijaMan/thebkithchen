import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/kitchen_os_theme.dart';
import '../../data/kitchen_items.dart';
import '../../state/kitchen_run_state.dart';

class PuzzleGrid extends StatelessWidget {
  const PuzzleGrid({super.key, required this.runState});

  final KitchenRunState runState;

  @override
  Widget build(BuildContext context) {
    final n = runState.level.gridSize;
    final isMemorize = runState.phase == PuzzlePhase.memorize;
    final isRecall = runState.phase == PuzzlePhase.recall;
    final isResult =
        runState.phase == PuzzlePhase.won || runState.phase == PuzzlePhase.lost;

    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: n,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: n * n,
          itemBuilder: (context, index) {
            final tile = runState.tiles[index];
            final selected = runState.selectedIndices.contains(index);
            final isCorrectTile = runState.correctTileIndices.contains(index);

            return PuzzleTileWidget(
              key: ValueKey('tile_${runState.level.id}_$index'),
              itemId: tile.itemId,
              showFace: isMemorize || isResult,
              selected: selected,
              tappable: isRecall && !runState.isPaused,
              resultMode: isResult,
              isCorrectTile: isCorrectTile,
              wasSelected: selected,
              onTap: () => runState.toggleTile(index),
            );
          },
        ),
      ),
    );
  }
}

class PuzzleTileWidget extends StatefulWidget {
  const PuzzleTileWidget({
    super.key,
    required this.itemId,
    required this.showFace,
    required this.selected,
    required this.tappable,
    required this.resultMode,
    required this.isCorrectTile,
    required this.wasSelected,
    required this.onTap,
  });

  final String? itemId;
  final bool showFace;
  final bool selected;
  final bool tappable;
  final bool resultMode;
  final bool isCorrectTile;
  final bool wasSelected;
  final VoidCallback onTap;

  @override
  State<PuzzleTileWidget> createState() => _PuzzleTileWidgetState();
}

class _PuzzleTileWidgetState extends State<PuzzleTileWidget>
    with TickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  bool _showingFace = true;

  @override
  void initState() {
    super.initState();
    _showingFace = widget.showFace;
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.9), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.05), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.05, end: 1.0), weight: 20),
    ]).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void didUpdateWidget(PuzzleTileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showFace != oldWidget.showFace) {
      if (widget.showFace && !_showingFace) {
        _flipController.forward().then((_) {
          if (mounted) setState(() => _showingFace = true);
          _flipController.reset();
        });
      } else if (!widget.showFace && _showingFace) {
        _flipController.forward().then((_) {
          if (mounted) setState(() => _showingFace = false);
          _flipController.reset();
        });
      }
    }
    if (widget.selected != oldWidget.selected && widget.selected) {
      _bounceController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.tappable
          ? () {
              widget.onTap();
              _bounceController.forward(from: 0);
            }
          : null,
      child: AnimatedBuilder(
        animation: Listenable.merge([_flipAnimation, _bounceAnimation]),
        builder: (context, child) {
          final flipValue = _flipAnimation.value;
          final angle = flipValue * math.pi;
          final pastHalf = flipValue > 0.5;
          final scale = _bounceAnimation.value;

          return Transform.scale(
            scale: scale,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(angle),
              child: pastHalf != _showingFace
                  ? _buildFace(context)
                  : _buildBack(context),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFace(BuildContext context) {
    Color? borderColor;
    Color bgColor = KitchenOsColors.receiptWhite;
    double borderWidth = 1.0;

    if (widget.resultMode) {
      if (widget.isCorrectTile && widget.wasSelected) {
        borderColor = KitchenOsColors.successGreen;
        bgColor = KitchenOsColors.successGreen.withValues(alpha: 0.15);
        borderWidth = 3;
      } else if (widget.isCorrectTile && !widget.wasSelected) {
        borderColor = KitchenOsColors.yolkYellow;
        bgColor = KitchenOsColors.yolkYellow.withValues(alpha: 0.15);
        borderWidth = 3;
      } else if (!widget.isCorrectTile && widget.wasSelected) {
        borderColor = KitchenOsColors.panicRed;
        bgColor = KitchenOsColors.panicRed.withValues(alpha: 0.15);
        borderWidth = 3;
      }
    }

    final emoji = widget.itemId != null
        ? KitchenItems.emojiFor(widget.itemId!)
        : '';

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(
          color: borderColor ??
              KitchenOsColors.terminalCharcoal.withValues(alpha: 0.3),
          width: borderWidth,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 28),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBack(BuildContext context) {
    Color borderColor;
    Color bgColor;
    double borderWidth;

    if (widget.selected) {
      borderColor = KitchenOsColors.yolkYellow;
      bgColor = KitchenOsColors.yolkYellow.withValues(alpha: 0.25);
      borderWidth = 3;
    } else {
      borderColor = KitchenOsColors.terminalCharcoal.withValues(alpha: 0.2);
      bgColor = KitchenOsColors.bsodBlue.withValues(alpha: 0.08);
      borderWidth = 1;
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Icon(
          widget.selected ? Icons.check_circle : Icons.help_outline,
          size: 22,
          color: widget.selected
              ? KitchenOsColors.yolkYellow
              : KitchenOsColors.terminalCharcoal.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}

class PuzzleTimerBar extends StatelessWidget {
  const PuzzleTimerBar({super.key, required this.fraction});

  final double fraction;

  @override
  Widget build(BuildContext context) {
    final clamped = fraction.clamp(0.0, 1.0);
    final color = clamped > 0.5
        ? KitchenOsColors.successGreen
        : clamped > 0.25
            ? KitchenOsColors.yolkYellow
            : KitchenOsColors.panicRed;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: clamped, end: clamped),
          duration: const Duration(milliseconds: 200),
          builder: (context, value, _) {
            return LinearProgressIndicator(
              value: value,
              minHeight: 10,
              backgroundColor:
                  KitchenOsColors.terminalCharcoal.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            );
          },
        ),
      ),
    );
  }
}
