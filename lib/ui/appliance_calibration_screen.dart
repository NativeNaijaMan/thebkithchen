import 'package:flutter/material.dart';

import '../app/app_state_scope.dart';
import 'health_safety_notice_screen.dart';

class ApplianceCalibrationScreen extends StatefulWidget {
  const ApplianceCalibrationScreen({super.key});

  @override
  State<ApplianceCalibrationScreen> createState() =>
      _ApplianceCalibrationScreenState();
}

class _ApplianceCalibrationScreenState
    extends State<ApplianceCalibrationScreen> {
  @override
  Widget build(BuildContext context) {
    final progress = AppStateScope.progressOf(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Health & Safety Notice',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              subtitle: const Text('Privacy & offline data.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => HealthSafetyNoticeScreen(
                      progress: progress,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
