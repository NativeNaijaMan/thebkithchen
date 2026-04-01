import 'dart:async';

import 'package:flutter/material.dart';

import '../app/app_routes.dart';
import '../app/app_state_scope.dart';
import '../app/kitchen_os_theme.dart';

/// Boot sequence → Terminal. Health & Safety stays under Appliance Calibration.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _bootTimer;
  bool _scheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_scheduled) {
      return;
    }
    _scheduled = true;
    final progress = AppStateScope.progressOf(context);
    final quickBoot = progress.hasCompletedSplashBoot;
    final delay = quickBoot
        ? const Duration(milliseconds: 550)
        : const Duration(milliseconds: 2200);
    _bootTimer = Timer(delay, _go);
  }

  @override
  void dispose() {
    _bootTimer?.cancel();
    super.dispose();
  }

  Future<void> _go() async {
    if (!mounted) {
      return;
    }
    final progress = AppStateScope.progressOf(context);
    await progress.markSplashBootDone();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushReplacementNamed(AppRoutes.terminal);
  }

  @override
  Widget build(BuildContext context) {
    final progress = AppStateScope.progressOf(context);
    final firstBoot = !progress.hasCompletedSplashBoot;

    return Scaffold(
      backgroundColor: KitchenOsColors.bsodBlue,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'THE BROKEN KITCHEN',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: KitchenOsColors.receiptWhite,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  firstBoot
                      ? 'LOADING KITCHENOS…\nIntegrity check: dubious.'
                      : 'KitchenOS standby…',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: KitchenOsColors.mintAppliance,
                      ),
                ),
                const SizedBox(height: 32),
                const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    color: KitchenOsColors.yolkYellow,
                    strokeWidth: 3,
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
