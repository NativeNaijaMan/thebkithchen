import 'package:flutter/material.dart';

import '../app/app_state_scope.dart';
import '../app/kitchen_os_theme.dart';
import '../data/campaign_levels.dart';
import '../data/level_definition.dart';
import '../state/progress_store.dart';
import 'line_screen.dart';
import 'widgets/pos_terminal_button.dart';

/// Level grid with stars and locks — 20 puzzle levels.
class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  Map<String, LevelDefinition>? _levels;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final map = <String, LevelDefinition>{};
      for (final id in kCampaignLevelIds) {
        map[id] = await LevelDefinition.loadFromAssets(id);
      }
      if (mounted) {
        setState(() {
          _levels = map;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = AppStateScope.progressOf(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('ORDER HISTORY'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: _body(context, progress),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, ProgressStore progress) {
    if (_error != null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Could not load tickets: $_error',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          PosTerminalButton(
            label: 'RETRY',
            onPressed: _load,
          ),
        ],
      );
    }
    final levels = _levels;
    if (levels == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: kCampaignLevelIds.length,
      itemBuilder: (context, index) {
        final id = kCampaignLevelIds[index];
        final def = levels[id]!;
        final unlocked = progress.isLevelUnlocked(id, kCampaignLevelIds);
        final stars = progress.starsForLevel(id);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: unlocked
                ? KitchenOsColors.receiptWhite
                : KitchenOsColors.countertopOffWhite,
            elevation: unlocked ? 3 : 0,
            child: InkWell(
              onTap: unlocked
                  ? () async {
                      await Navigator.of(context).push<void>(
                        MaterialPageRoute<void>(
                          builder: (_) => LineScreen(
                            levelId: id,
                            progress: progress,
                          ),
                        ),
                      );
                      if (mounted) setState(() {});
                    }
                  : null,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            unlocked
                                ? '${def.name} (${def.gridSize}×${def.gridSize})'
                                : 'TICKET NOT PRINTED YET',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          if (unlocked) ...[
                            const SizedBox(height: 2),
                            Text(
                              def.recipeRequest,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                          if (!unlocked) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Clear the prior shift with at least 1★.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (unlocked) ...[
                      Text(
                        '${'★' * stars}${'☆' * (3 - stars)}',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  letterSpacing: 2,
                                ),
                      ),
                      const Icon(Icons.chevron_right),
                    ] else
                      const Icon(Icons.lock_outline),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
