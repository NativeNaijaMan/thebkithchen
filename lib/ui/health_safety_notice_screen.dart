import 'package:flutter/material.dart';

import '../app/app_routes.dart';
import '../state/progress_store.dart';
import 'widgets/pos_terminal_button.dart';

/// Health & Safety / privacy copy — offline, no accounts (Phase 5).
class HealthSafetyNoticeScreen extends StatelessWidget {
  const HealthSafetyNoticeScreen({
    super.key,
    required this.progress,
    this.firstRunGate = false,
  });

  final ProgressStore progress;

  /// When true, no back affordance; player must acknowledge (first boot).
  final bool firstRunGate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HEALTH & SAFETY NOTICE'),
        automaticallyImplyLeading: !firstRunGate,
        leading: firstRunGate
            ? const SizedBox.shrink()
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          children: [
            Text(
              'KitchenOS — employee briefing',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'The Broken Kitchen runs offline on this device. It does not require '
              'an account, does not upload personal gameplay data, and does not '
              'collect analytics in this build. Progress (stars per shift) is '
              'stored only on your device.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'If we ship ads or online features later, this notice will be updated '
              'before those go live.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (firstRunGate) ...[
              const SizedBox(height: 32),
              PosTerminalButton(
                label: 'ACKNOWLEDGE — OPEN TERMINAL',
                onPressed: () async {
                  await progress.setHealthSafetyAcknowledged();
                  if (!context.mounted) {
                    return;
                  }
                  Navigator.of(context).pushReplacementNamed(AppRoutes.terminal);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
