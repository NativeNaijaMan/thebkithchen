import 'package:flutter/material.dart';

import 'app/app_routes.dart';
import 'app/app_state_scope.dart';
import 'app/kitchen_os_theme.dart';
import 'state/progress_store.dart';
import 'ui/splash_screen.dart';
import 'ui/terminal_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final progress = await ProgressStore.load();
  runApp(TheBrokenKitchenApp(progress: progress));
}

/// Root app shell: local prefs, KitchenOS theme, splash → terminal.
class TheBrokenKitchenApp extends StatelessWidget {
  const TheBrokenKitchenApp({super.key, required this.progress});

  final ProgressStore progress;

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      progress: progress,
      child: MaterialApp(
        title: 'The Broken Kitchen',
        debugShowCheckedModeBanner: false,
        theme: buildKitchenOsTheme(),
        routes: {
          AppRoutes.terminal: (context) => const TerminalScreen(),
        },
        home: const SplashScreen(),
      ),
    );
  }
}
