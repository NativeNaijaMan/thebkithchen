import 'package:flutter/material.dart';

/// How to play: memorize → recall → submit (puzzle redesign).
class EmployeeManualScreen extends StatelessWidget {
  const EmployeeManualScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EMPLOYEE MANUAL'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          children: [
            Text(
              'HOW TO SURVIVE KITCHENOS',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            _section(
              context,
              'The job',
              'Each ticket shows a recipe — like "Fry an Egg." '
              'Your job is to remember which kitchen items you need '
              'and find them on the grid before time runs out.',
            ),
            _section(
              context,
              'Memorize phase',
              'When the round starts, a grid of kitchen items appears. '
              'Study them carefully — you have limited time before they '
              'disappear. Pay attention to the items that match your recipe.',
            ),
            _section(
              context,
              'Recall phase',
              'After the items vanish, tap the tiles where the correct '
              'items were. You don\'t always need every single item — '
              'meeting the minimum threshold is enough to pass. '
              'But more correct picks means more stars!',
            ),
            _section(
              context,
              'Submit order',
              'When you\'re confident in your selections, hit SUBMIT ORDER. '
              'The game will reveal the grid and grade your performance.',
            ),
            _section(
              context,
              'Stars',
              '★★★ — All correct, no wrong picks, and fast.\n'
              '★★☆ — Threshold met with at most 1 mistake.\n'
              '★☆☆ — Bare minimum to pass.',
            ),
            _section(
              context,
              'Pause & bail out',
              'HALT ORDER freezes the timer. RESUME SHIFT continues where '
              'you left off. SCRAP ORDER restarts the ticket. '
              'BACK TO TERMINAL returns to the main menu.',
            ),
            _section(
              context,
              'Privacy',
              'Full wording is under Appliance Calibration → Health & '
              'Safety Notice (offline play, no accounts).',
            ),
            const SizedBox(height: 24),
            Text(
              'Now clock in and trust your memory.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(BuildContext context, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
