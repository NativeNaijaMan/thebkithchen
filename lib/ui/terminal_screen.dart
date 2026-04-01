import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/app_state_scope.dart';
import '../app/kitchen_os_theme.dart';
import '../data/campaign_levels.dart';
import 'appliance_calibration_screen.dart';
import 'employee_manual_screen.dart';
import 'line_screen.dart';
import 'order_history_screen.dart';
import 'widgets/pos_terminal_button.dart';

class TerminalScreen extends StatefulWidget {
  const TerminalScreen({super.key});

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  Future<void> _refreshAfterLine() async {
    if (mounted) setState(() {});
  }

  Future<void> _exitGame(BuildContext context) async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            backgroundColor: KitchenOsColors.receiptWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text('EXIT KITCHEN?'),
            content: const Text('Are you sure you want to leave?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(c).pop(false),
                child: const Text('STAY'),
              ),
              TextButton(
                onPressed: () => Navigator.of(c).pop(true),
                child: Text(
                  'EXIT',
                  style: TextStyle(color: KitchenOsColors.panicRed),
                ),
              ),
            ],
          ),
        ) ??
        false;
    if (!context.mounted || !ok) return;
    if (context.mounted) await SystemNavigator.pop();
  }

  void _clockIn(BuildContext context) {
    final progress = AppStateScope.progressOf(context);
    final id = progress.clockInLevelId(kCampaignLevelIds);
    if (id == null) return;
    Navigator.of(context)
        .push<void>(
      MaterialPageRoute<void>(
        builder: (_) => LineScreen(
          levelId: id,
          progress: progress,
        ),
      ),
    )
        .then((_) => _refreshAfterLine());
  }

  @override
  Widget build(BuildContext context) {
    final progress = AppStateScope.progressOf(context);
    final totalStars = kCampaignLevelIds.fold<int>(
      0,
      (sum, id) => sum + progress.starsForLevel(id),
    );
    final completedLevels = kCampaignLevelIds
        .where((id) => progress.starsForLevel(id) > 0)
        .length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _exitGame(context);
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                KitchenOsColors.bsodBlue,
                Color(0xFF0F1D33),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        color: KitchenOsColors.receiptWhite
                            .withValues(alpha: 0.7),
                        onPressed: () => _exitGame(context),
                        tooltip: 'Exit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined),
                        color: KitchenOsColors.receiptWhite
                            .withValues(alpha: 0.7),
                        onPressed: () {
                          Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  const ApplianceCalibrationScreen(),
                            ),
                          );
                        },
                        tooltip: 'Settings',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      const SizedBox(height: 24),
                      _buildLogo(context),
                      const SizedBox(height: 12),
                      _buildSubtitle(context),
                      const SizedBox(height: 24),
                      _buildStatsBar(context, totalStars, completedLevels),
                      const SizedBox(height: 36),
                      PosTerminalButton(
                        label: 'CLOCK IN',
                        icon: Icons.play_arrow_rounded,
                        onPressed: () => _clockIn(context),
                      ),
                      const SizedBox(height: 14),
                      PosTerminalButton(
                        label: 'ORDER HISTORY',
                        icon: Icons.receipt_long_outlined,
                        secondary: true,
                        onPressed: () {
                          Navigator.of(context)
                              .push<void>(
                            MaterialPageRoute<void>(
                              builder: (_) => const OrderHistoryScreen(),
                            ),
                          )
                              .then((_) => _refreshAfterLine());
                        },
                      ),
                      const SizedBox(height: 14),
                      PosTerminalButton(
                        label: 'EMPLOYEE MANUAL',
                        icon: Icons.menu_book_outlined,
                        secondary: true,
                        onPressed: () {
                          Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(
                              builder: (_) => const EmployeeManualScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 36),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: KitchenOsColors.yolkYellow,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: KitchenOsColors.yolkYellow.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              '🍳',
              style: TextStyle(fontSize: 40),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'THE BROKEN',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: KitchenOsColors.receiptWhite,
                fontWeight: FontWeight.w700,
                letterSpacing: 4,
                fontSize: 28,
                height: 1.1,
              ),
        ),
        Text(
          'KITCHEN',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: KitchenOsColors.yolkYellow,
                fontWeight: FontWeight.w700,
                letterSpacing: 8,
                fontSize: 36,
                height: 1.2,
              ),
        ),
      ],
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return Text(
      'A memory puzzle game',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: KitchenOsColors.mintAppliance.withValues(alpha: 0.8),
            letterSpacing: 2,
            fontSize: 13,
          ),
    );
  }

  Widget _buildStatsBar(
      BuildContext context, int totalStars, int completedLevels) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: KitchenOsColors.receiptWhite.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: KitchenOsColors.receiptWhite.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(
            icon: Icons.star_rounded,
            value: '$totalStars',
            label: 'STARS',
            color: KitchenOsColors.yolkYellow,
          ),
          Container(
            width: 1,
            height: 32,
            color: KitchenOsColors.receiptWhite.withValues(alpha: 0.15),
          ),
          _StatItem(
            icon: Icons.check_circle_outline,
            value: '$completedLevels/${kCampaignLevelIds.length}',
            label: 'LEVELS',
            color: KitchenOsColors.successGreen,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: KitchenOsColors.receiptWhite,
                    fontSize: 16,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: KitchenOsColors.receiptWhite
                        .withValues(alpha: 0.5),
                    fontSize: 9,
                    letterSpacing: 1.5,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
