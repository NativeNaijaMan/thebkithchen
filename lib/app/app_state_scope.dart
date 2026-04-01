import 'package:flutter/material.dart';

import '../state/progress_store.dart';

/// Holds dependencies that outlive a single screen (no extra packages).
class AppStateScope extends InheritedWidget {
  const AppStateScope({
    super.key,
    required this.progress,
    required super.child,
  });

  final ProgressStore progress;

  static ProgressStore progressOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope not found');
    return scope!.progress;
  }

  @override
  bool updateShouldNotify(covariant AppStateScope oldWidget) {
    return progress != oldWidget.progress;
  }
}
