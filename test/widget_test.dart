import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:xhinekwu/main.dart';
import 'package:xhinekwu/state/progress_store.dart';

void main() {
  testWidgets('App boots to splash with KitchenOS shell', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final progress = await ProgressStore.load();
    await tester.pumpWidget(TheBrokenKitchenApp(progress: progress));
    await tester.pump();
    expect(find.textContaining('BROKEN'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
