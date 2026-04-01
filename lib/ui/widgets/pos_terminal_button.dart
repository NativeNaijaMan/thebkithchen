import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/kitchen_os_theme.dart';

class PosTerminalButton extends StatefulWidget {
  const PosTerminalButton({
    super.key,
    required this.label,
    this.onPressed,
    this.secondary = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool secondary;
  final IconData? icon;

  @override
  State<PosTerminalButton> createState() => _PosTerminalButtonState();
}

class _PosTerminalButtonState extends State<PosTerminalButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    _pressController.forward();
  }

  void _handleTapUp(TapUpDetails _) {
    _pressController.reverse();
  }

  void _handleTapCancel() {
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null;

    final bg = widget.secondary
        ? KitchenOsColors.receiptWhite
        : KitchenOsColors.terminalCharcoal;
    final fg = widget.secondary
        ? KitchenOsColors.terminalCharcoal
        : KitchenOsColors.receiptWhite;
    final borderColor = widget.secondary
        ? KitchenOsColors.terminalCharcoal.withValues(alpha: 0.25)
        : KitchenOsColors.terminalCharcoal;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: disabled ? null : _handleTapDown,
        onTapUp: disabled ? null : _handleTapUp,
        onTapCancel: disabled ? null : _handleTapCancel,
        onTap: disabled
            ? null
            : () {
                HapticFeedback.lightImpact();
                widget.onPressed?.call();
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: disabled ? bg.withValues(alpha: 0.5) : bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: disabled
                ? []
                : [
                    BoxShadow(
                      color: KitchenOsColors.terminalCharcoal
                          .withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: fg, size: 20),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: disabled ? fg.withValues(alpha: 0.5) : fg,
                        fontFamily: 'SpaceMono',
                        letterSpacing: 1.2,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
